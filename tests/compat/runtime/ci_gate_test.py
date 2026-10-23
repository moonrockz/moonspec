"""A skipped required check cannot produce a green aggregate."""
import json
import os
from pathlib import Path
import subprocess
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[3]


class CiGateTests(unittest.TestCase):
    def test_shared_gate_selects_complete_shared_matrix(self):
        task = (ROOT / "mise-tasks/test/compat-shared").read_text()
        self.assertIn("probe.py --shared-only", task)

    def test_policy_schema_environment_is_provisioned_in_compatibility(self):
        workflow = (ROOT / ".github/workflows/ci.yml").read_text()
        category = workflow.split("  compatibility:\n", 1)[1].split("  ci-ok:", 1)[0]
        for dependency in ("PyYAML==6.0.3", "jsonschema==4.26.0", "uv==0.13.4"):
            self.assertIn(dependency, category)

    def test_compatibility_requires_every_policy_gate(self):
        import ast
        task = (ROOT / "mise-tasks/test/compat").read_text()
        line = next(line for line in task.splitlines() if line.startswith("#MISE depends="))
        selected = ast.literal_eval(line.split("=", 1)[1])
        for name in ("test:compat-contract", "test:compat-shared", "test:compat-target-policy",
                     "test:compat-policy-regeneration", "test:compat-target-matrix", "examples:multi-target"):
            self.assertIn(name, selected)

    def test_workflow_rejects_skipped_required_job(self):
        workflow = (ROOT / ".github/workflows/ci.yml").read_text()
        script = textwrap.dedent(workflow.split("  ci-ok:\n", 1)[1].split("        run: |\n", 1)[1])
        needs = {name: {"result": "success"} for name in
                 ("lint", "unit-tests", "core-tests", "examples", "site", "compatibility")}
        needs["site"]["result"] = "skipped"
        process = subprocess.run(["bash", "-c", script], cwd=ROOT,
                                 env={**os.environ, "NEEDS": json.dumps(needs)},
                                 text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        self.assertNotEqual(process.returncode, 0, process.stdout)

    def test_all_required_results_must_be_success(self):
        from ci_gate import REQUIRED, validate
        good = {name: {"result": "success"} for name in REQUIRED}
        validate(good)
        for name in REQUIRED:
            for status in ("failure", "cancelled", "skipped", "pending", None):
                changed = {key: dict(value) for key, value in good.items()}
                changed[name]["result"] = status
                with self.subTest(job=name, status=status), self.assertRaises(AssertionError):
                    validate(changed)
            missing = dict(good)
            del missing[name]
            with self.subTest(missing=name), self.assertRaises(AssertionError):
                validate(missing)
        with self.assertRaises(AssertionError):
            validate({**good, "surprise": {"result": "success"}})
        with self.assertRaises(AssertionError):
            validate({})

    def test_workflow_needs_matches_required_contract(self):
        import re
        from ci_gate import REQUIRED
        workflow = (ROOT / ".github/workflows/ci.yml").read_text()
        gate = workflow.split("  ci-ok:\n", 1)[1]
        needs = gate.split("    needs:\n", 1)[1].split("    steps:\n", 1)[0]
        self.assertEqual(set(re.findall(r"      - ([a-z-]+)", needs)), set(REQUIRED))
