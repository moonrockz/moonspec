"""Execute public consumers and retain comparable, identity-aware observations."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time

from verify import verify

HERE = Path(__file__).resolve().parent
TARGETS = {"sync": ["wasm", "wasm-gc", "js", "native"],
           "async": ["wasm", "js", "native"],
           "parallel": ["wasm", "js", "native"]}


def require_tests(output, count):
    summaries = re.findall(r"Total tests: (\d+), passed: (\d+), failed: (\d+)(?:, skipped: (\d+))?", output)
    assert len(summaries) == 1, ("missing or duplicate test summary", output[-1500:])
    assert tuple(int(n or 0) for n in summaries[0]) == (count, count, 0, 0), summaries
    assert count > 0


def observations(output, expected):
    records = [json.loads(line.removeprefix("COMPAT:"))
               for line in output.splitlines() if line.startswith("COMPAT:")]
    assert [r["fixture"] for r in records] == list(expected), "every fixture executes exactly once"
    reports = [json.loads(line.removeprefix("REPORT:"))
               for line in output.splitlines() if line.startswith("REPORT:")]
    assert [r["fixture"] for r in reports] == list(expected), "every run_or_fail case executes exactly once"
    return {"records": [verify(record, expected[record["fixture"]]) for record in records], "reports": reports}


def execute(mode, target):
    started = time.monotonic()
    process = subprocess.run(["moon", "test", "--target", target, "src/" + mode],
                             cwd=HERE, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log = HERE / "_build" / f"{mode}-{target}.jsonl"
    log.write_text(process.stdout)
    if process.returncode:
        print(process.stdout)
    process.check_returncode()
    (HERE / "_build/baseline.jsonl").write_text(process.stdout)
    require_tests(process.stdout, 6 if mode == "sync" else 5)
    expected = json.loads((HERE / "expected.json").read_text())
    records = observations(process.stdout, expected)
    (HERE / "_build" / f"{mode}-{target}.normalized.json").write_text(json.dumps(records, indent=2) + "\n")
    scenarios = sum(r["summary"]["total"] for r in records["records"])
    attempts = sum(len(e["attempts"]) for e in expected.values())
    assert scenarios > 0 and attempts >= scenarios
    evidence = {"mode": mode, "target": target, "tests": 6 if mode == "sync" else 5, "fixtures": len(records["records"]),
                "scenarios": scenarios, "attempts": attempts, "seconds": round(time.monotonic() - started, 3)}
    print(json.dumps(evidence), flush=True)
    return records, evidence


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=list(TARGETS))
    parser.add_argument("--target", choices=TARGETS["sync"])
    args = parser.parse_args()
    (HERE / "_build").mkdir(exist_ok=True)
    baseline = None
    report = []
    for mode in ([args.mode] if args.mode else TARGETS):
        for target in ([args.target] if args.target else TARGETS[mode]):
            assert target in TARGETS[mode], (mode, target, "unsupported selection")
            records, evidence = execute(mode, target)
            if baseline is None:
                baseline = records
            assert records == baseline, (mode, target, "results and normalized envelopes differ")
            report.append(evidence)
    (HERE / "_build/matrix-report.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
