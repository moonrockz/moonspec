"""Exercise actual local CLI rule rendering, rejection, and regeneration.

Run with mise run test:compat-cli-pin. Published CLI repro is a separate,
temporary file-based mise task so this gate needs no registry connection.
"""
import json
import os
from pathlib import Path
import shlex
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / "_build/bin/moonspec"
EVIDENCE = ROOT / "_build/compat-cli-pin"
EVIDENCE.mkdir(parents=True, exist_ok=True)


def run(args, cwd, label, *, success=True, env=None):
    result = subprocess.run(
        [str(arg) for arg in args], cwd=cwd, env=env, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
    )
    (EVIDENCE / (label + ".log")).write_text(result.stdout)
    assert (result.returncode == 0) == success, result.stdout
    return result.stdout


def command(rules):
    line = next(line for line in rules.splitlines() if 'command: "' in line)
    return line.split('command: "', 1)[1].removesuffix('",')


def regenerate(rules, cwd, label):
    argv = shlex.split(command(rules).replace("$input", "input.feature").replace("$output", "regenerated.mbt"))
    env = dict(os.environ, PATH=str(CLI.parent) + os.pathsep + os.environ["PATH"])
    run(argv, cwd, label, env=env)
    return (cwd / "regenerated.mbt").read_text()


with tempfile.TemporaryDirectory(prefix="moonspec-cli-pin-") as tmp:
    consumer = Path(tmp)
    (consumer / "input.feature").write_text("Feature: Pin\n  Scenario: A\n    Given a user\n")
    package = consumer / "src"
    package.mkdir()
    args = [CLI, "gen", "build", "input.feature", "-w", "MyWorld", "--package", "src"]
    preview = run([*args, "--moonx"], consumer, "moonx-default-preview")
    assert "moonspec/cmd/moonspec@0.12.0 gen tests" in preview, preview
    assert "--execution async" in preview, preview
    run([*args, "--moonx", "--apply"], consumer, "moonx-default-apply")
    rules = (package / "moon.pkg").read_text()
    assert command(preview) == command(rules)
    initial = (package / "input_feature_wbtest.mbt").read_text()
    assert "async test" in initial and "@moonspec.FeatureSource::File(" in initial, initial
    # From 0.12.0 the registry pin supports explicit sync selection.
    sync_preview = run([*args, "--moonx", "--execution", "sync"], consumer, "moonx-sync-preview")
    assert "moonspec@0.12.0 gen tests" in sync_preview and "--execution sync" in sync_preview, sync_preview
    assert (package / "moon.pkg").read_text() == rules, "a preview must not write"
    empty = consumer / "empty"
    empty.mkdir()
    run([*args[:-1], "empty", "--moonx", "--execution", "sync", "--apply"], consumer, "moonx-sync-empty")
    empty_rules = (empty / "moon.pkg").read_text()
    assert "moonspec@0.12.0 gen tests" in empty_rules and "--execution sync" in empty_rules, empty_rules
    (consumer / "moonspec.json5").write_text('{ execution: "sync" }')
    run([*args, "--moonx", "--apply"], consumer, "moonx-config-sync")
    rules = (package / "moon.pkg").read_text()
    assert "moonspec@0.12.0 gen tests" in rules and "--execution sync" in rules, rules
    assert "--execution async" not in rules, rules
    # Upgrade a canonical bad registry rule without losing unrelated content.
    unrelated = 'rule(\n  name: "other",\n  command: "echo preserved",\n)\n\n'
    registry = rules.replace("--execution sync", "--execution async")
    (package / "moon.pkg").write_text(unrelated + registry)
    (package / "input_feature_wbtest.mbt").unlink()
    run([*args, "--apply"], consumer, "installed-sync-apply")
    sync_rules = (package / "moon.pkg").read_text()
    assert sync_rules.startswith(unrelated)
    assert 'command: "moonspec gen tests' in sync_rules
    assert "moonx" not in sync_rules and "--execution sync" in sync_rules
    generated = (package / "input_feature_wbtest.mbt").read_text()
    assert "@moonspec.run_or_fail_sync(" in generated and "async test" not in generated
    # Select the moonspec command, leaving the unrelated rule intact.
    selected = sync_rules[len(unrelated):]
    regenerated = regenerate(selected, consumer, "installed-sync-regenerated")
    assert "@moonspec.run_or_fail_sync(" in regenerated and "async test" not in regenerated

report = {"cases": 7, "published_pin": "0.12.0", "local_sync_regenerated": True, "moonx_sync": True}
(EVIDENCE / "report.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report))
