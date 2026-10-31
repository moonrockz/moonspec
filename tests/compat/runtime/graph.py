"""Audit the actual package graph, selected build and emitted Wasm-GC code."""
import json
from pathlib import Path
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def reject_async_runtime(text):
    assert not re.search(r"moonbitlang[/._]async", text), "async runtime reached sync consumer"


def reachable_sync(graph):
    nodes = graph["nodes"]
    roots = [i for i, node in enumerate(nodes)
             if node["module"] == "moonrockz/moonspec" and node["rel"] == ""]
    assert len(roots) == 1, "public root must exist exactly once"
    visited = set()

    def visit(index):
        if index in visited:
            return
        visited.add(index)
        for edge in graph["edges"]:
            if edge["from"] == index and "source" in edge["kinds"]:
                visit(edge["to"])

    visit(roots[0])
    names = sorted(nodes[i]["module"] + ("/" + nodes[i]["rel"] if nodes[i]["rel"] else "") for i in visited)
    reject_async_runtime("\n".join(names))
    return names


def command(args, label, *, success=True):
    process = subprocess.run(args, cwd=HERE, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (HERE / "_build" / (label + ".log")).write_text(process.stdout)
    if success:
        if process.returncode:
            print(process.stdout)
        process.check_returncode()
    else:
        assert process.returncode != 0, "optional async unexpectedly available on wasm-gc"
    return process.stdout


def main():
    (HERE / "_build").mkdir(exist_ok=True)
    graph = json.loads(command(["moon", "tree", "--package", "--json"], "package-tree"))
    names = reachable_sync(graph)
    assert "moonrockz/moonspec/runner" in names
    (HERE / "_build/root-graph.json").write_text(json.dumps(names, indent=2) + "\n")
    plan = command(["moon", "--target-dir", "_build/graph-build", "--dry-run", "test", "--target", "wasm-gc", "src/sync"], "sync-build-plan")
    reject_async_runtime(plan)
    assert "moonspec" in plan and "moonc" in plan, "actual sync build plan required"
    command(["moon", "--target-dir", "_build/graph-output", "test", "--build-only", "--output-wat", "--target", "wasm-gc", "src/sync"], "sync-wat")
    files = list((HERE / "_build/graph-output/wasm-gc/debug/test/moonspec-compat/runtime/sync").glob("*.wat"))
    assert files, "emitted Wasm-GC output required"
    imports = []
    for path in files:
        wat = path.read_text()
        reject_async_runtime(wat)
        imports.extend(re.findall(r'\(import "([^"]+)" "([^"]+)"', wat))
    unsupported = command(["moon", "check", "--target", "wasm-gc", "src/unsupported"], "async-unsupported", success=False)
    assert "Selected backend 'wasm-gc' is incompatible with the dependency graph" in unsupported
    # Moon 0.1.20261028 (MoonBit 0.10.18) words this as "whose active dependency graph supports".
    assert "requires 'moonrockz/moonspec/async' whose active dependency graph supports" in unsupported
    report = {"source_packages": len(names), "wasm_gc_files": [str(p.relative_to(HERE)) for p in files],
              "host_imports": sorted(set(imports)), "async_wasm_gc": "unavailable as required"}
    (HERE / "_build/graph-report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report))


if __name__ == "__main__":
    main()
