# /// script
# requires-python = ">=3.10"
# dependencies = ["PyYAML==6.0.3", "jsonschema==4.26.0"]
# ///
"""Execute real target-policy output using the current local CLI."""
import argparse
import json
import os
import sys
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
EVIDENCE = ROOT / "_build/compat-target-policy"
CLI = ROOT / "_build/bin/moonspec"
POLICY = {
    "execution": {"default": "async", "targets": {"wasm-gc": "sync"}},
    "shared": {"package": "policy/consumer/definitions", "world_factory": "world", "options_factory": "options"},
}
SOURCE = "Feature: Generated shared policy\n  @keep\n  Scenario: Fresh\n    Given a fresh world\n  @keep\n  Scenario Outline: Fresh <value>\n    Given a fresh world\n    Examples:\n      | value |\n      | 1 |\n      | 2 |\n"
MARKDOWN = '`@keep`\r\n# Feature: Markdown shared policy\r\n\r\nProse "quotes" café 🌙.\r\n\r\n## Scenario: Markdown\r\n\r\n- Given a fresh world\r\n\r\nTrailing prose.\r\n'
SOURCES = {"./features/shared.feature": SOURCE, "./features/markdown.feature.md": MARKDOWN}
DEFINITION = '''///|
pub struct FixtureWorld { priv mut used : Bool }
///|
pub impl @moonspec.World for FixtureWorld with fn configure(self, setup) {
  setup.given("a fresh world", fn(_) raise {
    assert_false(self.used)
    self.used = true
  })
  setup.after_test_case(fn(_, status) raise {
    assert_true(self.used)
    assert_true(status is Passed)
  })
}
///|
pub extend FixtureWorld with @moonspec.World::{configure}
///|
pub fn world() -> FixtureWorld { { used: false } }
///|
pub fn options(sources : Array[@moonspec.FeatureSource]) -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions(sources)
  options.tag_expr("@keep")
  options.retries(1)
  options.no_color(true)
  options.add_formatter(@format.MessagesFormatter::new(), @moonspec.OutputDest::Stdout)
  options
}
'''


def command(args, cwd, label, *, success=True):
    result = subprocess.run([str(x) for x in args], cwd=cwd, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (EVIDENCE / (label + ".log")).write_text(result.stdout)
    if success and result.returncode:
        print(result.stdout)
        result.check_returncode()
    if not success:
        assert result.returncode, result.stdout
    return result.stdout


def fixture(path):
    (path / "lib/definitions").mkdir(parents=True)
    (path / "features").mkdir()
    (path / "moon.mod").write_text('name = "policy/consumer"\nversion = "0.0.1"\nsource = "lib"\nimport { "moonrockz/moonspec@0.11.0", "moonbitlang/async@0.22.4" }\n')
    (path / "moon.work").write_text(f'members = ["{ROOT}", "."]\n')
    (path / "lib/definitions/moon.pkg").write_text('import { "moonrockz/moonspec", "moonrockz/moonspec/format" }\nsupported_targets = "wasm+wasm-gc+js+native"\n')
    (path / "lib/definitions/world.mbt").write_text(DEFINITION)
    for uri, text in SOURCES.items():
        (path / uri).write_bytes(text.encode())
    (path / "moonspec.json5").write_text(json.dumps(POLICY))


def verify_run(output, target, mode, kind):
    tests = 4 if mode == "per-scenario" else 2
    summary = re.search(r"Total tests: (\d+), passed: (\d+), failed: (\d+)", output)
    assert summary and tuple(map(int, summary.groups())) == (tests, tests, 0), output
    envelopes = [json.loads(line) for line in output.splitlines() if line.startswith('{"')]
    sources = [e["source"] for e in envelopes if "source" in e]
    starts = [e["testCaseStarted"] for e in envelopes if "testCaseStarted" in e]
    steps = [e["testStepFinished"]["testStepResult"]["status"] for e in envelopes if "testStepFinished" in e]
    assert len(starts) == 4, starts
    assert steps == ["PASSED"] * 8, steps
    assert len(sources) == tests, sources
    assert set(source["uri"] for source in sources) == set(SOURCES), sources
    for source in sources:
        assert source["data"] == SOURCES[source["uri"]], source
    return {"target": target, "mode": mode, "kind": kind, "tests": tests, "scenarios": len(starts), "passed_steps": len(steps)}


def reject_missing_shared_package():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-missing-") as tmp:
        path = Path(tmp)
        fixture(path)
        config = dict(POLICY, shared=dict(POLICY["shared"], package="policy/consumer/missing"))
        (path / "moonspec.json5").write_text(json.dumps(config))
        output = command([CLI, "gen", "tests", "./features/shared.feature", "-o", "lib/suite"], path, "missing-package", success=False)
        assert "shared.package" in output, output
        assert not (path / "lib/suite").exists(), "invalid import wrote output"



def audit_graph(path):
    graph = json.loads(command(["moon", "tree", "--package", "--json"], path, "package-tree"))
    roots = [i for i, node in enumerate(graph["nodes"])
             if node["module"] == "policy/consumer" and node["rel"] == "suite/moonspec_gen/sync"]
    assert len(roots) == 1, roots
    visited = set()
    def visit(index):
        if index in visited:
            return
        visited.add(index)
        for edge in graph["edges"]:
            if edge["from"] == index:
                visit(edge["to"])
    visit(roots[0])
    names = sorted(graph["nodes"][i]["module"] + "/" + graph["nodes"][i]["rel"] for i in visited)
    assert "moonrockz/moonspec/runner" in names, names
    assert not re.search(r"moonbitlang[/._]async", "\n".join(names)), names
    plan = command(["moon", "--target-dir", "_build/graph-plan", "--dry-run", "test", "lib/suite/moonspec_gen/sync", "--target", "wasm-gc"], path, "sync-plan")
    assert "moonc" in plan and "suite/moonspec_gen/shared" in plan, plan
    assert not re.search(r"moonbitlang[/._]async", plan), plan
    command(["moon", "--target-dir", "_build/graph-output", "test", "lib/suite/moonspec_gen/sync", "--target", "wasm-gc", "--build-only", "--output-wat"], path, "sync-wat")
    wat = list((path / "_build/graph-output").rglob("*.wat"))
    assert wat, "actual emitted Wasm-GC output required"
    for file in wat:
        assert not re.search(r"moonbitlang[/._]async", file.read_text()), file
    return {"source_packages": names, "wasm_gc_outputs": len(wat), "async_runtime": "excluded"}



def reject_parent_file_collision():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-collision-") as tmp:
        path = Path(tmp)
        fixture(path)
        generated = path / "lib/suite/moonspec_gen"
        generated.mkdir(parents=True)
        (generated / "sync").write_text("user data")
        before = {str(p.relative_to(path)): p.read_bytes() for p in path.rglob("*") if p.is_file()}
        output = command([CLI, "gen", "tests", "./features/shared.feature", "-o", "lib/suite"], path, "parent-collision", success=False)
        after = {str(p.relative_to(path)): p.read_bytes() for p in path.rglob("*") if p.is_file()}
        assert before == after, "parent collision partially wrote output"
        assert "collision" in output, output



def verify_schema():
    try:
        import yaml
        from jsonschema import Draft202012Validator
    except ModuleNotFoundError:
        # The mise wrapper also works with a minimal system Python. uv reads the
        # pinned script dependencies and reuses its environment on later runs.
        os.execvp("uv", ["uv", "run", "--script", str(Path(__file__).resolve()), *sys.argv[1:]])
    schema = yaml.safe_load((ROOT / "schemas/moonspec.schema.yaml").read_text())
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)
    for config in [POLICY, {}, {"execution": "async"}, {"execution": "sync"}, dict(POLICY, execution={"default":"sync"})]:
        validator.validate(config)
    invalid = [
        {"execution": {"default": "sync"}},
        dict(POLICY, execution={}),
        dict(POLICY, execution={"default": "async"}),
        dict(POLICY, execution={"default": "sync", "targets": {"llvm": "sync"}}),
        dict(POLICY, execution={"default": "sync", "targets": {"wasm-gc": "async"}}),
        dict(POLICY, execution={"default": "sync", "targets": []}),
        dict(POLICY, execution={"default": "sync", "extra": 1}),
        dict(POLICY, shared={"package": "bad/../path", "world_factory": "world", "options_factory": "options"}),
        dict(POLICY, shared=dict(POLICY["shared"], options_factory="bad()")),
        dict(POLICY, shared=dict(POLICY["shared"], world_factory="fn")),
        dict(POLICY, shared=dict(POLICY["shared"], extra=True)),
    ]
    for config in invalid:
        assert list(validator.iter_errors(config)), config
    return {"valid": 5, "invalid": len(invalid)}



def reject_hidden_output():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-hidden-") as tmp:
        path = Path(tmp)
        fixture(path)
        output = command([CLI, "gen", "tests", "./features/shared.feature", "-o", "lib/_suite"], path, "hidden-output", success=False)
        assert "compiler-visible" in output, output
        assert not (path / "lib/_suite").exists()



def snapshot(path):
    return {str(p.relative_to(path)): p.read_bytes() for p in path.rglob("*") if p.is_file()}


def verify_plan_boundary():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-plan-") as tmp:
        path = Path(tmp)
        fixture(path)
        inputs = [CLI, "gen", "tests", *SOURCES, "-o", "lib/suite"]
        before = snapshot(path)
        preview = command(inputs + ["--preview"], path, "preview")
        assert "shared/sources.mbt" in preview and "sync/moon.pkg" in preview and "async/moon.pkg" in preview
        assert before == snapshot(path), "preview wrote output"
        build = [CLI, "gen", "build", *SOURCES, "--package", "lib/suite"]
        command(build, path, "build-preview")
        assert before == snapshot(path), "build preview wrote output"
        registry = command(build + ["--apply", "--moonx"], path, "registry-policy", success=False)
        assert "capability is unavailable" in registry and "without --moonx" in registry, registry
        assert before == snapshot(path), "unsupported registry policy wrote output"
        (path / "features/broken.feature").write_text("Feature: Broken\n Scenario Outline: Wrong\n  Given a fresh world\n  Examples:\n   | a | b |\n   | 1 |\n")
        before = snapshot(path)
        command(inputs + ["features/broken.feature"], path, "invalid-last-feature", success=False)
        assert before == snapshot(path), "invalid final feature partially wrote output"
        command(build + ["--apply"], path, "build-apply")
        generated = snapshot(path)
        command(inputs, path, "unchanged-regeneration")
        assert generated == snapshot(path), "unchanged generation is not byte-idempotent"
        source = path / "lib/suite/moonspec_gen/shared/sources.mbt"
        source.write_text(source.read_text() + "// user modification\n")
        before = snapshot(path)
        output = command(inputs, path, "modified-output", success=False)
        assert "modified generated output" in output, output
        assert before == snapshot(path), "modified generated output was overwritten"
        source.write_bytes(generated[str(source.relative_to(path))])
        config = dict(POLICY, execution="sync")
        (path / "moonspec.json5").write_text(json.dumps(config))
        before = snapshot(path)
        output = command(inputs, path, "stale-policy", success=False)
        assert "stale" in output, output
        assert before == snapshot(path), "stale tree changed before safe reconciliation"



def verify_precedence():
    results = []
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-precedence-") as tmp:
        path = Path(tmp)
        fixture(path)
        definitions = (path / "lib/definitions/world.mbt").read_bytes()
        (path / "lib/sync_suite").mkdir()
        (path / "lib/sync_suite/moonspec.json5").write_text('{"execution":"sync"}')
        for label, directory, flags, entry in [
            ("parent", "lib/async_suite", [], "async"),
            ("child", "lib/sync_suite", [], "sync"),
            ("cli", "lib/sync_suite/override", ["--execution", "async"], "async"),
        ]:
            command([CLI, "gen", "tests", *SOURCES, "-o", str(path.resolve() / directory) if label == "child" else directory, *flags], path, "precedence-" + label)
            generated = path / directory / "moonspec_gen"
            if label != "parent":
                assert not (generated / ("async" if entry == "sync" else "sync")).exists()
            output = command(["moon", "test", directory + "/moonspec_gen/" + entry, "--target", "native"], path, "precedence-" + label + "-native")
            result = verify_run(output, "native", "per-scenario", "wbtest")
            result.update(selection=label, execution=entry)
            results.append(result)
        assert (path / "lib/definitions/world.mbt").read_bytes() == definitions
    return results



def reject_nonportable_shared_package():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-nonportable-") as tmp:
        path = Path(tmp)
        fixture(path)
        package = path / "lib/definitions/moon.pkg"
        package.write_text('import { "moonrockz/moonspec", "moonrockz/moonspec/format" }\nsupported_targets = "native"\n')
        before = snapshot(path)
        output = command([CLI, "gen", "tests", *SOURCES, "-o", "lib/suite"], path, "nonportable-shared", success=False)
        assert "shared.package" in output and "wasm-gc" in output, output
        assert before == snapshot(path)



def reject_async_shared_import():
    with tempfile.TemporaryDirectory(prefix="moonspec-policy-async-import-") as tmp:
        path = Path(tmp)
        fixture(path)
        (path / "lib/definitions/moon.pkg").write_text('import { "moonrockz/moonspec/async" @moonspec, "moonrockz/moonspec/format" }\n')
        before = snapshot(path)
        output = command([CLI, "gen", "tests", *SOURCES, "-o", "lib/suite"], path, "async-shared-import", success=False)
        assert "shared.package" in output and "async" in output, output
        assert before == snapshot(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--schema-only", action="store_true")
    args = parser.parse_args()
    schema = verify_schema()
    if args.schema_only:
        print(json.dumps(schema))
        return
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    report = EVIDENCE / "report.json"
    report.unlink(missing_ok=True)
    reject_missing_shared_package()
    reject_parent_file_collision()
    reject_hidden_output()
    verify_plan_boundary()
    reject_nonportable_shared_package()
    reject_async_shared_import()
    precedence = verify_precedence()
    results = []
    graph = None
    for mode in ["per-scenario", "per-feature"]:
        for kind in ["wbtest", "test"]:
            with tempfile.TemporaryDirectory(prefix="moonspec-target-policy-") as tmp:
                path = Path(tmp)
                fixture(path)
                config = dict(POLICY, mode=mode, test_kind=kind)
                (path / "moonspec.json5").write_text(json.dumps(config))
                label = mode + "-" + kind
                command([CLI, "gen", "tests", *SOURCES, "-o", "lib/suite"], path, label + "-generate")
                generated = path / "lib/suite/moonspec_gen"
                for package in ["shared", "sync", "async"]:
                    assert (generated / package / "moon.pkg").exists()
                artifact = EVIDENCE / label
                artifact.mkdir(exist_ok=True)
                for file in generated.rglob("*"):
                    if file.is_file():
                        destination = artifact / file.relative_to(generated)
                        destination.parent.mkdir(parents=True, exist_ok=True)
                        destination.write_bytes(file.read_bytes())
                for uri in SOURCES:
                    (path / uri).unlink()
                for entry, target in [("async", "native"), ("sync", "wasm-gc")]:
                    output = command(["moon", "test", f"lib/suite/moonspec_gen/{entry}", "--target", target], path, label + "-" + target)
                    results.append(verify_run(output, target, mode, kind))
                if graph is None:
                    graph = audit_graph(path)
                    unsupported = command(["moon", "check", "lib/suite/moonspec_gen/async", "--target", "wasm-gc"], path, "unsupported-async-target", success=False)
                    assert "does not support target backend" in unsupported and "wasm-gc" in unsupported, unsupported
    report.write_text(json.dumps({"runs": results, "graph": graph, "schema": schema, "precedence": precedence}, indent=2) + "\n")
    print(json.dumps(results))



if __name__ == "__main__":
    main()
