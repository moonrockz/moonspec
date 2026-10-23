"""Executable package-selection and effect contract probes."""
import json
from pathlib import Path
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LOG = HERE / '_build/contract'
LOG.mkdir(parents=True, exist_ok=True)

def run(cwd, label, args, expected=None):
    p = subprocess.run(['moon', *args], cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (LOG / (label + '.log')).write_text(p.stdout)
    if expected is None:
        assert p.returncode == 0, p.stdout
    else:
        assert p.returncode != 0 and expected in p.stdout, p.stdout
    print(label + ': verified')
    return p.stdout

with tempfile.TemporaryDirectory(prefix='moonspec-u15-contract-') as temp:
    p = Path(temp)
    (p/'moon.mod').write_text('name = "probe/contract"\nimport { "moonrockz/moonspec@0.11.0", "moonbitlang/async@0.22.4" }\n')
    (p/'moon.work').write_text('members = '+json.dumps([str(ROOT), '.'])+'\n')
    consumer=p/'consumer'
    consumer.mkdir()
    pkg=consumer/'moon.pkg'
    pkg.write_text('import { "moonrockz/moonspec/async" @moonspec }\nsupported_targets = "wasm+wasm-gc+js+native"\n')
    (consumer/'entry.mbt').write_text('#cfg(target="native")\npub async fn launch() -> Unit { ignore(@moonspec.RunOptions([])) }\n')
    run(p, 'cfg-import-negative', ['check', '--target', 'wasm-gc', 'consumer'], "Selected backend 'wasm-gc' is incompatible")
    pkg.write_text(pkg.read_text()+'options(targets: { "entry.mbt": ["native"] })\n')
    run(p, 'file-import-negative', ['check', '--target', 'wasm-gc', 'consumer'], "Selected backend 'wasm-gc' is incompatible")
    pkg.write_text('supported_targets = "wasm+wasm-gc+js+native"\n')
    (consumer/'entry.mbt').write_text('pub fn value() -> Int { 1 }\n')
    run(p, 'portable-positive', ['check', '--target', 'wasm-gc', 'consumer'])
    pkg.write_text('options(targets: { "entry.mbt": ["native"] })\n')
    (consumer/'entry.mbt').write_text('pub fn value() -> Int { missing_native_implementation() }\n')
    run(p, 'file-exclusion-positive', ['check', '--target', 'wasm-gc', 'consumer'])
    run(p, 'file-selection-negative', ['check', '--target', 'native', 'consumer'], 'missing_native_implementation')
    pkg.write_text('')
    (consumer/'entry.mbt').write_text('#cfg(target="native")\npub fn value() -> Int { missing_native_implementation() }\n')
    run(p, 'cfg-exclusion-positive', ['check', '--target', 'wasm-gc', 'consumer'])
    run(p, 'cfg-selection-negative', ['check', '--target', 'native', 'consumer'], 'missing_native_implementation')
    definition=p/'definition'
    definition.mkdir()
    (definition/'moon.pkg').write_text('')
    (definition/'world.mbt').write_text('pub struct World { priv ready : Bool }\npub fn world() -> World { { ready: false } }\n')
    pkg.write_text('import { "probe/contract/definition" }\n')
    (consumer/'entry.mbt').write_text('pub fn private_field() -> Bool { @definition.world().ready }\n')
    run(p, 'shared-private-field-negative', ['check', '--target', 'wasm-gc', 'consumer'], 'ready')
    (consumer/'entry.mbt').write_text('pub fn opaque_world() -> @definition.World { @definition.world() }\n')
    run(p, 'shared-opaque-world-positive', ['check', '--target', 'wasm-gc', 'consumer'])
    (definition/'world.mbt').write_text('priv struct World { ready : Bool }\npub fn world() -> World { { ready: false } }\n')
    run(p, 'shared-private-type-negative', ['check', '--target', 'wasm-gc', 'definition'], 'private')
    (definition/'world.mbt').write_text('priv struct World { ready : Bool }\nfn world() -> World { { ready: false } }\n')
    (definition/'private_wbtest.mbt').write_text('test "private World remains available within its package" { assert_false(world().ready) }\n')
    run(p, 'private-whitebox-positive', ['test', '--target', 'wasm-gc', 'definition'])
    (definition/'private_wbtest.mbt').unlink()
    (definition/'world.mbt').write_text('')
    virtual=p/'virtual'
    virtual.mkdir()
    (virtual/'moon.pkg').write_text('virtual(has_default: true)\n')
    (virtual/'pkg.mbti').write_text('package "probe/contract/virtual"\nfn value() -> Int\n')
    (virtual/'value.mbt').write_text('pub fn value() -> Int { 1 }\n')
    pkg.write_text('import { "probe/contract/virtual" @v }\n')
    (consumer/'entry.mbt').write_text('pub fn value() -> Int { @v.value() }\n')
    run(p, 'virtual-sync-positive', ['check', '--target', 'native', 'consumer'])
    (virtual/'value.mbt').write_text('pub async fn value() -> Int { 1 }\n')
    run(p, 'virtual-effect-negative', ['check', '--target', 'native', 'virtual'], '4160')

run(HERE, 'shared-wasm-gc', ['test', '--target', 'wasm-gc', 'src/sync'])
run(HERE, 'shared-async-native', ['test', '--target', 'native', 'src/async'])
