"""Execute a deny-filesystem host and prove the policy is active."""
import json
from pathlib import Path
import subprocess
from matrix import require_tests

HERE = Path(__file__).resolve().parent


def main():
    report = []
    for mode, target, count in (("policy", "wasm", 2), ("policy", "wasm-gc", 2), ("async", "wasm", 1)):
        package = "src/policy" if mode == "policy" else "src/async/portable_test.mbt"
        process = subprocess.run(["moon", "test", "--target", target, "--wasm-policy", "deny-fs.json", package],
                                 cwd=HERE, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (HERE / "_build" / f"no-fs-{mode}-{target}.log").write_text(process.stdout)
        if process.returncode:
            print(process.stdout)
        process.check_returncode()
        require_tests(process.stdout, count)
        if mode == "policy":
            assert 'Sandbox policy blocked file read: "fixtures/passing.feature"' in process.stdout, process.stdout
        report.append({"mode": mode, "target": target, "tests": count, "policy": "deny all filesystem"})
    (HERE / "_build/host-report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
