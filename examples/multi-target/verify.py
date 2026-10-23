"""Execute the checkout example with the local CLI; no registry CLI is used."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
EXAMPLE = ROOT / "examples/multi-target"
CLI = ROOT / "_build/bin/moonspec"
EVIDENCE = ROOT / "_build/examples-multi-target"


def command(args, cwd, label):
    env = dict(os.environ, PATH=str(CLI.parent) + os.pathsep + os.environ["PATH"])
    result = subprocess.run([str(arg) for arg in args], cwd=cwd, env=env,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (EVIDENCE / (label + ".log")).write_text(result.stdout)
    if result.returncode:
        print(result.stdout)
    result.check_returncode()
    return result.stdout


def run(cwd, target, mode, suite="suite", expected=2, package=None, label=None):
    selection = (["src/suite/moonspec_gen/async", "src/sync_suite/moonspec_gen/sync"]
                 if package == "all" else [package or f"src/{suite}/moonspec_gen/{mode}"])
    output = command(["moon", "test", *selection, "--target", target],
                     cwd, label or f"{suite}-{mode}-{target}")
    summary = re.search(r"Total tests: (\d+), passed: (\d+), failed: (\d+)", output)
    assert summary and tuple(map(int, summary.groups())) == (expected, expected, 0), output
    envelopes = [json.loads(line) for line in output.splitlines() if line.startswith('{"')]
    starts = [e for e in envelopes if "testCaseStarted" in e]
    steps = [e["testStepFinished"]["testStepResult"]["status"]
             for e in envelopes if "testStepFinished" in e]
    assert len(starts) == expected, starts
    assert steps == ["PASSED"] * (5 * expected), steps
    sources = [e["source"] for e in envelopes if "source" in e]
    assert len(sources) == expected, sources
    for source in sources:
        assert source["data"] == (cwd / "features/counter.feature").read_text(), source
    return {"suite": suite, "target": target, "mode": mode,
            "tests": expected, "scenarios": len(starts), "passed_steps": len(steps)}


def snapshot(path, mtimes=False):
    return {str(file.relative_to(path)): (file.read_bytes(), file.stat().st_mtime_ns)
            if mtimes else file.read_bytes() for file in path.rglob("*") if file.is_file()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", nargs="?", choices=["wasm-gc", "wasm", "js", "native"])
    args = parser.parse_args()
    assert CLI.exists(), "Build the checkout CLI first: mise run build:cli"
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="moonspec-example-") as tmp:
        path = Path(tmp)
        shutil.copytree(EXAMPLE, path, dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns("_build", ".mooncakes", "__pycache__"))
        (path / "moon.work").write_text(f'members = ["{ROOT}", "."]\n')
        command([CLI, "gen", "tests", "features/counter.feature", "-o", "src/suite"],
                path, "generate")
        build = [CLI, "gen", "build", "features/counter.feature", "--package", "src/suite", "--apply"]
        command(build, path, "build-apply")
        assert "dev_build(" in (path / "src/suite/moonspec_gen/shared/moon.pkg").read_text(), "example needs executable regeneration rules"
        generated = path / "src/suite/moonspec_gen"
        assert snapshot(generated) == snapshot(EXAMPLE / "src/suite/moonspec_gen"), "committed output differs from local generation"
        before = snapshot(generated, mtimes=True)
        command([CLI, "gen", "tests", "features/counter.feature", "-o", "src/suite"],
                path, "generate-repeat")
        command(build, path, "build-repeat")
        assert snapshot(generated, mtimes=True) == before, "unchanged manual generation wrote files"
        targets = [args.target] if args.target else ["wasm-gc", "wasm", "js", "native"]
        runs = [run(path, target, "sync" if target == "wasm-gc" else "async")
                for target in targets]
        command([CLI, "gen", "build", "features/counter.feature", "--package", "src/sync_suite",
                 "--execution", "sync", "--apply"], path, "sync-override")
        runs.extend(run(path, target, "sync", "sync_suite") for target in targets)
        if not args.target or args.target == "native":
            runs.append(run(path, "native", "mixed", expected=4, package="all",
                            label="mixed-native"))
        if not args.target or args.target == "wasm-gc":
            feature = path / "features/counter.feature"
            feature.write_text(feature.read_text() + "\n  Scenario: Added without manual generation\n"
                               "    Given a fresh counter\n    When I increment the counter\n"
                               "    Then the counter is one\n")
            runs.append(run(path, "wasm-gc", "sync", expected=3, label="automatic-regeneration"))
    (EVIDENCE / "report.json").write_text(json.dumps({"runs": runs}, indent=2) + "\n")
    print(json.dumps({"runs": runs}))


if __name__ == "__main__":
    main()
