"""Mutation checks keep the compatibility verifier from accepting broken streams."""
import copy
import json
from pathlib import Path
import unittest

from verify import verify


class EnvelopeVerifierTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.expected = json.loads(Path("expected.json").read_text())
        cls.records = {r["fixture"]: r for r in (
            json.loads(line.removeprefix("COMPAT:"))
            for line in Path("_build/baseline.jsonl").read_text().splitlines()
            if line.startswith("COMPAT:")
        )}

    def test_rejects_dangling_case_finish(self):
        record = copy.deepcopy(self.records["hooks"])
        envelopes = [json.loads(line) for line in record["messages"].splitlines()]
        next(e["testCaseFinished"] for e in envelopes if "testCaseFinished" in e)["testCaseStartedId"] = "missing-start"
        record["messages"] = "\n".join(json.dumps(e) for e in envelopes)
        with self.assertRaises(AssertionError):
            verify(record, self.expected["hooks"])

    def edited(self, label, edit):
        record = copy.deepcopy(self.records[label])
        envelopes = [json.loads(line) for line in record["messages"].splitlines()]
        edit(envelopes)
        record["messages"] = "\n".join(json.dumps(e) for e in envelopes)
        return record

    def test_rejects_missing_step_events(self):
        record = self.edited("passing", lambda events: events.__setitem__(slice(None), [
            e for e in events if not ({"testStepStarted", "testStepFinished"} & e.keys())
        ]))
        with self.assertRaises(AssertionError):
            verify(record, self.expected["passing"])

    def test_rejects_corrupt_intermediate_retry_status(self):
        def corrupt(events):
            first = next(e["testStepFinished"] for e in events if "testStepFinished" in e)
            first["testStepResult"]["status"] = "PASSED"
        with self.assertRaises(AssertionError):
            verify(self.edited("retries-isolation", corrupt), self.expected["retries-isolation"])

    def test_rejects_changed_step_status(self):
        def corrupt(events):
            next(e["testStepFinished"] for e in events if "testStepFinished" in e)["testStepResult"]["status"] = "FAILED"
        with self.assertRaises(AssertionError):
            verify(self.edited("passing", corrupt), self.expected["passing"])

    def test_rejects_attachment_to_wrong_existing_step(self):
        def corrupt(events):
            case = next(e["testCase"] for e in events if "testCase" in e)
            attachment = next(e["attachment"] for e in events if e.get("attachment", {}).get("body") == "after case:Attached")
            attachment["testStepId"] = case["testSteps"][2]["id"]
        with self.assertRaises(AssertionError):
            verify(self.edited("hooks", corrupt), self.expected["hooks"])

    def test_rejects_dry_run_hook_step_offset(self):
        def corrupt(events):
            case = next(e["testCase"] for e in events if "testCase" in e)
            regular = next(s for s in case["testSteps"] if "pickleStepId" in s)
            hook = next(s for s in case["testSteps"] if "hookId" in s)
            for envelope in events:
                for kind in ("testStepStarted", "testStepFinished"):
                    if envelope.get(kind, {}).get("testStepId") == regular["id"]:
                        envelope[kind]["testStepId"] = hook["id"]
        with self.assertRaises((AssertionError, KeyError)):
            verify(self.edited("hooks-dry-run", corrupt), self.expected["hooks-dry-run"])

    def test_rejects_dangling_step_reference(self):
        def corrupt(events):
            next(e["testStepFinished"] for e in events if "testStepFinished" in e)["testStepId"] = "unknown-step"
        with self.assertRaises(AssertionError):
            verify(self.edited("hooks", corrupt), self.expected["hooks"])

    def test_rejects_dangling_hook_references(self):
        for kind, field in (("testRunHookStarted", "hookId"), ("testRunHookFinished", "testRunHookStartedId")):
            with self.subTest(kind=kind):
                def corrupt(events):
                    next(e[kind] for e in events if kind in e)[field] = "unknown-hook"
                with self.assertRaises(AssertionError):
                    verify(self.edited("hooks", corrupt), self.expected["hooks"])

    def test_rejects_dangling_run_attachment(self):
        def corrupt(events):
            next(e["attachment"] for e in events if e.get("attachment", {}).get("body") == "before run")["testRunHookStartedId"] = "unknown-run-hook"
        with self.assertRaises(AssertionError):
            verify(self.edited("hooks", corrupt), self.expected["hooks"])

    def test_rejects_wrong_source_content(self):
        def corrupt(events):
            next(e["source"] for e in events if "source" in e)["data"] = "different feature"
        with self.assertRaises(AssertionError):
            verify(self.edited("passing", corrupt), self.expected["passing"])

    def test_case_finishes_match_identity_not_position(self):
        def reorder(events):
            finishes = [e for e in events if "testCaseFinished" in e]
            events[:] = [e for e in events if "testCaseFinished" not in e]
            after_run = next(i for i, e in enumerate(events) if e.get("attachment", {}).get("body") == "after run")
            events[after_run - 1:after_run - 1] = reversed(finishes)
        verify(self.edited("hooks", reorder), self.expected["hooks"])

    def test_normalization_preserves_aliases_but_ignores_clocks(self):
        from verify import ID_ARRAY_KEYS, ID_KEYS, normalize
        original = [json.loads(line) for line in self.records["hooks"]["messages"].splitlines()]

        def rename(value, key=""):
            if key in ID_KEYS and isinstance(value, str):
                return "different-" + value
            if key in {"timestamp", "duration"}:
                return {"seconds": 987, "nanos": 123}
            if isinstance(value, list):
                return ["different-" + v if key in ID_ARRAY_KEYS else rename(v) for v in value]
            if isinstance(value, dict):
                return {k: rename(v, k) for k, v in value.items()}
            return value

        self.assertEqual(normalize(original), normalize(rename(original)))
        broken = copy.deepcopy(original)
        next(e["testCaseFinished"] for e in broken if "testCaseFinished" in e)["testCaseStartedId"] = "new-identity"
        self.assertNotEqual(normalize(original), normalize(broken))
