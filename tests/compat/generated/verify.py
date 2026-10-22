"""Execute actual CLI-generated tests in isolated downstream modules.

Run through mise run test:compat-generated. Logs, generated source and report.json
are written to _build/compat-generated. Temporary consumer modules resolve the
local framework through moon.work and are removed after each run. Generated test
source is never patched by this harness.
"""
import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
FIXTURE = Path(__file__).resolve().parent
EVIDENCE = ROOT / "_build/compat-generated"
NAMES = ["Regular", "Outline (value=2)", "Outline (value=3)"]
MARKDOWN_NAME = 'Markdown "quotes" \\{literal} café 🌙'
VALUES = dict(zip(NAMES + ["Opt in", MARKDOWN_NAME], ["1", "2", "3", "4", "5"]))


def run(command, cwd, label):
    result = subprocess.run(
        command, cwd=cwd, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    (EVIDENCE / (label + ".log")).write_text(result.stdout)
    if result.returncode:
        print(result.stdout)
    result.check_returncode()
    return result.stdout


def verify(output, *, tests, sources, names, step_count, skipped_steps=0):
    summary = re.search(
        r"Total tests: (\d+), passed: (\d+), failed: (\d+)(?:, skipped: (\d+))?",
        output,
    )
    assert summary, output
    actual = tuple(int(value or 0) for value in summary.groups())
    assert actual == (tests, tests, 0, 0), actual
    envelopes = [
        json.loads(line) for line in output.splitlines() if line.startswith('{"')
    ]
    starts = [e["testCaseStarted"] for e in envelopes if "testCaseStarted" in e]
    assert len(starts) == len(names) > 0, (len(starts), names)
    # IDs restart for each generated test's independent run. Verify within runs.
    runs = []
    for envelope in envelopes:
        if "meta" in envelope:
            runs.append([])
        assert runs, envelope
        runs[-1].append(envelope)
    selected = []
    steps = []
    for batch in runs:
        emitted = {
            e["source"]["uri"]: e["source"]["data"]
            for e in batch if "source" in e
        }
        assert len(emitted) == 1, emitted
        for uri, content in emitted.items():
            assert content == sources[uri], (uri, "original complete source")
        pickles = {e["pickle"]["id"]: e["pickle"] for e in batch if "pickle" in e}
        cases = {
            e["testCase"]["id"]: e["testCase"] for e in batch if "testCase" in e
        }
        batch_steps = []
        for envelope in batch:
            if "testCaseStarted" in envelope:
                case = cases[envelope["testCaseStarted"]["testCaseId"]]
                pickle = pickles[case["pickleId"]]
                selected.append(pickle["name"])
                assert [step["text"] for step in pickle["steps"]] == [
                    "a working fixture", "the value is " + VALUES[pickle["name"]],
                    "the value is positive",
                ], pickle
            if "testStepFinished" in envelope:
                batch_steps.append(
                    envelope["testStepFinished"]["testStepResult"]["status"]
                )
        steps.extend(batch_steps)
        finishes = [e["testRunFinished"] for e in batch if "testRunFinished" in e]
        # Existing Messages semantics mark a run with skipped steps unsuccessful,
        # although run_or_fail correctly permits skips and the Moon test passes.
        assert len(finishes) == 1, finishes
        assert finishes[0]["success"] == ("SKIPPED" not in batch_steps), finishes
    assert sorted(selected) == sorted(names), selected
    assert steps.count("PASSED") == step_count, steps
    assert steps.count("SKIPPED") == skipped_steps, steps
    assert len(steps) == step_count + skipped_steps, steps
    return {
        "tests": tests, "passed": tests, "failed": 0,
        "scenarios": len(selected), "passed_steps": step_count,
        "skipped_steps": skipped_steps,
    }


def consumer_case(mode, kind, *, execution="sync"):
    label = f"{execution}-{mode}-{kind}"
    sources = {
        "./features/" + name: (FIXTURE / "features" / name).read_bytes().decode()
        for name in ["scenarios.feature", "markdown.feature.md"]
    }
    expected_sources = {
        uri if execution == "sync" else uri.removeprefix("./"): text
        for uri, text in sources.items()
    }
    results = []
    with tempfile.TemporaryDirectory(prefix="moonspec-generated-") as tmp:
        consumer = Path(tmp)
        (consumer / "src").mkdir()
        (consumer / "features").mkdir()
        imports = '"moonrockz/moonspec@0.11.0"'
        facade = '"moonrockz/moonspec"'
        test_imports = '"moonrockz/moonspec/format"'
        targets = "wasm+wasm-gc+js+native"
        if execution == "async":
            imports += ', "moonbitlang/async@0.22.4"'
            facade = '"moonrockz/moonspec/async" @moonspec'
            test_imports += ', "moonbitlang/async"'
            targets = "wasm+js+native"
        (consumer / "moon.mod").write_text(
            'name = "moonspec-compat/generated"\nversion = "0.0.1"\n'
            f'import {{ {imports} }}\nsource = "src"\n'
        )
        (consumer / "moon.work").write_text(f'members = ["{ROOT}", "."]\n')
        (consumer / "src/moon.pkg").write_text(
            f'import {{ {facade} }}\n'
            f'import {{ {test_imports} }} for "{kind}"\n'
            f'supported_targets = "{targets}"\n'
        )
        (consumer / "src/world.mbt").write_text(
            (FIXTURE / "consumer/world.mbt").read_text()
        )
        # Alternate config selection and CLI override. Async omits execution.
        config = {
            "world": "FixtureWorld" if kind == "wbtest" else "@generated.FixtureWorld",
            "mode": mode, "test_kind": kind, "no_color": True,
            "formatters": [{"type": "messages", "output": "stdout"}],
        }
        flags = []
        if execution == "sync":
            config["execution"] = "sync" if kind == "wbtest" else "async"
            if kind == "test":
                flags = ["--execution", "sync"]
        (consumer / "moonspec.json5").write_text(json.dumps(config))
        artifact_dir = EVIDENCE / label
        artifact_dir.mkdir(exist_ok=True)
        for uri, source in sources.items():
            (consumer / uri).write_bytes(source.encode())
            stem = Path(uri).name.replace(".feature.md", "_markdown")
            stem = stem.replace(".feature", "_gherkin")
            output_path = consumer / f"src/{stem}_{kind}.mbt"
            run(
                [str(ROOT / "_build/bin/moonspec"), "gen", "tests", uri,
                 "-o", str(output_path)] + flags,
                consumer, label + "-generate-" + stem,
            )
            generated = output_path.read_text()
            (artifact_dir / output_path.name).write_text(generated)
            skip_count = 1 if mode == "per-scenario" or uri.endswith(".md") else 0
            assert generated.count("#skip(") == skip_count, generated
            assert "options.no_color(true)" in generated, generated
            assert ("async test" in generated) == (execution == "async"), generated
            assert ("FeatureSource::Text" in generated) == (execution == "sync"), generated
        if execution == "sync":
            # Remove inputs before ANY downstream build or execution.
            for uri in sources:
                (consumer / uri).unlink()
            assert not list((consumer / "features").iterdir())
        for target in (["wasm-gc", "js"] if execution == "sync" else ["js"]):
            for include_skipped in [False, True]:
                suffix = target + ("-included" if include_skipped else "-default")
                command = ["moon", "test", "src", "--target", target]
                if include_skipped:
                    command.append("--include-skipped")
                output = run(command, consumer, label + "-" + suffix)
                if mode == "per-feature":
                    tests = 2 if include_skipped else 1
                    names = NAMES + ["Opt in"]
                    # --include-skipped enables the attributed Markdown test;
                    # nested @skip scenarios retain runtime skip semantics.
                    if include_skipped:
                        names += [MARKDOWN_NAME]
                    passed_steps = 12 if include_skipped else 9
                    skipped_steps = 3
                else:
                    tests = 5 if include_skipped else 3
                    names = NAMES + ["Opt in", MARKDOWN_NAME] if include_skipped else NAMES
                    passed_steps = 15 if include_skipped else 9
                    skipped_steps = 0
                result = verify(
                    output, tests=tests, sources=expected_sources, names=names,
                    step_count=passed_steps, skipped_steps=skipped_steps,
                )
                result.update(
                    execution=execution, mode=mode, kind=kind, target=target,
                    include_skipped=include_skipped,
                    removed_sources=execution == "sync",
                    attributed_tests_omitted=(0 if include_skipped else
                                              1 if mode == "per-feature" else 2),
                )
                results.append(result)
                print(json.dumps(result))
            if execution == "sync":
                # A fresh plan exposes all selected source dependency edges,
                # including the generated test driver, even with a warm cache.
                plan = run(
                    ["moon", "--target-dir", str(consumer / ("graph-" + target)),
                     "--dry-run", "test", "src", "--target", target],
                    consumer, label + "-" + target + "-graph",
                )
                assert "moonbitlang/async" not in plan, plan
                assert "moonbitlang.async" not in plan, plan
                assert "moonrockz/moonspec/runner" in plan, plan
                assert str(ROOT / "src/runner") in plan, plan
                assert "moonrockz/moonspec/core" in plan, plan
            if mode == "per-scenario":
                output = run(
                    ["moon", "test", "src", "--target", target,
                     "--filter", "*Outline*value=2*"],
                    consumer, label + "-" + target + "-filtered",
                )
                result = verify(
                    output, tests=1, sources=expected_sources,
                    names=["Outline (value=2)"], step_count=3,
                )
                result.update(
                    execution=execution, mode=mode, kind=kind, target=target,
                    filter="*Outline*value=2*",
                )
                results.append(result)
                print(json.dumps(result))
    return results


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    report = EVIDENCE / "report.json"
    report.unlink(missing_ok=True)
    results = []
    for mode in ["per-scenario", "per-feature"]:
        for kind in ["wbtest", "test"]:
            results.extend(consumer_case(mode, kind))
    results.extend(consumer_case("per-scenario", "wbtest", execution="async"))
    report.write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
