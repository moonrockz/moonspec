"""Compare public results and Cucumber Messages without discarding ID relationships."""
import json
from pathlib import Path
import sys


ID_KEYS = {
    "id", "pickleId", "pickleStepId", "hookId", "testCaseId", "testStepId",
    "testCaseStartedId", "testRunStartedId", "testRunHookStartedId", "astNodeId",
}
ID_ARRAY_KEYS = {"astNodeIds", "stepDefinitionIds"}


def normalize(envelopes):
    """Rename identities consistently; clocks and backend metadata are not semantics."""
    identities = {}

    def identity(value):
        if value not in identities:
            identities[value] = f"id-{len(identities)}"
        return identities[value]

    def visit(value, key=""):
        if key in ID_KEYS and isinstance(value, str):
            return identity(value)
        if isinstance(value, list):
            return [identity(v) if key in ID_ARRAY_KEYS else visit(v) for v in value]
        if isinstance(value, dict):
            return {k: visit(v, k) for k, v in value.items()
                    if k not in {"timestamp", "duration"}}
        return value

    result = visit(envelopes)
    for envelope in result:
        if "meta" in envelope:
            for key in ("runtime", "os", "cpu"):
                envelope["meta"].pop(key, None)
    return result


def verify_envelopes(record, expected, envelopes):
    label = record["fixture"]
    assert envelopes and list(envelopes[0]) == ["meta"], (label, "Meta must be first")
    assert list(envelopes[-1]) == ["testRunFinished"], (label, "run must finish")

    def events(kind):
        return [(index, envelope[kind]) for index, envelope in enumerate(envelopes) if kind in envelope]

    def definitions(kind):
        result = {}
        for index, value in events(kind):
            assert value["id"] not in result, (label, "duplicate identity", kind, value["id"])
            result[value["id"]] = (index, value)
        return result

    def reference(table, identity, position):
        assert identity in table, (label, "dangling reference", identity)
        index, value = table[identity]
        assert index < position, (label, "reference precedes definition", identity)
        return value

    sources = {value["uri"]: (index, value) for index, value in events("source")}
    source_paths = expected.get("sources", [expected["source"]])
    assert set(sources) == set(source_paths), (label, "source URIs", list(sources))
    for uri, (_, source) in sources.items():
        assert source["data"] == (Path(__file__).resolve().parent / uri).read_text(), (label, "original source", uri)
    for index, document in events("gherkinDocument"):
        reference(sources, document["uri"], index)
    pickles = definitions("pickle")
    step_definitions = definitions("stepDefinition")
    hooks = definitions("hook")
    cases = definitions("testCase")
    run_starts = definitions("testRunStarted")
    case_starts = definitions("testCaseStarted")
    run_hook_starts = definitions("testRunHookStarted")
    assert len(run_starts) == 1, label
    assert len(events("testRunFinished")) == 1, label
    run_finish_index, run_finish = events("testRunFinished")[0]
    reference(run_starts, run_finish["testRunStartedId"], run_finish_index)
    assert run_finish["success"] == expected.get("run_success", record["summary"]["passed"] == record["summary"]["total"]), label

    pickle_steps = {}
    for index, pickle in pickles.values():
        reference(sources, pickle["uri"], index)
        for step in pickle["steps"]:
            assert step["id"] not in pickle_steps, (label, "duplicate pickle step")
            pickle_steps[step["id"]] = step
    test_steps = {}
    for index, case in cases.values():
        pickle = reference(pickles, case["pickleId"], index)
        local_steps = {step["id"] for step in pickle["steps"]}
        for step in case["testSteps"]:
            assert step["id"] not in test_steps, (label, "duplicate test step")
            test_steps[step["id"]] = (case["id"], step)
            if "hookId" in step:
                hook = reference(hooks, step["hookId"], index)
                assert hook["type"] in {"BEFORE_TEST_CASE", "AFTER_TEST_CASE"}, label
            else:
                assert step["pickleStepId"] in local_steps, (label, "step belongs to another pickle")
                for identity in step.get("stepDefinitionIds", []):
                    reference(step_definitions, identity, index)

    case_finishes = {}
    for index, finish in events("testCaseFinished"):
        identity = finish["testCaseStartedId"]
        reference(case_starts, identity, index)
        assert identity not in case_finishes, (label, "duplicate case finish")
        case_finishes[identity] = (index, finish)
    assert set(case_finishes) == set(case_starts), (label, "unfinished case")
    cases_by_name = {}
    for _, case in cases.values():
        name = pickles[case["pickleId"]][1]["name"]
        assert name not in cases_by_name, (label, "fixture names must be unique")
        cases_by_name[name] = case
    assert set(cases_by_name) == {s["name"] for s in record["scenarios"]}, (label, "filtered cases")
    starts_by_case = {identity: [] for identity in cases}
    for index, start in case_starts.values():
        reference(cases, start["testCaseId"], index)
        assert next(iter(run_starts.values()))[0] < index < run_finish_index, label
        starts_by_case[start["testCaseId"]].append(start)
    attempts = []
    for scenario in record["scenarios"]:
        case = cases_by_name[scenario["name"]]
        starts = sorted(starts_by_case[case["id"]], key=lambda s: s["attempt"])
        assert starts, (label, "case never executed", scenario["name"])
        assert [s["attempt"] for s in starts] == list(range(len(starts))), (label, "attempt sequence")
        for ordinal, start in enumerate(starts):
            finish = case_finishes[start["id"]][1]
            assert finish["willBeRetried"] == (ordinal + 1 < len(starts)), (label, "retry promises another attempt")
            attempts.append([start["attempt"], finish["willBeRetried"]])
    assert attempts == expected["attempts"], (label, attempts)

    step_starts = {}
    step_finishes = {}
    for kind, target in (("testStepStarted", step_starts), ("testStepFinished", step_finishes)):
        for index, event in events(kind):
            start = reference(case_starts, event["testCaseStartedId"], index)
            assert event["testStepId"] in test_steps, (label, "unknown test step")
            owner, _ = test_steps[event["testStepId"]]
            assert owner == start["testCaseId"], (label, "step belongs to another case")
            assert index < case_finishes[start["id"]][0], (label, "step after case finish")
            key = (start["id"], event["testStepId"])
            assert key not in target, (label, "duplicate step event", kind, key)
            target[key] = (index, event)
    assert set(step_starts) == set(step_finishes), (label, "unpaired step events")
    for key in step_starts:
        assert step_starts[key][0] < step_finishes[key][0], (label, "step finishes before start")
    for identity, (_, start) in case_starts.items():
        case = cases[start["testCaseId"]][1]
        planned = case["testSteps"]
        regular = [step for step in planned if "pickleStepId" in step]
        count = len(regular) if expected.get("dry_run") else len(planned)
        assert sum(key[0] == identity for key in step_starts) == count, (label, "every planned step must emit events")
    for scenario in record["scenarios"]:
        case = cases_by_name[scenario["name"]]
        starts = sorted(starts_by_case[case["id"]], key=lambda start: start["attempt"])
        regular = [step for step in case["testSteps"] if "pickleStepId" in step]
        expected_attempts = expected.get("attempt_steps", {}).get(
            scenario["name"], [[step["status"].upper() for step in scenario["steps"]]])
        assert len(starts) == len(expected_attempts), (label, "attempt status coverage")
        for start, wanted in zip(starts, expected_attempts):
            statuses = [step_finishes[(start["id"], step["id"])][1]["testStepResult"]["status"] for step in regular]
            assert statuses == wanted, (label, scenario["name"], start["attempt"], "envelope/result attempt step statuses", statuses)

    run_hook_finishes = {}
    for index, start in run_hook_starts.values():
        reference(run_starts, start["testRunStartedId"], index)
        hook = reference(hooks, start["hookId"], index)
        assert hook["type"] in {"BEFORE_TEST_RUN", "AFTER_TEST_RUN"}, label
    for index, finish in events("testRunHookFinished"):
        identity = finish["testRunHookStartedId"]
        reference(run_hook_starts, identity, index)
        assert identity not in run_hook_finishes, (label, "duplicate run hook finish")
        assert index < run_finish_index, label
        run_hook_finishes[identity] = (index, finish)
    assert set(run_hook_starts) == set(run_hook_finishes), (label, "unfinished run hook")
    if "hook_log" in expected:
        assert sorted(value["type"] for _, value in hooks.values()) == sorted([
            "BEFORE_TEST_RUN", "AFTER_TEST_RUN", "BEFORE_TEST_CASE", "AFTER_TEST_CASE", "BEFORE_TEST_STEP", "AFTER_TEST_STEP",
        ]), (label, "all six hook definitions")
        assert [hooks[value["hookId"]][1]["type"] for _, value in run_hook_starts.values()] == ["BEFORE_TEST_RUN", "AFTER_TEST_RUN"], label

    attachment_links = []
    for kind, count_key in (("attachment", "attachments"), ("externalAttachment", "external_attachments")):
        attachments = events(kind)
        assert len(attachments) == expected.get(count_key, 0), (label, count_key, len(attachments))
        for index, attachment in attachments:
            if "testRunHookStartedId" in attachment:
                identity = attachment["testRunHookStartedId"]
                reference(run_hook_starts, identity, index)
                assert index < run_hook_finishes[identity][0], (label, "attachment outside run hook")
                assert "testCaseStartedId" not in attachment and "testStepId" not in attachment, label
                hook_id = run_hook_starts[identity][1]["hookId"]
                scope = hooks[hook_id][1]["type"]
                name, text = "", ""
            else:
                start = reference(case_starts, attachment["testCaseStartedId"], index)
                key = (start["id"], attachment["testStepId"])
                assert key in step_starts, (label, "attachment to unknown step")
                assert step_starts[key][0] < index < case_finishes[start["id"]][0], (label, "attachment outside case")
                case = cases[start["testCaseId"]][1]
                name = pickles[case["pickleId"]][1]["name"]
                step = test_steps[attachment["testStepId"]][1]
                if "hookId" in step:
                    scope = hooks[step["hookId"]][1]["type"]
                    text = ""
                else:
                    scope = "STEP"
                    text = pickle_steps[step["pickleStepId"]]["text"]
            attachment_links.append([scope, name, text, attachment.get("body", attachment.get("url"))])
    assert sorted(attachment_links) == sorted(expected.get("attachment_links", [])), (label, "attachment lifecycle links", attachment_links)
    if expected.get("external_attachments"):
        external = events("externalAttachment")[0][1]
        assert external["url"] == "https://example.test/evidence" and external["mediaType"] == "text/uri-list", label
        evidence = {value["body"]: value for _, value in events("attachment")}
        assert evidence["step evidence"]["fileName"] == "evidence.txt", label
        assert evidence["YWJj"]["contentEncoding"] == "BASE64", label
        assert evidence["YWJj"]["mediaType"] == "application/octet-stream", label
        assert evidence["YWJj"]["fileName"] == "evidence.bin", label
    parse_errors = events("parseError")
    assert len(parse_errors) == expected["parse_errors"], (label, "parse error envelopes")
    for _, error in parse_errors:
        assert error["source"]["uri"] in sources, (label, "parse error source")


def verify(record, expected):
    label = record["fixture"]
    assert record["summary"] == expected["summary"], (label, record["summary"])
    scenarios = [[s["name"], s["status"], [step["status"] for step in s["steps"]]] for s in record["scenarios"]]
    assert scenarios == expected["scenarios"], (label, scenarios)
    assert len(record["parse_errors"]) == expected["parse_errors"], label
    if "hook_log" in expected:
        assert record["hook_log"] == expected["hook_log"], (label, record["hook_log"])
    by_name = {scenario["name"]: scenario for scenario in record["scenarios"]}
    for name, reason in expected.get("skip_reasons", {}).items():
        assert by_name[name].get("skip_reason") == reason, (label, name, "skip reason")
    for name, index, fragments in expected.get("diagnostics", []):
        diagnostic = by_name[name]["steps"][index]["diagnostic"]
        assert all(fragment in diagnostic for fragment in fragments), (label, name, diagnostic)
    for error in record["parse_errors"]:
        assert error["uri"] == expected["source"] and error["line"] == 1, (label, error)
        assert "Feature:" in error["message"], (label, error)
    envelopes = [json.loads(line) for line in record["messages"].splitlines()]
    verify_envelopes(record, expected, envelopes)
    return {**record, "messages": normalize(envelopes)}


def main():
    expected = json.loads(Path("expected.json").read_text())
    records = [json.loads(line.removeprefix("COMPAT:")) for line in sys.stdin if line.startswith("COMPAT:")]
    assert [r["fixture"] for r in records] == list(expected), "every expected fixture must execute exactly once"
    normalized = [verify(record, expected[record["fixture"]]) for record in records]
    Path("_build/baseline.normalized.json").write_text(json.dumps(normalized, indent=2) + "\n")
    scenarios = sum(r["summary"]["total"] for r in records)
    attempts = sum(len(expected[r["fixture"]]["attempts"]) for r in records)
    assert scenarios > 0 and attempts >= scenarios, "scenario execution is required"
    print(f"Compatibility baseline: {len(records)} fixtures, {scenarios} final scenarios, {attempts} attempts verified")


if __name__ == "__main__":
    main()
