"""Execution proof must reject silently omitted tests and fixture runs."""
import unittest
from matrix import require_tests


class ExecutionProofTests(unittest.TestCase):
    def test_positive_execution_required(self):
        require_tests("Total tests: 1, passed: 1, failed: 0", 1)
        for output in ("", "Total tests: 0, passed: 0, failed: 0",
                       "Total tests: 1, passed: 0, failed: 0, skipped: 1",
                       "Total tests: 1, passed: 0, failed: 1"):
            with self.subTest(output=output), self.assertRaises(AssertionError):
                require_tests(output, 1)

    def test_reports_cannot_be_silently_omitted(self):
        from pathlib import Path
        import json
        from matrix import observations
        expected = json.loads(Path("expected.json").read_text())
        output = Path("_build/sync-js.jsonl").read_text()
        output = "\n".join(line for line in output.splitlines() if not line.startswith("REPORT:"))
        with self.assertRaises(AssertionError):
            observations(output, expected)
