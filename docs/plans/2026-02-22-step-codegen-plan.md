# Step Codegen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `moonspec gen steps` CLI command that scans MoonBit source files for `#moonspec.*` attributes and generates `register_steps` implementations, alongside refactoring `moonspec gen` into `moonspec gen tests`/`moonspec gen steps` subcommands and introducing hierarchical config.

**Architecture:** Three-phase epic. Phase 1 refactors the CLI to use nested subcommands (`gen tests`, `gen steps`). Phase 2 creates a `src/config/` package for hierarchical `moonspec.json5` config loading with package-level overrides. Phase 3 implements attribute scanning via `moonbitlang/parser` and code generation for `register_steps` implementations.

**Tech Stack:** MoonBit, `TheWaWaR/clap` (nested subcommands), `moonbitlang/x/json5`, `moonbitlang/x/fs`, `moonbitlang/parser` (AST parsing)

---

## Phase 1: CLI Refactoring

### Task 1: Refactor `gen` into nested subcommands

**Files:**
- Modify: `src/cmd/main/main.mbt:18-64` (build_parser)
- Modify: `src/cmd/main/main.mbt:240-277` (main dispatch)

**Step 1: Write the failing test**

No test file exists for the CLI currently. Create one with a basic structural test.

```moonbit
// src/cmd/main/cli_wbtest.mbt
test "build_parser has gen subcommand with tests and steps sub-subcommands" {
  let parser = build_parser()
  // Verify the parser builds without error
  // The gen subcommand should exist with nested subcmds
  let value = @clap.SimpleValue::new("moonspec")
  let help = parser.parse(value, ["gen"][:]) catch { _ => "" }
  // Should show help for gen (no sub-subcommand given)
  match help {
    Some(msg) => assert_true(msg.contains("tests") && msg.contains("steps"))
    None => assert_true(false) // Should have shown help
  }
}
```

Note: `build_parser()` is module-private (`fn`, not `pub fn`), so the test file goes in the same package: `src/cmd/main/cli_wbtest.mbt`. The `_wbtest.mbt` suffix is the MoonBit whitebox test convention.

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `build_parser` doesn't have nested subcmds yet, and the `contains` method may not exist on String (check MoonBit stdlib). If `String::contains` isn't available, use the existing `contains()` helper from `codegen.mbt` or inline a simple check.

**Step 3: Refactor `build_parser` to use nested subcommands**

Change `build_parser()` in `src/cmd/main/main.mbt` to nest `tests` and `steps` under `gen`:

```moonbit
fn build_parser() -> @clap.Parser {
  @clap.Parser::new(
    prog="moonspec",
    description="BDD test framework for MoonBit",
    subcmds={
      "gen": @clap.SubCommand::new(
        subcmds={
          "tests": @clap.SubCommand::new(
            args={
              "files": @clap.Arg::positional(
                nargs=AtLeast(1),
                help=".feature files to generate tests from",
              ),
              "output-dir": @clap.Arg::named(
                short='o',
                nargs=AtMost(1),
                help="Output directory for generated test files",
              ),
              "world": @clap.Arg::named(
                short='w',
                nargs=AtMost(1),
                help="World type name (e.g. CalcWorld)",
              ),
              "mode": @clap.Arg::named(
                short='m',
                nargs=AtMost(1),
                help="Codegen mode: per-scenario (default) or per-feature",
              ),
              "config": @clap.Arg::named(
                short='c',
                nargs=AtMost(1),
                help="Path to moonspec.json5 config file",
              ),
            },
            help="Generate _test.mbt files from .feature files",
          ),
          "steps": @clap.SubCommand::new(
            args={
              "dir": @clap.Arg::named(
                short='d',
                nargs=AtMost(1),
                help="Directory to scan for .mbt files (default: src/)",
              ),
              "config": @clap.Arg::named(
                short='c',
                nargs=AtMost(1),
                help="Path to moonspec.json5 config file",
              ),
            },
            help="Generate register_steps from #moonspec.* attributes",
          ),
        },
        help="Code generation commands",
      ),
      "check": @clap.SubCommand::new(
        args={
          "files": @clap.Arg::positional(
            nargs=AtLeast(1),
            help=".feature files to check",
          ),
        },
        help="Parse and validate .feature files",
      ),
      "version": @clap.SubCommand::new(help="Print version information"),
    },
  )
}
```

**Step 4: Update the main dispatch to handle nested subcommands**

Update the `main` function dispatch in `src/cmd/main/main.mbt`:

```moonbit
match value.subcmd {
  Some(subcmd) =>
    match subcmd.name {
      "version" => cmd_version()
      "gen" =>
        match subcmd.subcmd {
          Some(gen_subcmd) =>
            match gen_subcmd.name {
              "tests" => cmd_gen_tests(gen_subcmd)
              "steps" => cmd_gen_steps(gen_subcmd)
              _ => ()
            }
          None => {
            let help = parser.gen_help_message(["moonspec", "gen"], {})
            println(help)
          }
        }
      "check" => cmd_check(subcmd)
      _ => ()
    }
  None => {
    let help = parser.gen_help_message(["moonspec"], {})
    println(help)
  }
}
```

**Step 5: Rename `cmd_gen` to `cmd_gen_tests` and add stub `cmd_gen_steps`**

Rename the existing `cmd_gen` function to `cmd_gen_tests` (same body, just rename). Add a stub:

```moonbit
fn cmd_gen_steps(_value : @clap.SimpleValue) -> Unit {
  eprintln("moonspec gen steps: not yet implemented")
  @sys.exit(1)
}
```

**Step 6: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 7: Commit**

```bash
git add src/cmd/main/main.mbt src/cmd/main/cli_wbtest.mbt
git commit -m "refactor(cli): nest gen subcommands as gen tests and gen steps"
```

---

## Phase 2: Hierarchical Config Package

### Task 2: Create config package with moonspec-specific config struct

**Files:**
- Create: `src/config/moon.pkg`
- Create: `src/config/config.mbt`
- Create: `src/config/config_wbtest.mbt`

**Step 1: Write the failing test**

```moonbit
// src/config/config_wbtest.mbt

test "MoonspecConfig::from_json5 parses simple mode" {
  let json5 = "{ \"world\": \"MyWorld\", \"mode\": \"per-scenario\" }"
  let config = MoonspecConfig::from_json5(json5)
  assert_eq(config.world, Some("MyWorld"))
  match config.mode {
    Some(Simple(mode)) => assert_eq(mode, "per-scenario")
    _ => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 parses map mode" {
  let json5 =
    #|{
    #|  "world": "MyWorld",
    #|  "mode": {
    #|    "features/checkout.feature": "per-feature",
    #|    "*": "per-scenario"
    #|  }
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.mode {
    Some(PerFile(map)) => {
      assert_eq(map.get("features/checkout.feature"), Some("per-feature"))
      assert_eq(map.get("*"), Some("per-scenario"))
    }
    _ => assert_true(false)
  }
}

test "MoonspecConfig::from_json5 parses steps config" {
  let json5 =
    #|{
    #|  "steps": {
    #|    "output": "alongside",
    #|    "exclude": ["lib/*", "vendor/*"]
    #|  }
    #|}
  let config = MoonspecConfig::from_json5(json5)
  match config.steps {
    Some(steps) => {
      assert_eq(steps.output, Some("alongside"))
      assert_eq(steps.exclude, Some(["lib/*", "vendor/*"]))
    }
    None => assert_true(false)
  }
}

test "merge: package config overrides module config" {
  let module_config = MoonspecConfig::{
    world: Some("ModuleWorld"),
    mode: Some(Simple("per-scenario")),
    steps: None,
  }
  let package_config = MoonspecConfig::{
    world: None,
    mode: Some(Simple("per-feature")),
    steps: Some(StepsConfig::{ output: Some("alongside"), exclude: None }),
  }
  let merged = module_config.merge(package_config)
  assert_eq(merged.world, Some("ModuleWorld"))  // inherited from module
  match merged.mode {
    Some(Simple(m)) => assert_eq(m, "per-feature")  // overridden by package
    _ => assert_true(false)
  }
  match merged.steps {
    Some(s) => assert_eq(s.output, Some("alongside"))
    None => assert_true(false)
  }
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — config package doesn't exist yet

**Step 3: Create the config package**

`src/config/moon.pkg`:
```
import {
  "moonbitlang/x/json5",
}
```

`src/config/config.mbt`:
```moonbit
///|
/// Mode configuration — either a simple string or a per-file map.
pub(all) enum ModeConfig {
  Simple(String)
  PerFile(Map[String, String])
} derive(Show, Eq)

///|
/// Steps codegen configuration.
pub(all) struct StepsConfig {
  output : String?
  exclude : Array[String]?
} derive(Show, Eq)

///|
/// Moonspec configuration with optional fields for hierarchical merging.
pub(all) struct MoonspecConfig {
  world : String?
  mode : ModeConfig?
  steps : StepsConfig?
} derive(Show, Eq)

///|
/// Empty config (all None).
pub fn MoonspecConfig::empty() -> MoonspecConfig {
  { world: None, mode: None, steps: None }
}

///|
/// Parse config from a JSON5 string.
pub fn MoonspecConfig::from_json5(input : String) -> MoonspecConfig {
  let json = @json5.parse(input) catch { _ => return MoonspecConfig::empty() }
  let mut world : String? = None
  let mut mode : ModeConfig? = None
  let mut steps : StepsConfig? = None
  match json {
    Object(obj) => {
      match obj.get("world") {
        Some(String(s)) => world = Some(s)
        _ => ()
      }
      match obj.get("mode") {
        Some(String(s)) => mode = Some(Simple(s))
        Some(Object(map)) => {
          let result : Map[String, String] = {}
          for key, value in map {
            match value {
              String(s) => result.set(key, s)
              _ => ()
            }
          }
          mode = Some(PerFile(result))
        }
        _ => ()
      }
      match obj.get("steps") {
        Some(Object(steps_obj)) => {
          let mut output : String? = None
          let mut exclude : Array[String]? = None
          match steps_obj.get("output") {
            Some(String(s)) => output = Some(s)
            _ => ()
          }
          match steps_obj.get("exclude") {
            Some(Array(arr)) => {
              let items : Array[String] = []
              for item in arr {
                match item {
                  String(s) => items.push(s)
                  _ => ()
                }
              }
              exclude = Some(items)
            }
            _ => ()
          }
          steps = Some(StepsConfig::{ output, exclude })
        }
        _ => ()
      }
    }
    _ => ()
  }
  { world, mode, steps }
}

///|
/// Merge two configs. Fields from `override_` take precedence when present.
pub fn MoonspecConfig::merge(
  self : MoonspecConfig,
  override_ : MoonspecConfig,
) -> MoonspecConfig {
  {
    world: match override_.world {
      Some(_) => override_.world
      None => self.world
    },
    mode: match override_.mode {
      Some(_) => override_.mode
      None => self.mode
    },
    steps: match (self.steps, override_.steps) {
      (_, Some(s)) => Some(s)
      (Some(s), None) => Some(s)
      (None, None) => None
    },
  }
}

///|
/// Resolve the codegen mode for a specific feature file path.
/// Returns "per-scenario" or "per-feature".
pub fn MoonspecConfig::resolve_mode(
  self : MoonspecConfig,
  _feature_path : String,
) -> String {
  match self.mode {
    Some(Simple(s)) => s
    Some(PerFile(map)) => {
      // TODO: implement glob matching against feature_path
      // For now, check exact match then fallback to "*"
      match map.get(_feature_path) {
        Some(m) => m
        None =>
          match map.get("*") {
            Some(m) => m
            None => "per-scenario"
          }
      }
    }
    None => "per-scenario"
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/config/
git commit -m "feat(config): add hierarchical moonspec config package"
```

### Task 3: Migrate CLI to use new config package

**Files:**
- Modify: `src/cmd/main/main.mbt:72-161` (cmd_gen_tests)
- Modify: `src/cmd/main/moon.pkg`

**Step 1: Update the CLI's moon.pkg to import the config package**

Add `"moonrockz/moonspec/config"` to `src/cmd/main/moon.pkg` imports.

**Step 2: Update `cmd_gen_tests` to load config via the new package**

Adapt `cmd_gen_tests` to use `@config.MoonspecConfig::from_json5()` and convert to the existing `CodegenConfig` for backward compatibility with the codegen package:

```moonbit
fn cmd_gen_tests(value : @clap.SimpleValue) -> Unit {
  let files = value.positional_args
  let output_dir : String? = match value.args.get("output-dir") {
    Some(vals) => Some(vals[0])
    None => None
  }
  // Load hierarchical config
  let config_path : String? = match value.args.get("config") {
    Some(vals) => Some(vals[0])
    None => None
  }
  let moonspec_config = load_config(config_path)
  // CLI flags override config
  let world = match value.args.get("world") {
    Some(vals) => vals[0]
    None =>
      match moonspec_config.world {
        Some(w) => w
        None => ""
      }
  }
  if world.length() == 0 {
    die(
      "Error: --world (-w) is required. Specify the World type name (e.g. -w CalcWorld)",
    )
    return
  }
  for file in files {
    let mode_str = match value.args.get("mode") {
      Some(vals) => vals[0]
      None => moonspec_config.resolve_mode(file)
    }
    let mode = match mode_str {
      "per-feature" => @codegen.CodegenMode::PerFeature
      "per-scenario" => @codegen.CodegenMode::PerScenario
      other => {
        die("Unknown mode: \{other} (expected per-scenario or per-feature)")
        return
      }
    }
    let config = @codegen.CodegenConfig::{ mode, world }
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        die("Error reading \{file}: \{msg}")
        return
      }
    }
    let test_code = @codegen.generate_test_file(content, file, config~)
    let test_filename = @codegen.feature_to_test_filename(file)
    let output_path = match output_dir {
      Some(dir) => dir + "/" + test_filename
      None => test_filename
    }
    @fs.write_string_to_file(output_path, test_code) catch {
      @fs.IOError(msg) => {
        die("Error writing \{output_path}: \{msg}")
        return
      }
    }
    println(output_path)
  }
}
```

Add a helper `load_config`:

```moonbit
fn load_config(config_path : String?) -> @config.MoonspecConfig {
  let path = match config_path {
    Some(p) => p
    None => {
      let content = @fs.read_file_to_string("moonspec.json5") catch { _ => "" }
      if content.length() > 0 {
        "moonspec.json5"
      } else {
        return @config.MoonspecConfig::empty()
      }
    }
  }
  let content = @fs.read_file_to_string(path) catch {
    @fs.IOError(msg) => {
      die("Error reading config \{path}: \{msg}")
      return @config.MoonspecConfig::empty()
    }
  }
  @config.MoonspecConfig::from_json5(content)
}
```

**Step 3: Run tests to verify nothing broke**

Run: `mise run test:unit`
Expected: PASS — existing codegen tests should still pass since the codegen package itself is unchanged

**Step 4: Commit**

```bash
git add src/cmd/main/main.mbt src/cmd/main/moon.pkg
git commit -m "refactor(cli): migrate gen tests to use hierarchical config"
```

---

## Phase 3: Attribute Scanning & Step Codegen

### Task 4: Add `moonbitlang/parser` dependency

**Files:**
- Modify: `moon.mod.json`

**Step 1: Add the dependency**

```bash
moon add moonbitlang/parser
```

Or manually add `"moonbitlang/parser": "0.1.16"` to `moon.mod.json` deps and run `moon update`.

**Step 2: Verify dependency resolves**

Run: `moon check`
Expected: Success (no compile errors)

**Step 3: Commit**

```bash
git add moon.mod.json
git commit -m "build: add moonbitlang/parser dependency"
```

### Task 5: Create step scanner package with attribute extraction

**Files:**
- Create: `src/scanner/moon.pkg`
- Create: `src/scanner/scanner.mbt`
- Create: `src/scanner/types.mbt`
- Create: `src/scanner/scanner_wbtest.mbt`

**Step 1: Write failing tests for attribute extraction**

```moonbit
// src/scanner/scanner_wbtest.mbt

test "scan extracts #moonspec.given attribute from method" {
  let source =
    #|#moonspec.given("I have {int} cucumbers")
    #|fn set_cucumbers(self : MyWorld, count : Int) -> Unit {
    #|  self.cucumbers = count
    #|}
  let results = scan_source(source, name="test.mbt")
  assert_eq(results.step_fns.length(), 1)
  let step = results.step_fns[0]
  assert_eq(step.keyword, "given")
  assert_eq(step.pattern, "I have {int} cucumbers")
  assert_eq(step.fn_name, "set_cucumbers")
  assert_eq(step.world_type, "MyWorld")
  assert_eq(step.params.length(), 1)
  assert_eq(step.params[0].name, "count")
  assert_eq(step.params[0].type_name, "Int")
}

test "scan extracts #moonspec.world attribute from struct" {
  let source =
    #|#moonspec.world(init = Self::new)
    #|struct AnimalWorld { mut cat : Cat }
  let results = scan_source(source, name="test.mbt")
  assert_eq(results.world_configs.length(), 1)
  let wc = results.world_configs[0]
  assert_eq(wc.type_name, "AnimalWorld")
  assert_eq(wc.init_fn, Some("Self::new"))
}

test "scan handles multiple step keywords" {
  let source =
    #|#moonspec.given("a user named {string}")
    #|fn given_user(self : W, name : String) -> Unit {}
    #|
    #|#moonspec.when("they log in")
    #|fn when_login(self : W) -> Unit {}
    #|
    #|#moonspec.then("they see {string}")
    #|fn then_see(self : W, text : String) -> Unit raise Error {}
  let results = scan_source(source, name="test.mbt")
  assert_eq(results.step_fns.length(), 3)
  assert_eq(results.step_fns[0].keyword, "given")
  assert_eq(results.step_fns[1].keyword, "when")
  assert_eq(results.step_fns[2].keyword, "then")
  assert_true(results.step_fns[2].raises)
}

test "scan handles standalone function (non-method)" {
  let source =
    #|#moonspec.given("I have {int} items")
    #|fn set_items(world : MyWorld, count : Int) -> Unit {
    #|  world.items = count
    #|}
  let results = scan_source(source, name="test.mbt")
  assert_eq(results.step_fns.length(), 1)
  assert_eq(results.step_fns[0].world_type, "MyWorld")
  assert_eq(results.step_fns[0].is_method, false)
}

test "scan ignores functions without moonspec attributes" {
  let source =
    #|fn helper(x : Int) -> Int { x + 1 }
    #|
    #|#moonspec.given("something")
    #|fn step_fn(self : W) -> Unit {}
  let results = scan_source(source, name="test.mbt")
  assert_eq(results.step_fns.length(), 1)
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — scanner package doesn't exist

**Step 3: Create the types**

`src/scanner/moon.pkg`:
```
import {
  "moonbitlang/parser",
}
```

`src/scanner/types.mbt`:
```moonbit
///|
/// A parameter extracted from a function signature.
pub(all) struct ParamInfo {
  name : String
  type_name : String
} derive(Show, Eq)

///|
/// A step function extracted from source code.
pub(all) struct StepFnInfo {
  keyword : String         // "given", "when", "then"
  pattern : String         // cucumber expression pattern
  fn_name : String         // function name
  world_type : String      // World type from self/first param
  params : Array[ParamInfo] // cucumber expression params (excludes self/world)
  is_method : Bool         // true if uses self parameter
  raises : Bool            // true if function raises Error
  source_file : String     // source file path
  line : Int               // line number
} derive(Show, Eq)

///|
/// World configuration from #moonspec.world attribute.
pub(all) struct WorldConfigInfo {
  type_name : String       // struct name
  init_fn : String?        // custom constructor (e.g. "Self::new")
  source_file : String
  line : Int
} derive(Show, Eq)

///|
/// Results of scanning a source file.
pub(all) struct ScanResult {
  step_fns : Array[StepFnInfo]
  world_configs : Array[WorldConfigInfo]
} derive(Show, Eq)
```

**Step 4: Implement the scanner**

`src/scanner/scanner.mbt`:

```moonbit
///|
/// Scan a MoonBit source string for #moonspec.* attributes.
pub fn scan_source(
  source : String,
  name? : String = "<input>",
) -> ScanResult {
  let (impls, _errors) = @parser.parse_string(source, name?)
  let step_fns : Array[StepFnInfo] = []
  let world_configs : Array[WorldConfigInfo] = []
  walk_impls(impls, step_fns, world_configs, name)
  { step_fns, world_configs }
}

///|
fn walk_impls(
  impls : @list.List[@parser.syntax.Impl],
  step_fns : Array[StepFnInfo],
  world_configs : Array[WorldConfigInfo],
  source_file : String,
) -> Unit {
  match impls {
    Nil => ()
    Cons(impl_, rest) => {
      process_impl(impl_, step_fns, world_configs, source_file)
      walk_impls(rest, step_fns, world_configs, source_file)
    }
  }
}

///|
fn process_impl(
  impl_ : @parser.syntax.Impl,
  step_fns : Array[StepFnInfo],
  world_configs : Array[WorldConfigInfo],
  source_file : String,
) -> Unit {
  match impl_ {
    TopFuncDef(fun_decl~, ..) =>
      process_func(fun_decl, step_fns, source_file)
    TopTypeDef(type_decl) =>
      process_type(type_decl, world_configs, source_file)
    _ => ()
  }
}

///|
fn process_func(
  fun_decl : @parser.syntax.FunDecl,
  step_fns : Array[StepFnInfo],
  source_file : String,
) -> Unit {
  // Check each attribute for #moonspec.given/when/then
  let mut attrs = fun_decl.attrs
  while true {
    match attrs {
      Nil => break
      Cons(attr, rest) => {
        match extract_step_attr(attr) {
          Some((keyword, pattern)) => {
            let (world_type, params, is_method) = extract_func_params(
              fun_decl.decl_params,
            )
            let raises = fun_decl.has_error is Some(_)
            step_fns.push(
              {
                keyword,
                pattern,
                fn_name: fun_decl.name.name,
                world_type,
                params,
                is_method,
                raises,
                source_file,
                line: fun_decl.name.loc.start.line,
              },
            )
          }
          None => ()
        }
        attrs = rest
      }
    }
  }
}

///|
fn extract_step_attr(
  attr : @parser.attribute.Attribute,
) -> (String, String)? {
  match attr.parsed {
    Some(Apply(id, props)) =>
      if id.qual == Some("moonspec") {
        match id.name {
          "given" | "when" | "then" => {
            let pattern = extract_string_arg(props)
            match pattern {
              Some(p) => Some((id.name, p))
              None => None
            }
          }
          _ => None
        }
      } else {
        None
      }
    _ => None
  }
}

///|
fn extract_string_arg(
  props : @list.List[@parser.attribute.Prop],
) -> String? {
  match props {
    Cons(prop, _) =>
      match prop {
        Expr(String(s)) => Some(s.to_string())
        _ => None
      }
    Nil => None
  }
}

///|
fn extract_func_params(
  params : @list.List[@parser.syntax.Parameter]?,
) -> (String, Array[ParamInfo], Bool) {
  let result : Array[ParamInfo] = []
  let mut world_type = ""
  let mut is_method = false
  let mut is_first = true
  let mut param_list = match params {
    Some(list) => list
    None => return (world_type, result, is_method)
  }
  while true {
    match param_list {
      Nil => break
      Cons(param, rest) => {
        match param {
          Positional(binder~, ty~) => {
            if is_first {
              if binder.name == "self" {
                is_method = true
                world_type = type_to_string(ty)
              } else {
                // Standalone function — first param is World
                world_type = type_to_string(ty)
              }
            } else {
              result.push(
                { name: binder.name, type_name: type_to_string(ty) },
              )
            }
          }
          _ => ()
        }
        is_first = false
        param_list = rest
      }
    }
  }
  (world_type, result, is_method)
}

///|
fn type_to_string(ty : @parser.syntax.Type?) -> String {
  match ty {
    Some(Name(constr_id~, ..)) => constr_id.name
    _ => "Unknown"
  }
}

///|
fn process_type(
  type_decl : @parser.syntax.TypeDecl,
  world_configs : Array[WorldConfigInfo],
  source_file : String,
) -> Unit {
  let mut attrs = type_decl.attrs
  while true {
    match attrs {
      Nil => break
      Cons(attr, rest) => {
        match extract_world_attr(attr) {
          Some(init_fn) =>
            world_configs.push(
              {
                type_name: type_decl.tycon,
                init_fn,
                source_file,
                line: type_decl.loc.start.line,
              },
            )
          None => ()
        }
        attrs = rest
      }
    }
  }
}

///|
fn extract_world_attr(
  attr : @parser.attribute.Attribute,
) -> String?? {
  // Returns None if not a moonspec.world attr,
  // Some(None) if no init specified,
  // Some(Some(init_fn)) if init specified
  match attr.parsed {
    Some(Apply(id, props)) =>
      if id.qual == Some("moonspec") && id.name == "world" {
        let init_fn = extract_labeled_string(props, "init")
        Some(init_fn)
      } else {
        None
      }
    _ => None
  }
}

///|
fn extract_labeled_string(
  props : @list.List[@parser.attribute.Prop],
  label : String,
) -> String? {
  match props {
    Nil => None
    Cons(prop, rest) =>
      match prop {
        Labeled(name, expr) =>
          if name == label {
            match expr {
              // The init value might be parsed as an Ident, not a String
              Ident(id) =>
                match id.qual {
                  Some(q) => Some(q + "::" + id.name)
                  None => Some(id.name)
                }
              String(s) => Some(s.to_string())
              _ => None
            }
          } else {
            extract_labeled_string(rest, label)
          }
        _ => extract_labeled_string(rest, label)
      }
  }
}
```

**Important note:** The exact AST field names (`fun_decl`, `decl_body`, `type_name`, `name`, `decl_params`, `has_error`, `attrs`, `loc`, etc.) are from the `moonbitlang/parser` research. These may need adjustment based on the actual published API. The implementing agent should check the parser's `.mbti` file or source to verify exact field names and enum variant names.

**Step 5: Run tests**

Run: `mise run test:unit`
Expected: PASS (or near-pass with minor AST field name adjustments)

**Step 6: Commit**

```bash
git add src/scanner/
git commit -m "feat(scanner): add MoonBit source scanner for moonspec attributes"
```

### Task 6: Create step codegen (generate register_steps)

**Files:**
- Create: `src/scanner/codegen.mbt`
- Create: `src/scanner/codegen_wbtest.mbt`

**Step 1: Write failing tests**

```moonbit
// src/scanner/codegen_wbtest.mbt

test "generate_register_steps produces valid impl block" {
  let steps : Array[StepFnInfo] = [
    {
      keyword: "given",
      pattern: "I have {int} cucumbers",
      fn_name: "set_cucumbers",
      world_type: "MyWorld",
      params: [{ name: "count", type_name: "Int" }],
      is_method: true,
      raises: false,
      source_file: "src/steps.mbt",
      line: 2,
    },
  ]
  let output = generate_register_steps("MyWorld", steps, source_hash="abcd1234")
  assert_true(output.contains("impl @moonspec.World for MyWorld"))
  assert_true(output.contains("s.given(\"I have {int} cucumbers\""))
  assert_true(output.contains("set_cucumbers(self"))
  assert_true(output.contains("// moonspec:hash:abcd1234"))
}

test "generate_register_steps maps arg types correctly" {
  let steps : Array[StepFnInfo] = [
    {
      keyword: "when",
      pattern: "I eat {int} of {string}",
      fn_name: "eat_food",
      world_type: "W",
      params: [
        { name: "count", type_name: "Int" },
        { name: "food", type_name: "String" },
      ],
      is_method: true,
      raises: false,
      source_file: "src/steps.mbt",
      line: 5,
    },
  ]
  let output = generate_register_steps("W", steps, source_hash="00000000")
  assert_true(output.contains("args[0].int()"))
  assert_true(output.contains("args[1].string()"))
}

test "generate_register_steps handles raise functions" {
  let steps : Array[StepFnInfo] = [
    {
      keyword: "then",
      pattern: "I should have {int}",
      fn_name: "check_count",
      world_type: "W",
      params: [{ name: "n", type_name: "Int" }],
      is_method: true,
      raises: true,
      source_file: "src/steps.mbt",
      line: 10,
    },
  ]
  let output = generate_register_steps("W", steps, source_hash="00000000")
  assert_true(output.contains("fn(args) raise {"))
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL

**Step 3: Implement the code generator**

`src/scanner/codegen.mbt`:

```moonbit
///|
/// Map a MoonBit type name to a StepArg accessor.
fn arg_accessor(type_name : String) -> String {
  match type_name {
    "Int" => "int()"
    "Double" => "float()"
    "String" => "string()"
    _ => "string()"
  }
}

///|
/// Generate a register_steps implementation for a World type.
pub fn generate_register_steps(
  world_type : String,
  steps : Array[StepFnInfo],
  source_hash? : String = "00000000",
) -> String {
  let buf = StringBuilder::new()
  buf.write_string("// Generated by moonspec gen steps — DO NOT EDIT\n")
  buf.write_string("// moonspec:hash:")
  buf.write_string(source_hash)
  buf.write_string("\n\n")
  buf.write_string("impl @moonspec.World for ")
  buf.write_string(world_type)
  buf.write_string(" with register_steps(self, s) {\n")
  for step in steps {
    buf.write_string("  s.")
    buf.write_string(step.keyword)
    buf.write_string("(\"")
    buf.write_string(step.pattern)
    buf.write_string("\", ")
    if step.raises {
      buf.write_string("fn(args) raise {\n")
    } else {
      buf.write_string("fn(args) {\n")
    }
    buf.write_string("    ")
    buf.write_string(step.fn_name)
    buf.write_string("(self")
    for i, param in steps.iter2() {
      // Only iterate this step's params
      ignore(i)
      ignore(param)
    }
    // Generate args
    for i = 0; i < step.params.length(); i = i + 1 {
      buf.write_string(", args[")
      buf.write_string(i.to_string())
      buf.write_string("].")
      buf.write_string(arg_accessor(step.params[i].type_name))
    }
    buf.write_string(")\n")
    buf.write_string("  })\n")
  }
  buf.write_string("}\n")
  buf.to_string()
}
```

**Note:** The exact accessor methods on `StepArg` (e.g., `.int()`, `.string()`, `.float()`) need to be verified against the actual `StepArg` enum API. Currently `StepArg` is an enum with `IntArg(Int)`, `FloatArg(Double)`, `StringArg(String)` etc. The generated code needs to use pattern matching or helper methods. The implementing agent should check if accessor methods exist or if pattern-matching closures are needed instead. If no accessors exist, the generated handler should use match expressions:

```moonbit
// Alternative: generate match-based extraction
fn(args) {
  let count = match args[0] { IntArg(v) => v; _ => 0 }
  set_cucumbers(self, count)
}
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/scanner/codegen.mbt src/scanner/codegen_wbtest.mbt
git commit -m "feat(scanner): add register_steps code generator"
```

### Task 7: Wire up `cmd_gen_steps` in CLI

**Files:**
- Modify: `src/cmd/main/main.mbt` (cmd_gen_steps)
- Modify: `src/cmd/main/moon.pkg` (add scanner import)

**Step 1: Update moon.pkg**

Add `"moonrockz/moonspec/scanner"` to `src/cmd/main/moon.pkg` imports.

**Step 2: Implement `cmd_gen_steps`**

Replace the stub in `src/cmd/main/main.mbt`:

```moonbit
fn cmd_gen_steps(value : @clap.SimpleValue) -> Unit {
  let scan_dir = match value.args.get("dir") {
    Some(vals) => vals[0]
    None => "src"
  }
  let config = match value.args.get("config") {
    Some(vals) => load_config(Some(vals[0]))
    None => load_config(None)
  }
  let output_mode = match config.steps {
    Some(steps) =>
      match steps.output {
        Some(o) => o
        None => "generated"
      }
    None => "generated"
  }
  let exclude_patterns = match config.steps {
    Some(steps) =>
      match steps.exclude {
        Some(e) => e
        None => []
      }
    None => []
  }
  // Discover .mbt files
  let files = discover_mbt_files(scan_dir, exclude_patterns)
  if files.is_empty() {
    println("No .mbt files found in \{scan_dir}")
    return
  }
  // Scan all files
  let all_steps : Map[String, Array[@scanner.StepFnInfo]] = {}
  let all_world_configs : Array[@scanner.WorldConfigInfo] = []
  for file in files {
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        eprintln("Warning: could not read \{file}: \{msg}")
        continue
      }
    }
    let result = @scanner.scan_source(content, name=file)
    for step in result.step_fns {
      match all_steps.get(step.world_type) {
        Some(arr) => arr.push(step)
        None => all_steps.set(step.world_type, [step])
      }
    }
    for wc in result.world_configs {
      all_world_configs.push(wc)
    }
  }
  if all_steps.is_empty() {
    println("No #moonspec.* attributes found")
    return
  }
  // Generate for each World type
  for world_type, steps in all_steps {
    // TODO: conflict detection — check for manual register_steps
    let source_content = steps.map(fn(s) { s.source_file + ":" + s.line.to_string() }).join(",")
    let hash = simple_hash(source_content)
    let code = @scanner.generate_register_steps(world_type, steps, source_hash=hash)
    let output_path = resolve_output_path(output_mode, world_type, steps)
    @fs.write_string_to_file(output_path, code) catch {
      @fs.IOError(msg) => {
        die("Error writing \{output_path}: \{msg}")
        return
      }
    }
    println(output_path)
  }
}
```

Add helper functions for file discovery and output path resolution:

```moonbit
fn discover_mbt_files(
  dir : String,
  _exclude_patterns : Array[String],
) -> Array[String] {
  // Walk directory recursively finding .mbt files
  // TODO: implement exclude pattern matching
  let files : Array[String] = []
  walk_dir(dir, files)
  files
}

fn walk_dir(dir : String, files : Array[String]) -> Unit {
  let entries = @fs.read_dir(dir) catch { _ => return }
  for entry in entries {
    let path = dir + "/" + entry
    if entry.ends_with(".mbt") && not(entry.ends_with("_wbtest.mbt")) && not(entry.ends_with("_test.mbt")) {
      files.push(path)
    } else {
      // Try as directory (crude check: no extension)
      if not(entry.contains(".")) {
        walk_dir(path, files)
      }
    }
  }
}

fn resolve_output_path(
  mode : String,
  world_type : String,
  steps : Array[@scanner.StepFnInfo],
) -> String {
  match mode {
    "alongside" => {
      // Write next to the first step file
      let first_file = steps[0].source_file
      let dir = dirname(first_file)
      let lower_world = world_type.to_lower()
      dir + "/" + lower_world + "_steps_gen.mbt"
    }
    "per-package" => {
      let first_file = steps[0].source_file
      let dir = dirname(first_file)
      dir + "/moonspec_gen.mbt"
    }
    "generated" => {
      "_generated/" + world_type.to_lower() + "_steps.mbt"
    }
    custom => custom + "/" + world_type.to_lower() + "_steps.mbt"
  }
}

fn dirname(path : String) -> String {
  let mut last_slash = -1
  for i = 0; i < path.length(); i = i + 1 {
    if path[i] == '/' {
      last_slash = i
    }
  }
  if last_slash >= 0 {
    path.substring(start=0, end=last_slash)
  } else {
    "."
  }
}
```

**Note:** `@fs.read_dir`, `String::ends_with`, `String::contains`, `String::to_lower`, `String::substring` — the implementing agent must verify these exist in the MoonBit stdlib or `moonbitlang/x`. Some may need custom implementations (similar to the existing helpers in `codegen.mbt`).

**Step 3: Run full test suite**

Run: `mise run test:unit`
Expected: PASS

**Step 4: Commit**

```bash
git add src/cmd/main/main.mbt src/cmd/main/moon.pkg
git commit -m "feat(cli): implement moonspec gen steps command"
```

### Task 8: Add staleness detection and conflict checking

**Files:**
- Modify: `src/cmd/main/main.mbt` (add conflict detection to cmd_gen_steps)
- Create: `src/scanner/conflict.mbt`
- Create: `src/scanner/conflict_wbtest.mbt`

**Step 1: Write failing test for conflict detection**

```moonbit
// src/scanner/conflict_wbtest.mbt

test "detect_manual_registration finds impl World block" {
  let source =
    #|impl @moonspec.World for MyWorld with register_steps(self, s) {
    #|  s.given("something", fn(args) { () })
    #|}
  assert_true(has_manual_registration(source, "MyWorld"))
}

test "detect_manual_registration returns false for other types" {
  let source =
    #|impl @moonspec.World for OtherWorld with register_steps(self, s) {
    #|  s.given("something", fn(args) { () })
    #|}
  assert_true(not(has_manual_registration(source, "MyWorld")))
}
```

**Step 2: Implement conflict detection**

`src/scanner/conflict.mbt`:

```moonbit
///|
/// Check if source contains a manual `impl World for <type> with register_steps` block.
/// Uses simple string matching — no AST parsing needed.
pub fn has_manual_registration(source : String, world_type : String) -> Bool {
  let needle = "impl @moonspec.World for " + world_type + " with register_steps"
  source.contains(needle)
}
```

**Step 3: Wire into cmd_gen_steps**

In the generation loop, before writing, scan all source files for manual registrations and emit warnings.

**Step 4: Run tests, commit**

```bash
git add src/scanner/conflict.mbt src/scanner/conflict_wbtest.mbt src/cmd/main/main.mbt
git commit -m "feat(scanner): add conflict detection for manual register_steps"
```

### Task 9: End-to-end integration test

**Files:**
- Create: `tests/gen_steps_wbtest.mbt` (or add to existing test location)

**Step 1: Write an end-to-end test**

Create a test that exercises the full pipeline: parse source → extract attributes → generate code → verify output is valid MoonBit.

```moonbit
test "end-to-end: scan and generate from attributed source" {
  let source =
    #|struct CucumberWorld { mut cucumbers : Int } derive(Default)
    #|
    #|#moonspec.given("I have {int} cucumbers")
    #|fn set_cukes(self : CucumberWorld, count : Int) -> Unit {
    #|  self.cucumbers = count
    #|}
    #|
    #|#moonspec.when("I eat {int} cucumbers")
    #|fn eat_cukes(self : CucumberWorld, count : Int) -> Unit {
    #|  self.cucumbers = self.cucumbers - count
    #|}
    #|
    #|#moonspec.then("I should have {int} cucumbers")
    #|fn check_cukes(self : CucumberWorld, count : Int) -> Unit raise Error {
    #|  assert_eq(self.cucumbers, count)
    #|}
  let result = @scanner.scan_source(source, name="test.mbt")
  assert_eq(result.step_fns.length(), 3)
  // Group by world type
  let steps = result.step_fns
  assert_eq(steps[0].world_type, "CucumberWorld")
  // Generate
  let code = @scanner.generate_register_steps("CucumberWorld", steps)
  assert_true(code.contains("impl @moonspec.World for CucumberWorld"))
  assert_true(code.contains("set_cukes(self"))
  assert_true(code.contains("eat_cukes(self"))
  assert_true(code.contains("check_cukes(self"))
}
```

**Step 2: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 3: Commit**

```bash
git add tests/
git commit -m "test: add end-to-end test for step codegen pipeline"
```

---

## Verification Checklist

After all tasks are complete:

- [ ] `moonspec gen` without subcommand shows help listing `tests` and `steps`
- [ ] `moonspec gen tests <files>` works identically to the old `moonspec gen`
- [ ] `moonspec gen steps` scans `.mbt` files and generates `register_steps`
- [ ] Hierarchical config: module-level `moonspec.json5` provides defaults
- [ ] Package-level `moonspec.json5` overrides module-level
- [ ] Mode can be a string or a per-file map
- [ ] Steps output mode is configurable (`generated`/`alongside`/`per-package`/custom)
- [ ] Hash-based staleness detection prevents unnecessary regeneration
- [ ] Conflict detection warns when manual `register_steps` exists
- [ ] All tests pass: `mise run test:unit`
