"""Mutations of actual generated execution evidence must fail closed."""
import unittest
import copy
from matrix import require_tests


class SelectionTests(unittest.TestCase):
    def test_selected_matrix_requires_every_success(self):
        from matrix import validate_selection, TARGETS
        runs = [dict(target=target, mode=mode, kind=kind, status="success",
                     tests=(4 if mode == "per-scenario" else 2) * (2 if target == "wasm-gc" else 3),
                     scenarios=4 * (2 if target == "wasm-gc" else 3))
                for mode in ["per-scenario", "per-feature"] for kind in ["wbtest", "test"] for target in TARGETS]
        validate_selection(runs, TARGETS)
        for status in ["missing", "skipped", "failure", "cancelled"]:
            changed = copy.deepcopy(runs)
            changed[0]["status"] = status
            with self.subTest(status=status), self.assertRaises(AssertionError):
                validate_selection(changed, TARGETS)
        for changed in [runs[:-1], runs + [runs[0]], []]:
            with self.assertRaises(AssertionError):
                validate_selection(changed, TARGETS)

    def test_requires_exact_positive_summary(self):
        require_tests("Total tests: 4, passed: 4, failed: 0", 4)
        for output in ("", "Total tests: 0, passed: 0, failed: 0",
                       "Total tests: 4, passed: 3, failed: 1",
                       "Total tests: 4, passed: 4, failed: 0, skipped: 1",
                       "Total tests: 4, passed: 4, failed: 0\n" * 2):
            with self.subTest(output=output), self.assertRaises(AssertionError):
                require_tests(output, 4)

    def test_actual_mixed_project_executes(self):
        from matrix import mixed_case
        result = mixed_case("per-scenario", "wbtest", targets=["native"])
        self.assertEqual([(r["tests"], r["scenarios"]) for r in result["runs"]], [(12, 12)])
        self.assertTrue(result["sync_parallel_rejected"])
        from matrix import EVIDENCE, verify_execution
        output = (EVIDENCE / "per-scenario-wbtest-native.log").read_text()
        mutations = [
            output.replace('MATRIX_FACTORY:parallel', 'MATRIX_FACTORY:sequential'),
            "\n".join(line for line in output.splitlines() if '"testCaseStarted"' not in line),
            "\n".join(line for line in output.splitlines() if '"testRunFinished"' not in line),
            "\n".join(line for line in output.splitlines() if '"testCaseFinished"' not in line),
            output.replace('"success":true', '"success":false'),
            output.replace('"status":"PASSED"', '"status":"SKIPPED"'),
            output.replace('"name":"Fresh"', '"name":"wrong scenario"'),
        ]
        for changed in mutations:
            self.assertNotEqual(output, changed)
            with self.assertRaises(AssertionError):
                verify_execution(changed, "native", "per-scenario", "wbtest")
