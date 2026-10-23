"""Run real generated sync, sequential async and bounded async in one module."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

import verify as policy

EVIDENCE = policy.ROOT / "_build/compat-target-matrix"
TARGETS = ["wasm", "wasm-gc", "js", "native"]


def require_tests(output, count):
    summaries = re.findall(r"Total tests: (\d+), passed: (\d+), failed: (\d+)(?:, skipped: (\d+))?", output)
    assert count > 0 and len(summaries) == 1, (count, summaries)
    assert tuple(int(n or 0) for n in summaries[0]) == (count, count, 0, 0), summaries


def mixed_case(mode, kind, *, targets=TARGETS, audit=False):
    policy.EVIDENCE = EVIDENCE
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    label = mode + "-" + kind
    runs = []
    graph = None
    with tempfile.TemporaryDirectory(prefix="moonspec-mixed-") as tmp:
        path = Path(tmp)
        policy.fixture(path)
        definition = policy.DEFINITION.replace("pub fn options(", "fn common_options(")
        for factory, marker, settings in [
            ("options", "sequential", ""),
            ("sync_options", "sync", ""),
            ("parallel_options", "parallel", "  options.parallel(true)\n  options.max_concurrent(2)\n"),
        ]:
            definition += f'''///|
pub fn {factory}(sources : Array[@moonspec.FeatureSource]) -> @moonspec.RunOptions {{
  println("MATRIX_FACTORY:{marker}")
  let options = common_options(sources)
{settings}  options
}}
'''
        world = path / "lib/definitions/world.mbt"
        world.write_text(definition)
        assert definition.count("fn configure(") == 1
        source_hash = hashlib.sha256(world.read_bytes()).hexdigest()
        for suite, execution, factory in [
            ("suite", policy.POLICY["execution"], "options"),
            ("sync_suite", "sync", "sync_options"),
            ("parallel_suite", policy.POLICY["execution"], "parallel_options"),
        ]:
            directory = path / "lib" / suite
            directory.mkdir()
            config = dict(policy.POLICY, execution=execution, mode=mode, test_kind=kind,
                          shared=dict(policy.POLICY["shared"], options_factory=factory))
            (directory / "moonspec.json5").write_text(json.dumps(config))
            policy.command([policy.CLI, "gen", "tests", *policy.SOURCES, "-o", "lib/" + suite], path, label + "-generate-" + suite)
        artifacts = EVIDENCE / label
        for file in (path / "lib").rglob("*"):
            if file.is_file():
                dest = artifacts / file.relative_to(path / "lib")
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(file.read_bytes())
        for uri in policy.SOURCES:
            (path / uri).unlink()
        if audit:
            graph = policy.audit_graph(path)
            graph["wat_sha256"] = {}
            for file in (path / "_build/graph-output").rglob("*.wat"):
                dest = artifacts / "wasm-gc" / file.relative_to(path / "_build/graph-output")
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.write_bytes(file.read_bytes())
                graph["wat_sha256"][str(dest.relative_to(EVIDENCE))] = hashlib.sha256(file.read_bytes()).hexdigest()
        rejected = policy.command(["moon", "test", "lib/parallel_suite/moonspec_gen/sync", "--target", "wasm-gc"], path, label + "-parallel-sync-rejected", success=False)
        assert "ParallelNotSupported" in rejected, rejected
        assert '"testCaseStarted"' not in rejected, rejected
        for target in targets:
            entries = ["lib/sync_suite/moonspec_gen/sync", "lib/suite/moonspec_gen/" + ("sync" if target == "wasm-gc" else "async")]
            if target != "wasm-gc":
                entries.append("lib/parallel_suite/moonspec_gen/async")
            output = policy.command(["moon", "test", *entries, "--target", target], path, label + "-" + target)
            tests = (4 if mode == "per-scenario" else 2) * len(entries)
            require_tests(output, tests)
            result = verify_execution(output, target, mode, kind)
            runs.append(result)
            print(json.dumps(result), flush=True)
        assert hashlib.sha256(world.read_bytes()).hexdigest() == source_hash
    return {"runs": runs, "definition_sha256": source_hash, "sync_parallel_rejected": True, "graph": graph}


def verify_execution(output, target, mode, kind):
    suites = 2 if target == "wasm-gc" else 3
    tests_per_suite = 4 if mode == "per-scenario" else 2
    require_tests(output, suites * tests_per_suite)
    envelopes = [json.loads(line) for line in output.splitlines() if line.startswith('{"')]
    starts = [e["testCaseStarted"] for e in envelopes if "testCaseStarted" in e]
    steps = [e["testStepFinished"]["testStepResult"]["status"] for e in envelopes if "testStepFinished" in e]
    sources = [e["source"] for e in envelopes if "source" in e]
    finishes = [e["testRunFinished"] for e in envelopes if "testRunFinished" in e]
    assert len(starts) == 4 * suites, starts
    case_finishes = [e["testCaseFinished"] for e in envelopes if "testCaseFinished" in e]
    assert len(case_finishes) == len(starts), case_finishes
    assert steps == ["PASSED"] * (8 * suites), steps
    assert len(finishes) == suites * tests_per_suite and all(e["success"] for e in finishes), finishes
    assert len(sources) == suites * tests_per_suite, sources
    assert set(e["uri"] for e in sources) == set(policy.SOURCES), sources
    for source in sources:
        assert source["data"] == policy.SOURCES[source["uri"]], source
    # Generated invocations restart message IDs, so validate references within
    # each run, then require each selected scenario once per suite.
    batches = []
    for envelope in envelopes:
        if "meta" in envelope:
            batches.append([])
        assert batches, envelope
        batches[-1].append(envelope)
    names = []
    for batch in batches:
        pickles = {e["pickle"]["id"]: e["pickle"] for e in batch if "pickle" in e}
        cases = {e["testCase"]["id"]: e["testCase"] for e in batch if "testCase" in e}
        batch_starts = [e["testCaseStarted"] for e in batch if "testCaseStarted" in e]
        batch_finishes = [e["testCaseFinished"] for e in batch if "testCaseFinished" in e]
        start_ids = [e["id"] for e in batch_starts]
        finish_ids = [e["testCaseStartedId"] for e in batch_finishes]
        assert len(start_ids) == len(set(start_ids)) and sorted(start_ids) == sorted(finish_ids), batch
        for start in batch_starts:
            assert start["testCaseId"] in cases, start
            case = cases[start["testCaseId"]]
            assert case["pickleId"] in pickles, case
            names.append(pickles[case["pickleId"]]["name"])
    expected_names = ["Fresh", "Fresh <value> (value=1)", "Fresh <value> (value=2)", "Markdown"]
    assert sorted(names) == sorted(expected_names * suites), names
    markers = re.findall(r"^MATRIX_FACTORY:(\w+)$", output, re.MULTILINE)
    expected = ["sync", "sequential"] + ([] if target == "wasm-gc" else ["parallel"])
    assert sorted(markers) == sorted(expected * tests_per_suite), markers
    return dict(target=target, mode=mode, kind=kind, status="success", tests=suites * tests_per_suite,
                scenarios=len(starts), passed_steps=len(steps), factories=expected)


def validate_selection(runs, targets):
    expected = {(target, mode, kind) for target in targets
                for mode in ["per-scenario", "per-feature"] for kind in ["wbtest", "test"]}
    keys = [(r["target"], r["mode"], r["kind"]) for r in runs]
    assert len(keys) == len(set(keys)) and set(keys) == expected, (keys, expected)
    for run in runs:
        suites = 2 if run["target"] == "wasm-gc" else 3
        assert run["status"] == "success", run
        assert run["tests"] == suites * (4 if run["mode"] == "per-scenario" else 2), run
        assert run["scenarios"] == suites * 4, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", choices=TARGETS)
    args = parser.parse_args()
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    report = EVIDENCE / "report.json"
    report.unlink(missing_ok=True)
    targets = [args.target] if args.target else TARGETS
    results = [mixed_case(mode, kind, targets=targets, audit=mode == "per-scenario" and kind == "wbtest")
               for mode in ["per-scenario", "per-feature"] for kind in ["wbtest", "test"]]
    runs = [run for result in results for run in result["runs"]]
    validate_selection(runs, targets)
    sources = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard",
               "src", "schemas", "moon.mod", "moon.work", ".mise.toml", ".github/workflows/ci.yml",
               "tests/compat", "mise-tasks/test", "mise-tasks/examples"], cwd=policy.ROOT, text=True).splitlines()
    hashes = {name: hashlib.sha256((policy.ROOT / name).read_bytes()).hexdigest() for name in sorted(set(sources))}
    report.write_text(json.dumps(dict(results=results, totals=dict(runs=len(runs), tests=sum(r["tests"] for r in runs),
                      scenarios=sum(r["scenarios"] for r in runs)), source_sha256=hashes,
                      cli_sha256=hashlib.sha256(policy.CLI.read_bytes()).hexdigest()), indent=2) + "\n")


if __name__ == "__main__":
    main()
