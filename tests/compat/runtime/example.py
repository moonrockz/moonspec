"""Regenerate the documented sync example and require actual target execution."""
import argparse
import json
from pathlib import Path
import subprocess
import time
from matrix import require_tests

ROOT = Path(__file__).resolve().parents[3]
EXAMPLE = ROOT / "examples/sync-wasm"
EVIDENCE = ROOT / "_build/compat-example"


def run(command, label):
    process = subprocess.run(command, cwd=EXAMPLE, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (EVIDENCE / (label + ".log")).write_text(process.stdout)
    if process.returncode:
        print(process.stdout)
    process.check_returncode()
    return process.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("target", nargs="?", choices=["wasm", "wasm-gc", "js", "native"])
    args = parser.parse_args()
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    generated = EXAMPLE / "src/calculator_feature_wbtest.mbt"
    before = generated.read_bytes()
    run(["../../_build/bin/moonspec", "gen", "tests", "features/calculator.feature",
         "-w", "CalculatorWorld", "-o", "src", "--execution", "sync"], "generate")
    run(["moon", "fmt"], "format-generated")
    assert generated.read_bytes() == before, "regeneration must preserve committed source, URI and hash"
    report = []
    for target in ([args.target] if args.target else ["wasm", "wasm-gc", "js", "native"]):
        started = time.monotonic()
        output = run(["moon", "test", "--target", target, "-p", "example/sync-wasm"], target)
        require_tests(output, 3)
        report.append({"target": target, "tests": 3, "seconds": round(time.monotonic() - started, 3)})
    (EVIDENCE / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
