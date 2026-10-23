"""Exercise safe regeneration with the current native CLI and real Moon builds."""
import json
import os
import re
import tempfile
import subprocess
import time
from pathlib import Path
import verify as policy

policy.EVIDENCE = policy.ROOT / '_build/compat-policy-regeneration'
policy.EVIDENCE.mkdir(parents=True, exist_ok=True)

RUNS = []
command = policy.command


def recorded_command(args, cwd, label, *, success=True):
    output = command(args, cwd, label, success=success)
    if str(args[0]) == 'moon' and 'test' in args and success:
        summary = re.search(r'Total tests: (\d+), passed: (\d+), failed: (\d+)', output)
        assert summary, output
        total, passed, failed = map(int, summary.groups())
        envelopes = [json.loads(line) for line in output.splitlines() if line.startswith('{"')]
        scenarios = sum('testCaseStarted' in e for e in envelopes)
        statuses = [e['testStepFinished']['testStepResult']['status'] for e in envelopes if 'testStepFinished' in e]
        assert total > 0 and total == passed and failed == 0 and scenarios > 0, output
        assert statuses and set(statuses) == {'PASSED'}, statuses
        RUNS.append(dict(label=label, tests=total, scenarios=scenarios, steps=len(statuses)))
    return output


policy.command = recorded_command
os.environ['PATH'] = str(policy.CLI.parent) + os.pathsep + os.environ['PATH']


def test_mode_change():
    with tempfile.TemporaryDirectory(prefix='moonspec-regenerate-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = [policy.CLI, 'gen', 'tests', *policy.SOURCES, '-o', 'lib/suite']
        policy.command(args, path, 'initial')
        config = dict(policy.POLICY, execution='sync')
        (path / 'moonspec.json5').write_text(json.dumps(config))
        policy.command(args, path, 'async-to-sync')
        generated = path / 'lib/suite/moonspec_gen'
        assert not list((generated / 'async').glob('*')), 'unchanged stale async outputs remain'
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/sync', '--target', 'native'], path, 'sync-executed')
        return policy.verify_run(output, 'native', 'per-scenario', 'wbtest')


def test_concurrent_generation():
    with tempfile.TemporaryDirectory(prefix='moonspec-concurrent-generation-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = [policy.CLI, 'gen', 'build', *policy.SOURCES, '--package', 'lib/suite', '--apply']
        policy.command(args, path, 'concurrent-initial')
        source = path / 'features/shared.feature'
        source.write_text(source.read_text() + '  @keep\n  Scenario: Concurrent regeneration\n    Given a fresh world\n')
        before = policy.snapshot(path)
        lock = path / '.moonspec-generation.lock'
        lock.mkdir()
        process = subprocess.Popen([str(x) for x in args], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        try:
            time.sleep(.15)
            assert process.poll() is None, 'generation did not wait for another writer'
            assert before == policy.snapshot(path), 'queued generation wrote before acquiring ownership'
        finally:
            lock.rmdir()
            output, _ = process.communicate(timeout=15)
        assert process.returncode == 0, output
        generated = path / 'lib/suite/moonspec_gen/shared/sources.mbt'
        assert 'Concurrent regeneration' in generated.read_text()
        # Both automatic package commands execute concurrently on the pinned Moon.
        # A shared CLI guard must also cover validation and manifest publication.
        writers = [subprocess.Popen([str(x) for x in [*args, '--refresh-output', 'lib/suite/moonspec_gen/' + ('shared/sources.mbt' if i % 2 else 'async/shared_feature_wbtest.mbt')]], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True) for i in range(8)]
        for writer in writers:
            output, _ = writer.communicate(timeout=15)
            assert writer.returncode == 0, output
        assert not lock.exists(), 'generation leaked its writer guard'
        policy.command(args, path, 'concurrent-idempotent')


def test_automatic_generation_cli_capability():
    policy.command(['moon', 'build', '--target', 'js', 'src/cmd/moonspec'], policy.ROOT, 'javascript-cli-build')
    cli = policy.ROOT / '_build/js/debug/build/cmd/moonspec/moonspec.js'
    # cli.run expects one executable prefix; Node supplies two without this adapter.
    node_cli = ['node', '--input-type=module', '--eval', f'process.argv.splice(1,1); await import({json.dumps(cli.as_uri())});', str(cli)]
    with tempfile.TemporaryDirectory(prefix='moonspec-cli-generation-capability-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = ['gen', 'tests', *policy.SOURCES, '-o', 'lib/suite']
        policy.command([policy.CLI, *args], path, 'capability-initial')
        before = policy.snapshot(path)
        output = policy.command([*node_cli, 'gen', 'build', *policy.SOURCES, '--package', 'lib/suite', '--apply', '--refresh-output', 'lib/suite/moonspec_gen/shared/sources.mbt'], path, 'javascript-automatic-rejected', success=False)
        assert 'automatic shared regeneration requires the local native moonspec CLI' in output, output
        assert before == policy.snapshot(path), 'unsupported automatic CLI wrote files'
        policy.command([*node_cli, *args, '--preview'], path, 'javascript-preview')
        policy.command([*node_cli, *args], path, 'javascript-manual-generation')
        assert before == policy.snapshot(path), 'manual generation changed compatible output'


def test_build_rule():
    with tempfile.TemporaryDirectory(prefix='moonspec-build-regenerate-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = [policy.CLI, 'gen', 'build', *policy.SOURCES, '--package', 'lib/suite', '--apply']
        policy.command(args, path, 'build-initial')
        pkg = path / 'lib/suite/moonspec_gen/shared/moon.pkg'
        assert 'dev_build(' in pkg.read_text(), 'gen build did not emit executable regeneration'
        assert '--refresh-output' in pkg.read_text() and 'touch $output' not in pkg.read_text(), 'build refresh needs the portable CLI'
        before = policy.snapshot(path)
        mtimes = {str(f): f.stat().st_mtime_ns for f in (path / 'lib/suite/moonspec_gen').rglob('*') if f.is_file()}
        policy.command(args, path, 'build-repeat')
        assert mtimes == {str(f): f.stat().st_mtime_ns for f in (path / 'lib/suite/moonspec_gen').rglob('*') if f.is_file()}, 'unchanged regeneration rewrites outputs'
        assert before == policy.snapshot(path), 'unchanged build is not byte-idempotent'
        os.environ['PATH'] = str(policy.CLI.parent) + os.pathsep + os.environ['PATH']
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'moon-initial')
        policy.verify_run(output, 'native', 'per-scenario', 'wbtest')
        source = path / 'features/shared.feature'
        source.write_text(source.read_text() + '  @keep\n  Scenario: Regenerated\n    Given a fresh world\n')
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'moon-regenerated')
        assert 'Total tests: 5, passed: 5, failed: 0' in output, output
        starts = [line for line in output.splitlines() if line.startswith('{"testCaseStarted"')]
        assert len(starts) == 5, output
        assert 'Regenerated' in (pkg.parent / 'sources.mbt').read_text()
        policy.command([policy.CLI, 'gen', 'tests', *policy.SOURCES, '-o', 'lib/suite', '--test-kind', 'test'], path, 'test-kind-change')
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'test-kind-executed')
        assert 'Total tests: 5, passed: 5, failed: 0' in output, output
        assert not list((pkg.parent.parent / 'async').glob('*_wbtest.mbt'))
        assert len(list((pkg.parent.parent / 'async').glob('*_test.mbt'))) == 2
        policy.command([policy.CLI, 'gen', 'tests', *policy.SOURCES, '-o', 'lib/suite', '--mode', 'per-feature', '--no-color'], path, 'group-change')
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'group-change-executed')
        assert 'Total tests: 2, passed: 2, failed: 0' in output, output
        assert len([line for line in output.splitlines() if line.startswith('{"testCaseStarted"')]) == 5, output


def test_malformed_ownership():
    with tempfile.TemporaryDirectory(prefix='moonspec-ownership-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = [policy.CLI, 'gen', 'tests', *policy.SOURCES, '-o', 'lib/suite']
        policy.command(args, path, 'ownership-initial')
        manifest = path / 'lib/suite/moonspec_gen/manifest.json'
        original = manifest.read_text()
        malformed = {
            'duplicate-key': original.replace('"generator":', '"generator":"unknown","generator":'),
            'invalid-json': '{',
            'unknown-generator': original.replace('moonspec-shared-v1', 'unowned-v1'),
            'duplicate-output': original.replace('"path": "sync/moon.pkg"', '"path": "shared/moon.pkg"'),
            'escaping-path': original.replace('"path": "shared/sources.mbt"', '"path": "../escape.mbt"'),
            'missing-marker': original.replace('// Generated by moonspec shared codegen. DO NOT EDIT.', '// user file'),
            'unknown-field': original.replace('"generator":', '"unknown": 1,\n  "generator":'),
        }
        for label, text in malformed.items():
            manifest.write_text(text)
            before = policy.snapshot(path)
            output = policy.command(args, path, 'ownership-' + label, success=False)
            assert 'ownership' in output, output
            assert before == policy.snapshot(path)



def test_targets_and_preservation():
    with tempfile.TemporaryDirectory(prefix='moonspec-policy-targets-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        suite = path / 'lib/suite'
        suite.mkdir()
        user_pkg = 'import { "moonrockz/moonspec" }\noptions(warn_list: "-1")\nrule(name: "unrelated", command: "echo preserved")\n'
        (suite / 'moon.pkg').write_text(user_pkg)
        (suite / 'user.mbt').write_text('// preserved user code\n')
        definitions = (path / 'lib/definitions/world.mbt').read_bytes()
        args = [policy.CLI, 'gen', 'build', *policy.SOURCES, '--package', 'lib/suite', '--apply']
        policy.command(args, path, 'targets-initial')
        generated = suite / 'moonspec_gen'
        manual = generated / 'async/manual.mbt'
        manual.write_text('// user launcher extension\n')
        config = dict(policy.POLICY, execution={'default':'sync', 'targets':{'native':'async'}})
        (path / 'moonspec.json5').write_text(json.dumps(config))
        before = policy.snapshot(path)
        policy.command(args[:-1], path, 'targets-preview')
        assert before == policy.snapshot(path)
        policy.command(args, path, 'targets-updated')
        assert '"wasm+wasm-gc+js"' in (generated / 'sync/moon.pkg').read_text()
        assert '"native"' in (generated / 'async/moon.pkg').read_text()
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'targets-async-executed')
        policy.verify_run(output, 'native', 'per-scenario', 'wbtest')
        # Change config only. Moon must track that input and regenerate grouping.
        config['mode'] = 'per-feature'
        (path / 'moonspec.json5').write_text(json.dumps(config))
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/async', '--target', 'native'], path, 'config-regenerated')
        policy.verify_run(output, 'native', 'per-feature', 'wbtest')
        config['execution'] = {'default':'sync', 'targets':{'js':'async'}}
        (path / 'moonspec.json5').write_text(json.dumps(config))
        policy.command(args, path, 'targets-native-sync')
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/sync', '--target', 'native'], path, 'targets-sync-executed')
        policy.verify_run(output, 'native', 'per-feature', 'wbtest')
        assert '"js"' in (generated / 'async/moon.pkg').read_text()
        config['execution'] = 'sync'
        (path / 'moonspec.json5').write_text(json.dumps(config))
        before = policy.snapshot(path)
        preview = policy.command(args[:-1], path, 'stale-removal-preview')
        assert 'remove lib/suite/moonspec_gen/async/moon.pkg' in preview, preview
        assert before == policy.snapshot(path)
        policy.command(args, path, 'targets-remove-async')
        assert manual.read_text() == '// user launcher extension\n'
        assert list((generated / 'async').iterdir()) == [manual]
        assert (suite / 'moon.pkg').read_text() == user_pkg
        assert (suite / 'user.mbt').read_text() == '// preserved user code\n'
        assert (path / 'lib/definitions/world.mbt').read_bytes() == definitions
        # A missing stale owned file is tolerated when removing a feature.
        (generated / 'sync/markdown_feature_wbtest.mbt').unlink()
        policy.command([policy.CLI, 'gen', 'build', './features/shared.feature', '--package', 'lib/suite', '--apply'], path, 'remove-feature')
        output = policy.command(['moon', 'test', 'lib/suite/moonspec_gen/sync', '--target', 'native'], path, 'feature-removed-executed')
        assert 'Total tests: 1, passed: 1, failed: 0' in output, output
        assert len([line for line in output.splitlines() if line.startswith('{"testCaseStarted"')]) == 3


def test_empty_ownership():
    with tempfile.TemporaryDirectory(prefix='moonspec-empty-ownership-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        generated = path / 'lib/suite/moonspec_gen'
        generated.mkdir(parents=True)
        (generated / 'manifest.json').write_text('{\n  "generator": "moonspec-shared-v1",\n  "files": []\n}\n')
        before = policy.snapshot(path)
        output = policy.command([policy.CLI, 'gen', 'tests', *policy.SOURCES, '-o', 'lib/suite'], path, 'empty-ownership', success=False)
        assert 'ownership' in output, output
        assert before == policy.snapshot(path)


def test_legacy_refresh_rejected():
    with tempfile.TemporaryDirectory(prefix='moonspec-legacy-refresh-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        (path / 'moonspec.json5').write_text('{"world":"MyWorld", "execution":"sync"}')
        (path / 'lib/suite').mkdir()
        base = [policy.CLI, 'gen', 'build', './features/shared.feature', '--package', 'lib/suite', '--apply']
        for flags in [['--refresh-output', 'lib/user.mbt'], ['--mode', 'per-feature'], ['--no-color']]:
            before = policy.snapshot(path)
            output = policy.command(base + flags, path, 'legacy-' + flags[0][2:], success=False)
            assert flags[0] in output, output
            assert before == policy.snapshot(path)



def test_rejections():
    with tempfile.TemporaryDirectory(prefix='moonspec-policy-reject-') as tmp:
        path = Path(tmp)
        policy.fixture(path)
        args = [policy.CLI, 'gen', 'build', *policy.SOURCES, '--package', 'lib/suite', '--apply']
        policy.command(args, path, 'reject-initial')
        generated = path / 'lib/suite/moonspec_gen'
        for invalid in ['lib/user.mbt', 'lib/suite/moonspec_gen/manifest.json', 'lib/suite/moonspec_gen/shared/moon.pkg', '../outside.mbt']:
            before = policy.snapshot(path)
            output = policy.command(args + ['--refresh-output', invalid], path, 'invalid-refresh-' + Path(invalid).name, success=False)
            assert 'refresh-output' in output or 'paths must not contain ..' in output, output
            assert before == policy.snapshot(path)
        before = policy.snapshot(path)
        policy.command(args[:-1] + ['--refresh-output', 'lib/suite/moonspec_gen/shared/sources.mbt'], path, 'refresh-preview')
        assert before == policy.snapshot(path)
        stale = generated / 'async/shared_feature_wbtest.mbt'
        stale.write_text(stale.read_text() + '// user modification\n')
        (path / 'moonspec.json5').write_text(json.dumps(dict(policy.POLICY, execution='sync')))
        before = policy.snapshot(path)
        output = policy.command(args, path, 'modified-stale', success=False)
        assert 'modified generated output' in output, output
        assert before == policy.snapshot(path)
        stale.write_text(stale.read_text().removesuffix('// user modification\n'))
        collision = generated / 'sync/shared_feature_test.mbt'
        collision.write_text('// unowned file\n')
        before = policy.snapshot(path)
        output = policy.command(args + ['--test-kind', 'test'], path, 'unowned-new-output', success=False)
        assert 'unowned output collision' in output, output
        assert before == policy.snapshot(path)


if __name__ == '__main__':
    (policy.EVIDENCE / 'report.json').unlink(missing_ok=True)
    test_mode_change()
    test_concurrent_generation()
    test_automatic_generation_cli_capability()
    test_build_rule()
    test_malformed_ownership()
    test_targets_and_preservation()
    test_rejections()
    test_empty_ownership()
    test_legacy_refresh_rejected()
    report = dict(runs=RUNS, tests=sum(r['tests'] for r in RUNS), scenarios=sum(r['scenarios'] for r in RUNS))
    (policy.EVIDENCE / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report))
