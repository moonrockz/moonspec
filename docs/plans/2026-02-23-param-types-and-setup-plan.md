# ParameterType Envelopes & Setup Facade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add custom parameter type registration via a new `Setup` facade, emit ParameterType envelopes, and improve type safety in cucumber-expressions.

**Architecture:** Work spans two repos: `cucumber-expressions` (type safety improvements, new accessor) and `moonspec` (Setup facade, ParameterType emission). cucumber-expressions changes land first, then moonspec updates its dependency and builds on top.

**Tech Stack:** MoonBit, cucumber-expressions v0.1.0 → v0.2.0, moonspec runner + core

---

## Phase A: cucumber-expressions Changes

All changes in `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`.

### Task 1: Add RegexPattern Newtype

**Files:**
- Modify: `src/param_type.mbt`
- Modify: `src/param_type_wbtest.mbt`

**Context:** `RegexPattern` wraps a `String` to make the type system explicit about regex patterns vs arbitrary strings. Uses MoonBit's struct constructor feature so users write `RegexPattern("pattern")`.

**Step 1: Write the failing test**

In `src/param_type_wbtest.mbt`, add at the end:

```moonbit
///|
test "RegexPattern round-trip" {
  let rp = RegexPattern("\\d+")
  assert_eq(rp.to_string(), "\\d+")
}

///|
test "RegexPattern equality" {
  let a = RegexPattern("abc")
  let b = RegexPattern("abc")
  let c = RegexPattern("xyz")
  assert_eq(a, b)
  assert_true(a != c)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `RegexPattern` not defined.

**Step 3: Write minimal implementation**

In `src/param_type.mbt`, add before the `ParamType` enum:

```moonbit
///|
/// A regex pattern used for matching parameter types in cucumber expressions.
pub(all) struct RegexPattern {
  priv value : String

  fn new(value : String) -> RegexPattern
} derive(Show, Eq)

///|
fn RegexPattern::new(value : String) -> RegexPattern {
  { value }
}

///|
pub fn RegexPattern::to_string(self : RegexPattern) -> String {
  self.value
}
```

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/param_type.mbt src/param_type_wbtest.mbt
git commit -m "feat: add RegexPattern newtype with struct constructor"
```

---

### Task 2: Add ParamTypeEntry and Refactor ParamTypeRegistry

**Files:**
- Modify: `src/param_type.mbt`
- Modify: `src/param_type_wbtest.mbt`
- Modify: `src/compiler.mbt`
- Modify: `src/expression.mbt`

**Context:** Replace the `(String, ParamType, Array[String])` tuple with a proper `ParamTypeEntry` struct. Make `entries` private. Add `entries_view()` accessor. Update `register()` and `get()` signatures to use new types. Update all internal callers.

**Step 1: Write the failing test**

In `src/param_type_wbtest.mbt`, add:

```moonbit
///|
test "ParamTypeEntry fields are accessible" {
  let entry : ParamTypeEntry = {
    name: "color",
    type_: ParamType::Custom("color"),
    patterns: [RegexPattern("red|blue|green")],
  }
  assert_eq(entry.name, "color")
  assert_eq(entry.type_, ParamType::Custom("color"))
  assert_eq(entry.patterns[0].to_string(), "red|blue|green")
}

///|
test "entries_view returns all registered types" {
  let reg = ParamTypeRegistry::default()
  let view = reg.entries_view()
  assert_eq(view.length(), 5)
  // First entry should be "int"
  assert_eq(view[0].name, "int")
  assert_eq(view[0].type_, ParamType::Int)
}

///|
test "get returns ParamTypeEntry" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("int")
  guard entry is Some(e)
  assert_eq(e.name, "int")
  assert_eq(e.type_, ParamType::Int)
  assert_true(e.patterns.length() > 0)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `ParamTypeEntry` and `entries_view()` not defined.

**Step 3: Write the implementation**

In `src/param_type.mbt`, replace the existing `ParamTypeRegistry` and related code:

```moonbit
///|
/// A registered parameter type entry with name, type, and regex patterns.
pub(all) struct ParamTypeEntry {
  name : String
  type_ : ParamType
  patterns : Array[RegexPattern]
} derive(Show, Eq)

///|
/// Registry mapping parameter type names to their regex patterns.
pub(all) struct ParamTypeRegistry {
  priv mut entries : Array[ParamTypeEntry]
}

///|
pub fn ParamTypeRegistry::new() -> ParamTypeRegistry {
  { entries: [] }
}

///|
/// Create a registry with the 5 built-in parameter types pre-registered.
pub fn ParamTypeRegistry::default() -> ParamTypeRegistry {
  let reg = ParamTypeRegistry::new()
  reg.register("int", ParamType::Int, [
    RegexPattern("(?:-?\\d+)"),
    RegexPattern("(?:\\d+)"),
  ])
  reg.register("float", ParamType::Float, [
    RegexPattern(
      "(?:[+-]?(?:\\d+|\\d+\\.\\d*|\\d*\\.\\d+)(?:[eE][+-]?\\d+)?)",
    ),
  ])
  reg.register("string", ParamType::String_, [
    RegexPattern("\"([^\"\\\\]*(\\\\.[^\"\\\\]*)*)\""),
    RegexPattern("'([^'\\\\]*(\\\\.[^'\\\\]*)*)'"),
  ])
  reg.register("word", ParamType::Word, [RegexPattern("[^\\s]+")])
  reg.register("", ParamType::Anonymous, [RegexPattern(".*")])
  reg
}

///|
pub fn ParamTypeRegistry::register(
  self : ParamTypeRegistry,
  name : String,
  type_ : ParamType,
  patterns : Array[RegexPattern],
) -> Unit {
  self.entries.push({ name, type_, patterns })
}

///|
pub fn ParamTypeRegistry::get(
  self : ParamTypeRegistry,
  name : String,
) -> ParamTypeEntry? {
  for entry in self.entries {
    if entry.name == name {
      return Some(entry)
    }
  }
  None
}

///|
/// Read-only view of all registered parameter type entries.
pub fn ParamTypeRegistry::entries_view(
  self : ParamTypeRegistry,
) -> ArrayView[ParamTypeEntry] {
  self.entries[:]
}
```

**Step 4: Update internal callers**

In `src/compiler.mbt`, update `compile()` at the `ParameterNode` match arm (line 31-52):

```moonbit
    ParameterNode(name) =>
      match registry.get(name) {
        Some(entry) => {
          let buf = StringBuilder::new()
          buf.write_char('(')
          for i, pat in entry.patterns {
            if i > 0 {
              buf.write_char('|')
            }
            buf.write_string("(?:")
            buf.write_string(pat.to_string())
            buf.write_char(')')
          }
          buf.write_char(')')
          buf.to_string()
        }
        None =>
          raise ExpressionError::UnknownParameterType(
            name~,
            message="Unknown parameter type: {" + name + "}",
          )
      }
```

In `src/expression.mbt`, update `collect_param_types()` (line 110-111):

```moonbit
        match registry.get(name) {
          Some(entry) => types.push(entry.type_)
          None => ()
        }
```

In `src/expression.mbt`, update `collect_group_counts()` (line 141-143):

```moonbit
        match registry.get(name) {
          Some(entry) => counts.push(count_capture_groups(entry.patterns))
          None => counts.push(1)
        }
```

In `src/expression.mbt`, update `count_capture_groups()` (line 167-173) to accept `Array[RegexPattern]`:

```moonbit
fn count_capture_groups(patterns : Array[RegexPattern]) -> Int {
  let mut count = 1
  for pat in patterns {
    count = count + count_groups_in_pattern(pat.to_string())
  }
  count
}
```

**Step 5: Update existing tests**

In `src/param_type_wbtest.mbt`, update the existing test that accesses `entries.length()`:

```moonbit
// Change: inspect(reg.entries.length(), content="5")
// To:
inspect(reg.entries_view().length(), content="5")
```

Update the custom type registration test to use `RegexPattern`:

```moonbit
// Change: reg.register("color", ParamType::Custom("color"), ["red|blue|green"])
// To:
reg.register("color", ParamType::Custom("color"), [RegexPattern("red|blue|green")])
```

In `src/custom_param_wbtest.mbt`, update all `register()` calls to use `RegexPattern`:

```moonbit
// Change: reg.register("color", ParamType::Custom("color"), ["red|blue|green"])
// To:
reg.register("color", ParamType::Custom("color"), [RegexPattern("red|blue|green")])
```

Do the same for "direction" and any other custom type registrations.

**Step 6: Run all tests**

Run: `mise run test:unit`
Expected: PASS

**Step 7: Commit**

```bash
git add src/param_type.mbt src/param_type_wbtest.mbt src/compiler.mbt src/expression.mbt src/custom_param_wbtest.mbt
git commit -m "feat!: add ParamTypeEntry, RegexPattern; make entries private

BREAKING CHANGE: ParamTypeRegistry.entries is now private.
Use entries_view() for read access. register() and get()
now use RegexPattern and ParamTypeEntry types."
```

---

### Task 3: Publish cucumber-expressions v0.2.0

**Files:**
- Modify: `moon.mod.json` (bump version)

**Step 1: Run moon fmt**

```bash
moon fmt
```

Revert any `.pkg` file changes if the new syntax breaks the build.

**Step 2: Regenerate .mbti**

```bash
moon info
```

**Step 3: Run full tests**

```bash
mise run test:unit
```

**Step 4: Bump version**

In `moon.mod.json`, change `"version": "0.1.0"` to `"version": "0.2.0"`.

**Step 5: Commit and publish**

```bash
git add .
git commit -m "chore: release v0.2.0"
moon publish
```

---

## Phase B: moonspec Changes

All changes in `/home/damian/code/repos/github/moonrockz/moonspec/` (in a new worktree).

### Task 4: Update cucumber-expressions Dependency

**Files:**
- Modify: `moon.mod.json`

**Step 1: Update dependency**

```bash
moon update
```

Or manually update `moon.mod.json` to reference cucumber-expressions v0.2.0.

**Step 2: Run tests to verify nothing breaks**

Run: `mise run test:unit`
Expected: FAIL — existing code uses the old tuple API for `ParamTypeRegistry`. This confirms the breaking change propagated.

**Step 3: Fix compilation errors**

In `src/core/registry.mbt`, update the `ParamTypeRegistry` usage. The registry is accessed via `self.param_registry` in `register_def()` — the `Expression::parse_with_registry()` call should still work since it takes `ParamTypeRegistry` by value. No changes needed here yet since `register_def` doesn't call `get()` directly.

If there are compilation errors from the tuple API changes, fix them now.

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add moon.mod.json
git commit -m "build: update cucumber-expressions to v0.2.0"
```

---

### Task 5: Update StepDefId to Struct Constructor

**Files:**
- Modify: `src/core/step_def.mbt`
- Modify: `src/core/step_def_wbtest.mbt`
- Modify: `src/core/registry.mbt` (update `from_string` call)

**Context:** Replace `StepDefId::from_string(value)` with struct constructor `StepDefId(value)` for consistency with `RegexPattern`.

**Step 1: Write the failing test**

In `src/core/step_def_wbtest.mbt`, update existing tests or add:

```moonbit
///|
test "StepDefId struct constructor" {
  let id = StepDefId("sd-1")
  assert_eq(id.to_string(), "sd-1")
}
```

**Step 2: Update StepDefId**

In `src/core/step_def.mbt`, replace:

```moonbit
// Old:
pub(all) struct StepDefId {
  priv value : String
} derive(Show, Eq, Hash)

pub fn StepDefId::from_string(value : String) -> StepDefId {
  { value }
}

// New:
pub(all) struct StepDefId {
  priv value : String

  fn new(value : String) -> StepDefId
} derive(Show, Eq, Hash)

fn StepDefId::new(value : String) -> StepDefId {
  { value }
}
```

Keep `to_string()` as-is.

**Step 3: Update all callers**

In `src/core/registry.mbt`, update `next_step_def_id()`:

```moonbit
// Change: StepDefId::from_string("sd-" + self.counter.to_string())
// To:
StepDefId("sd-" + self.counter.to_string())
```

Search for any other `StepDefId::from_string` references and update them.

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```bash
git add src/core/step_def.mbt src/core/step_def_wbtest.mbt src/core/registry.mbt
git commit -m "refactor(core): StepDefId uses struct constructor instead of from_string"
```

---

### Task 6: Introduce Setup Facade

**Files:**
- Create: `src/core/setup.mbt`
- Modify: `src/core/world.mbt`
- Modify: `src/core/registry.mbt`
- Create: `src/core/setup_wbtest.mbt`

**Context:** `Setup` wraps `StepRegistry` + `ParamTypeRegistry` as siblings. Users interact with `Setup` instead of `StepRegistry` directly. The `World` trait method changes from `register_steps(Self, StepRegistry)` to `configure(Self, Setup)`.

**Step 1: Write the failing test**

In `src/core/setup_wbtest.mbt`:

```moonbit
///|
test "Setup registers given step" {
  let setup = Setup::new()
  setup.given("a calculator", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 1)
}

///|
test "Setup registers when/then/step" {
  let setup = Setup::new()
  setup.when("I add {int}", fn(_args) {  })
  setup.then("the result is {int}", fn(_args) {  })
  setup.step("anything", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 3)
}

///|
test "Setup registers custom param type" {
  let setup = Setup::new()
  setup.add_param_type("color", [
    @cucumber_expressions.RegexPattern("red|blue|green"),
  ])
  setup.given("I pick a {color} cucumber", fn(_args) {  })
  assert_eq(setup.step_registry().len(), 1)
  // Verify the custom type is in the param registry
  let entries = setup.param_registry().entries_view()
  // 5 built-in + 1 custom = 6
  assert_eq(entries.length(), 6)
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit`
Expected: FAIL — `Setup` not defined.

**Step 3: Write the Setup implementation**

Create `src/core/setup.mbt`:

```moonbit
///|
/// User-facing configuration facade for registering steps and parameter types.
/// Wraps StepRegistry and ParamTypeRegistry as siblings.
pub(all) struct Setup {
  priv step_reg : StepRegistry
  priv param_reg : @cucumber_expressions.ParamTypeRegistry
}

///|
pub fn Setup::new() -> Setup {
  {
    step_reg: StepRegistry::new(),
    param_reg: @cucumber_expressions.ParamTypeRegistry::default(),
  }
}

///|
/// Access the underlying step registry (for runner internals).
pub fn Setup::step_registry(self : Setup) -> StepRegistry {
  self.step_reg
}

///|
/// Access the underlying param type registry (for runner internals).
pub fn Setup::param_registry(
  self : Setup,
) -> @cucumber_expressions.ParamTypeRegistry {
  self.param_reg
}

///|
/// Register a custom parameter type with name and regex patterns.
/// Must be called before registering steps that use the custom type.
pub fn Setup::add_param_type(
  self : Setup,
  name : String,
  patterns : Array[@cucumber_expressions.RegexPattern],
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns,
  )
}

///|
/// Register a Given step.
pub fn Setup::given(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Given,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a When step.
pub fn Setup::when(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::When,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a Then step.
pub fn Setup::then(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Then,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a step that matches any keyword.
pub fn Setup::step(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Step,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Compose a StepLibrary into this setup.
pub fn[L : StepLibrary] Setup::use_library(
  self : Setup,
  library : L,
) -> Unit {
  self.step_reg.use_library(library, self.param_reg)
}
```

**Step 4: Update StepRegistry to accept param_registry as parameter**

In `src/core/registry.mbt`, modify `StepRegistry`:

1. Remove `param_registry` field from struct:

```moonbit
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv id_gen : IdGenerator
}
```

2. Update `StepRegistry::new()`:

```moonbit
pub fn StepRegistry::new() -> StepRegistry {
  { entries: [], id_gen: IdGenerator::new() }
}
```

3. Update `register_def()` to take param_registry as parameter:

```moonbit
pub fn StepRegistry::register_def(
  self : StepRegistry,
  step_def : StepDef,
  param_registry : @cucumber_expressions.ParamTypeRegistry,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    step_def.pattern,
    param_registry,
  ) catch {
    _ => return
  }
  step_def.id = Some(self.id_gen.next_step_def_id())
  self.entries.push({ def: step_def, expression: expr })
}
```

4. Update `use_library()` similarly:

```moonbit
pub fn[L : StepLibrary] StepRegistry::use_library(
  self : StepRegistry,
  library : L,
  param_registry : @cucumber_expressions.ParamTypeRegistry,
) -> Unit {
  for step_def in library.steps() {
    self.register_def(step_def, param_registry)
  }
}
```

5. Remove the convenience methods `given`, `when`, `then`, `step` from StepRegistry (they live on Setup now). Also remove the private `register` helper.

**Step 5: Update World trait**

In `src/core/world.mbt`:

```moonbit
///|
/// Configuration trait. Users implement this on their world struct.
///
/// Called once per scenario with a fresh `Default`-constructed instance.
/// Closures registered via `Setup` capture `self`, sharing world
/// state between steps within the same scenario.
///
/// Example:
/// ```
/// struct MyWorld { mut count : Int } derive(Default)
///
/// impl @moonspec.World for MyWorld with configure(self, setup) {
///   setup.given("a count of {int}", fn(args) {
///     match args[0] { @moonspec.IntArg(n) => self.count = n | _ => () }
///   })
/// }
/// ```
pub(open) trait World {
  configure(Self, Setup) -> Unit
}
```

**Step 6: Run tests**

Run: `mise run test:unit`
Expected: FAIL — all World implementations still use `register_steps`. Fix in next task.

**Step 7: Commit (partial — compiles but tests fail due to callers)**

```bash
git add src/core/setup.mbt src/core/setup_wbtest.mbt src/core/world.mbt src/core/registry.mbt
git commit -m "feat(core)!: introduce Setup facade, rename World.register_steps to configure

BREAKING CHANGE: World trait method is now configure(Self, Setup)
instead of register_steps(Self, StepRegistry)."
```

---

### Task 7: Update All World Implementations

**Files:**
- Modify: `src/runner/run.mbt` (change `register_steps` calls to `configure`)
- Modify: `src/runner/run_wbtest.mbt`
- Modify: `src/runner/background_wbtest.mbt`
- Modify: `src/runner/e2e_wbtest.mbt`
- Modify: `src/runner/feature_wbtest.mbt`
- Modify: `src/runner/filter_wbtest.mbt`
- Modify: `src/runner/hooks_wbtest.mbt`
- Modify: `src/runner/parallel_wbtest.mbt`
- Modify: `examples/calculator/src/world.mbt`
- Modify: `examples/ecommerce/src/world.mbt`
- Modify: `examples/ecommerce-cli/src/world.mbt`
- Modify: `examples/bank-account/src/world.mbt`

**Context:** Every `impl World with register_steps(self, s)` becomes `impl World with configure(self, setup)`. The `s.given(...)` calls become `setup.given(...)`. The `s.use_library(...)` calls become `setup.use_library(...)`.

**Step 1: Update all test World implementations**

For each test file, change the pattern:

```moonbit
// Old:
impl @core.World for FooWorld with register_steps(_self, s) {
  s.given("a step", fn(_args) {  })
}

// New:
impl @core.World for FooWorld with configure(_self, setup) {
  setup.given("a step", fn(_args) {  })
}
```

**Step 2: Update runner calls**

In `src/runner/run.mbt`, find all calls to `@core.World::register_steps(world, registry)` and change them. The runner now creates a `Setup` instead of a `StepRegistry`:

```moonbit
// Old:
let registry = @core.StepRegistry::new()
@core.World::register_steps(world0, registry)

// New:
let setup = @core.Setup::new()
@core.World::configure(world0, setup)
let registry = setup.step_registry()
let param_registry = setup.param_registry()
```

Do this in both `run()` and `run_with_hooks()`. Also update `execute_pickle()` and `execute_pickle_with_hooks()` which create per-scenario registries:

```moonbit
// Old (in execute_pickle):
let registry = @core.StepRegistry::new()
@core.World::register_steps(world, registry)

// New:
let setup = @core.Setup::new()
@core.World::configure(world, setup)
let registry = setup.step_registry()
```

**Step 3: Update example world files**

Same pattern as test files. For examples using `use_library`:

```moonbit
// Old:
impl @moonspec.World for EcomWorld with register_steps(self, s) {
  s.use_library(CartSteps(self))
}

// New:
impl @moonspec.World for EcomWorld with configure(self, setup) {
  setup.use_library(CartSteps(self))
}
```

**Step 4: Update hooks test files**

In `hooks_wbtest.mbt`, there are direct `@core.World::register_steps(world, registry)` calls in test helper functions. Update those too.

**Step 5: Run tests**

Run: `mise run test:unit`
Expected: PASS

Run: `moon test --target js`
Expected: PASS

**Step 6: Commit**

```bash
git add src/runner/ examples/ src/core/
git commit -m "refactor: migrate all World implementations to configure(Setup)"
```

---

### Task 8: Emit ParameterType Envelopes

**Files:**
- Modify: `src/runner/run.mbt`
- Modify: `src/runner/planner.mbt`
- Modify: `src/runner/run_wbtest.mbt`

**Context:** Replace the TODO placeholders with actual ParameterType envelope emission. Filter out built-in types (only custom types get envelopes). Add ID generation with `"pt-N"` prefix.

**Step 1: Write the failing test**

In `src/runner/run_wbtest.mbt`, add a new World with a custom param type and test:

```moonbit
///|
struct ParamWorld {} derive(Default)

///|
impl @core.World for ParamWorld with configure(_self, setup) {
  setup.add_param_type("color", [
    @cucumber_expressions.RegexPattern("red|blue|green"),
  ])
  setup.given("I pick a {color} cucumber", fn(_args) {  })
}

///|
async test "run emits ParameterType envelopes for custom types" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt",
      "Feature: PT\n\n  Scenario: S\n    Given I pick a red cucumber\n",
    ),
  ]
  let _ = run(ParamWorld::default, features, sinks=[collector])
  let mut pt_count = 0
  for env in collector.envelopes {
    if env is @cucumber_messages.Envelope::ParameterType(_) {
      pt_count += 1
    }
  }
  // One custom type: "color"
  assert_eq(pt_count, 1)
}

///|
async test "run emits ParameterType after StepDefinition before TestCase" {
  let collector = CollectorSink::new()
  let features = [
    FeatureSource::Text(
      "test://pt-order",
      "Feature: PTO\n\n  Scenario: S\n    Given I pick a blue cucumber\n",
    ),
  ]
  let _ = run(ParamWorld::default, features, sinks=[collector])
  let mut sd_idx = -1
  let mut pt_idx = -1
  let mut tc_idx = -1
  for i, env in collector.envelopes {
    match env {
      @cucumber_messages.Envelope::StepDefinition(_) =>
        if sd_idx < 0 { sd_idx = i }
      @cucumber_messages.Envelope::ParameterType(_) =>
        if pt_idx < 0 { pt_idx = i }
      @cucumber_messages.Envelope::TestCase(_) =>
        if tc_idx < 0 { tc_idx = i }
      _ => ()
    }
  }
  assert_true(pt_idx > sd_idx)
  assert_true(pt_idx < tc_idx)
}
```

**Step 2: Run test to verify it fails**

Run: `moon test --target js`
Expected: FAIL — no ParameterType envelopes emitted.

**Step 3: Add IdGenerator method**

In `src/runner/planner.mbt`, add to IdGenerator:

```moonbit
///|
pub fn IdGenerator::next_param_type_id(self : IdGenerator) -> String {
  self.next("pt")
}
```

**Step 4: Implement ParameterType emission**

In `src/runner/run.mbt`, replace the TODO block in `run()` with:

```moonbit
// Emit ParameterType envelopes for custom parameter types
if sinks.length() > 0 {
  let builtin_names : Array[String] = ["int", "float", "string", "word", ""]
  for entry in param_registry.entries_view() {
    // Skip built-in types
    let mut is_builtin = false
    for name in builtin_names {
      if entry.name == name {
        is_builtin = true
        break
      }
    }
    if is_builtin {
      continue
    }
    let patterns_json : Array[Json] = []
    for pat in entry.patterns {
      patterns_json.push(pat.to_string().to_json())
    }
    let json : Json = {
      "parameterType": {
        "id": id_gen.next_param_type_id().to_json(),
        "name": entry.name.to_json(),
        "regularExpressions": patterns_json.to_json(),
        "preferForRegularExpressionMatch": false,
        "useForSnippets": true,
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
      _ => continue
    }
    emit(sinks, envelope)
  }
}
```

Apply the same change in `run_with_hooks()`.

**Step 5: Update the "no ParameterType for built-ins" test**

The existing test `"run emits no ParameterType envelopes for built-in types only"` should still pass since `RunWorld` has no custom types.

**Step 6: Run all tests**

Run: `mise run test:unit`
Run: `moon test --target js`
Expected: PASS

**Step 7: Commit**

```bash
git add src/runner/run.mbt src/runner/planner.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): emit ParameterType envelopes for custom parameter types"
```

---

### Task 9: Final Cleanup

**Files:**
- Various (formatting, mbti regeneration)

**Step 1: Run moon fmt**

```bash
moon fmt
```

Revert any `.pkg` file changes if new syntax breaks build.

**Step 2: Regenerate .mbti files**

```bash
moon info
```

**Step 3: Run full test suite**

```bash
mise run test:unit
moon test --target js
```

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: moon fmt and regenerate mbti interfaces"
```

---

## Execution Order Summary

| Task | Package | Description |
|------|---------|-------------|
| 1 | cucumber-expressions | Add RegexPattern newtype |
| 2 | cucumber-expressions | Add ParamTypeEntry, refactor registry |
| 3 | cucumber-expressions | Publish v0.2.0 |
| 4 | moonspec | Update dependency to v0.2.0 |
| 5 | moonspec | StepDefId struct constructor |
| 6 | moonspec | Introduce Setup facade |
| 7 | moonspec | Update all World implementations |
| 8 | moonspec | Emit ParameterType envelopes |
| 9 | moonspec | Final cleanup |
