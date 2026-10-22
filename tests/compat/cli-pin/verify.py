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
    assert "moonspec@0.11.0 gen tests" in preview, preview
    assert "--execution" not in preview, preview
    run([*args, "--moonx", "--apply"], consumer, "moonx-default-apply")
    rules = (package / "moon.pkg").read_text()
    assert command(preview) == command(rules)
    initial = (package / "input_feature_wbtest.mbt").read_text()
    assert "async test" in initial and "@moonspec.FeatureSource::File(" in initial, initial
    for apply in [False, True]:
        before = {p.name: p.read_bytes() for p in package.iterdir()}
        result = run([*args, "--moonx", "--execution", "sync", *(["--apply"] if apply else [])], consumer, "moonx-sync-" + str(apply), success=False)
        assert "0.11.0" in result and "sync" in result, result
        assert "mise run build:cli" in result and "without --moonx" in result, result
        assert before == {p.name: p.read_bytes() for p in package.iterdir()}
    empty = consumer / "empty"
    empty.mkdir()
    run([*args[:-1], "empty", "--moonx", "--execution", "sync", "--apply"], consumer, "moonx-sync-empty", success=False)
    assert not list(empty.iterdir())
    (consumer / "moonspec.json5").write_text('{ execution: "sync" }')
    run([*args, "--moonx", "--apply"], consumer, "moonx-config-sync", success=False)
    # Upgrade a canonical bad registry rule without losing unrelated content.
    unrelated = 'rule(\n  name: "other",\n  command: "echo preserved",\n)\n\n'
    bad = rules.replace(" -o $output", " --execution async -o $output")
    (package / "moon.pkg").write_text(unrelated + bad)
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

report = {"cases": 8, "published_pin": "0.11.0", "local_sync_regenerated": True, "rejection_preserves_files": True}
(EVIDENCE / "report.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report))
