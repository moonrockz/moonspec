# Step Definitions (moonspec-mlp) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add first-class StepDef type, StepLibrary trait, MoonspecError suberror hierarchy, undefined step diagnostics, and run! throwing variant.

**Architecture:** Bottom-up: new core types first (StepDef, StepKeyword, StepSource), then StepLibrary trait, then MoonspecError, then registry refactor, then executor changes, then runner run! variant, then snippet/suggest utilities, then facade re-exports, then codegen update.

**Tech Stack:** MoonBit, moonrockz/cucumber-expressions, moonrockz/gherkin

---

### Task 1: StepDef, StepKeyword, StepSource types

**Files:**
- Create: `src/core/step_def.mbt`
- Test: `src/core/step_def_wbtest.mbt`

**Step 1: Write the failing tests**

```moonbit
///|
test "StepDef::given creates Given keyword" {
  let def = StepDef::given("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Given)
  assert_eq(def.pattern, "a step")
  assert_true(def.source is None)
}

///|
test "StepDef::when creates When keyword" {
  let def = StepDef::when("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::When)
}

///|
test "StepDef::then creates Then keyword" {
  let def = StepDef::then("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Then)
}

///|
test "StepDef::step creates Step keyword" {
  let def = StepDef::step("a step", StepHandler(fn(_args) {  }))
  assert_eq(def.keyword, StepKeyword::Step)
}

///|
test "StepDef with source" {
  let def = StepDef::given(
    "a step",
    StepHandler(fn(_args) {  }),
    source=StepSource::new(uri="test.mbt", line=42),
  )
  assert_true(def.source is Some(_))
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `StepDef`, `StepKeyword`, `StepSource` not defined

**Step 3: Write minimal implementation**

```moonbit
///|
/// Keyword classification for a step definition.
pub(all) enum StepKeyword {
  Given
  When
  Then
  Step
} derive(Show, Eq)

///|
/// Optional source location for a step definition (populated by codegen).
pub(all) struct StepSource {
  uri : String?
  line : Int?
} derive(Show, Eq)

///|
pub fn StepSource::new(uri~ : String = "", line~ : Int = 0) -> StepSource {
  {
    uri: if uri == "" { None } else { Some(uri) },
    line: if line == 0 { None } else { Some(line) },
  }
}

///|
/// A first-class step definition: keyword, pattern, handler, and optional source.
pub(all) struct StepDef {
  keyword : StepKeyword
  pattern : String
  handler : StepHandler
  source : StepSource?
}

///|
pub fn StepDef::given(
  pattern : String,
  handler : StepHandler,
  source? : StepSource,
) -> StepDef {
  { keyword: Given, pattern, handler, source }
}

///|
pub fn StepDef::when(
  pattern : String,
  handler : StepHandler,
  source? : StepSource,
) -> StepDef {
  { keyword: When, pattern, handler, source }
}

///|
pub fn StepDef::then(
  pattern : String,
  handler : StepHandler,
  source? : StepSource,
) -> StepDef {
  { keyword: Then, pattern, handler, source }
}

///|
pub fn StepDef::step(
  pattern : String,
  handler : StepHandler,
  source? : StepSource,
) -> StepDef {
  { keyword: Step, pattern, handler, source }
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```
feat(core): add StepDef, StepKeyword, StepSource types

First-class step definition type with keyword classification,
pattern, handler, and optional source location metadata.
```

---

### Task 2: StepLibrary trait

**Files:**
- Create: `src/core/step_library.mbt`
- Test: `src/core/step_library_wbtest.mbt`

**Step 1: Write the failing tests**

```moonbit
///|
struct TestWorld {
  mut value : Int
}

///|
struct MathSteps {
  world : TestWorld
}

///|
impl StepLibrary for MathSteps with steps(self) {
  [
    StepDef::given("a value of {int}", StepHandler(fn(args) {
      match args[0] {
        StepArg::IntArg(n) => self.world.value = n
        _ => ()
      }
    })),
    StepDef::then("the value is {int}", StepHandler(fn(args) raise {
      match args[0] {
        StepArg::IntArg(n) => assert_eq(self.world.value, n)
        _ => ()
      }
    })),
  ][:]
}

///|
test "StepLibrary returns ArrayView of StepDefs" {
  let world = { value: 0 }
  let lib = MathSteps::new(world)
  let defs = lib.steps()
  assert_eq(defs.length(), 2)
  assert_eq(defs[0].keyword, StepKeyword::Given)
  assert_eq(defs[1].keyword, StepKeyword::Then)
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `StepLibrary` trait not defined

**Step 3: Write minimal implementation**

```moonbit
///|
/// A composable group of step definitions.
///
/// Implement this on structs that provide reusable step definitions.
/// Libraries return an immutable view of their steps via `ArrayView`.
///
/// Example:
/// ```
/// struct AuthSteps { world : MyWorld }
///
/// impl StepLibrary for AuthSteps with steps(self) {
///   [
///     StepDef::given("I am logged in", StepHandler(fn(_args) {
///       self.world.logged_in = true
///     })),
///   ][:]
/// }
/// ```
pub(open) trait StepLibrary {
  steps(Self) -> ArrayView[StepDef]
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```
feat(core): add StepLibrary trait

Composable step definition groups returning ArrayView[StepDef].
```

---

### Task 3: MoonspecError suberror hierarchy

**Files:**
- Create: `src/core/error.mbt`
- Test: `src/core/error_wbtest.mbt`

**Step 1: Write the failing tests**

```moonbit
///|
test "UndefinedStep carries step text and snippet" {
  let err : Error = UndefinedStep(
    step="I have 5 bananas",
    keyword="Given",
    snippet="s.given(\"I have {int} bananas\", fn(args) { ... })",
    suggestions=["I have {int} cucumbers"],
  )
  match err {
    UndefinedStep(step~, keyword~, snippet~, suggestions~) => {
      assert_eq(step, "I have 5 bananas")
      assert_eq(keyword, "Given")
      assert_true(snippet.length() > 0)
      assert_eq(suggestions.length(), 1)
    }
    _ => fail!("expected UndefinedStep")
  }
}

///|
test "PendingStep carries message" {
  let err : Error = PendingStep(
    step="a pending step",
    keyword="Given",
    message="TODO: implement",
  )
  match err {
    PendingStep(step~, ..) => assert_eq(step, "a pending step")
    _ => fail!("expected PendingStep")
  }
}

///|
test "ScenarioFailed aggregates step errors" {
  let step_errors : Array[MoonspecError] = [
    UndefinedStep(
      step="undefined one",
      keyword="Given",
      snippet="",
      suggestions=[],
    ),
    StepFailed(step="failed one", keyword="Then", message="assertion failed"),
  ]
  let err : Error = ScenarioFailed(
    scenario="My Scenario",
    feature="My Feature",
    errors=step_errors,
  )
  match err {
    ScenarioFailed(errors~, ..) => assert_eq(errors.length(), 2)
    _ => fail!("expected ScenarioFailed")
  }
}

///|
test "RunFailed aggregates scenario errors" {
  let scenario_errors : Array[MoonspecError] = [
    ScenarioFailed(scenario="S1", feature="F1", errors=[]),
  ]
  let err : Error = RunFailed(
    summary="1 scenario failed",
    errors=scenario_errors,
  )
  match err {
    RunFailed(summary~, errors~) => {
      assert_eq(summary, "1 scenario failed")
      assert_eq(errors.length(), 1)
    }
    _ => fail!("expected RunFailed")
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `MoonspecError` not defined

**Step 3: Write minimal implementation**

```moonbit
///|
/// Structured error hierarchy for moonspec.
///
/// Step-level errors aggregate into ScenarioFailed, which aggregates
/// into RunFailed. This enables rich diagnostics and the `run!` API.
pub suberror MoonspecError {
  UndefinedStep(
    step~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String],
  )
  PendingStep(
    step~ : String,
    keyword~ : String,
    message~ : String,
  )
  StepFailed(
    step~ : String,
    keyword~ : String,
    message~ : String,
  )
  ScenarioFailed(
    scenario~ : String,
    feature~ : String,
    errors~ : Array[MoonspecError],
  )
  RunFailed(
    summary~ : String,
    errors~ : Array[MoonspecError],
  )
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```
feat(core): add MoonspecError suberror hierarchy

Structured errors: UndefinedStep, PendingStep, StepFailed,
ScenarioFailed, RunFailed with aggregation support.
```

---

### Task 4: StepMatchResult type and registry refactor

**Files:**
- Modify: `src/core/types.mbt` — add StepMatchResult
- Modify: `src/core/registry.mbt` — replace StepEntry with StepDef, add use_library/register_def, change find_match return type
- Modify: `src/core/registry_wbtest.mbt` — update tests for new find_match return type
- Test: `src/core/registry_wbtest.mbt` — add use_library tests

**Step 1: Add StepMatchResult to types.mbt**

Add after `StepArg` definition in `src/core/types.mbt`:

```moonbit
///|
/// Result of matching step text against the registry.
pub(all) enum StepMatchResult {
  Matched(StepDef, Array[StepArg])
  Undefined(
    step_text~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String],
  )
} derive(Show)
```

**Step 2: Write new registry tests**

Add to `src/core/registry_wbtest.mbt`:

```moonbit
///|
test "StepRegistry find_match returns Matched" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  match reg.find_match("I have 42 cucumbers") {
    Matched(step_def, args) => {
      assert_eq(step_def.keyword, StepKeyword::Given)
      assert_eq(args[0], StepArg::IntArg(42))
    }
    _ => fail!("expected Matched")
  }
}

///|
test "StepRegistry find_match returns Undefined with snippet" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  match reg.find_match("I have many bananas") {
    Undefined(step_text~, snippet~, ..) => {
      assert_eq(step_text, "I have many bananas")
      assert_true(snippet.length() > 0)
    }
    _ => fail!("expected Undefined")
  }
}

///|
test "StepRegistry use_library registers library steps" {
  let reg = StepRegistry::new()
  let world = { value: 0 }
  let lib = MathSteps::new(world)
  reg.use_library(lib)
  assert_true(reg.find_match("a value of 5") is Matched(..))
}

///|
test "StepRegistry register_def registers a StepDef directly" {
  let reg = StepRegistry::new()
  let def = StepDef::given("hello world", StepHandler(fn(_args) {  }))
  reg.register_def(def)
  assert_eq(reg.len(), 1)
  assert_true(reg.find_match("hello world") is Matched(..))
}
```

Note: `MathSteps` struct and `StepLibrary` impl are defined in `step_library_wbtest.mbt` from Task 2. Since both are in the same `core` package, they are visible here.

**Step 3: Refactor registry.mbt**

Replace `StepEntry` with compiled step entries that carry `StepDef`. The internal type becomes:

```moonbit
///|
/// Internal: a compiled step entry pairing a StepDef with its parsed expression.
struct CompiledStep {
  def : StepDef
  expression : @cucumber_expressions.Expression
}

///|
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv param_registry : @cucumber_expressions.ParamTypeRegistry
}

///|
pub fn StepRegistry::new() -> StepRegistry {
  {
    entries: [],
    param_registry: @cucumber_expressions.ParamTypeRegistry::default(),
  }
}

///|
pub fn StepRegistry::len(self : StepRegistry) -> Int {
  self.entries.length()
}

///|
/// Register a StepDef directly.
pub fn StepRegistry::register_def(self : StepRegistry, step_def : StepDef) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    step_def.pattern,
    self.param_registry,
  ) catch {
    _ => return
  }
  self.entries.push({ def: step_def, expression: expr })
}

///|
/// Compose a StepLibrary into this registry.
pub fn StepRegistry::use_library[L : StepLibrary](
  self : StepRegistry,
  library : L,
) -> Unit {
  for step_def in library.steps() {
    self.register_def(step_def)
  }
}

///|
fn StepRegistry::register(
  self : StepRegistry,
  keyword : StepKeyword,
  pattern : String,
  handler : StepHandler,
) -> Unit {
  self.register_def({ keyword, pattern, handler, source: None })
}

///|
pub fn StepRegistry::given(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Given, pattern, StepHandler(handler))
}

///|
pub fn StepRegistry::when(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::When, pattern, StepHandler(handler))
}

///|
pub fn StepRegistry::then(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Then, pattern, StepHandler(handler))
}

///|
pub fn StepRegistry::step(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Step, pattern, StepHandler(handler))
}

///|
/// Find a matching step definition for the given step text.
/// Returns Matched with StepDef + extracted args, or Undefined with diagnostics.
pub fn StepRegistry::find_match(
  self : StepRegistry,
  text : String,
  keyword? : String = "* ",
) -> StepMatchResult {
  for entry in self.entries {
    match entry.expression.match_(text) {
      Some(m) => {
        let args = m.params.map(StepArg::from_param)
        return Matched(entry.def, args)
      }
      None => continue
    }
  }
  let snippet = generate_snippet(text, keyword)
  let suggestions = find_suggestions(self, text)
  Undefined(step_text=text, keyword~, snippet~, suggestions~)
}
```

**Step 4: Update existing registry tests**

Update `src/core/registry_wbtest.mbt` — change tests that use old `Option` return:

- `"StepRegistry matches step text"`: change `assert_true(result is Some(_))` → `assert_true(result is Matched(..))`
- `"StepRegistry returns None for no match"`: change `assert_true(result is None)` → `assert_true(result is Undefined(..))`
- `"StepRegistry extracts parameters"`: change `let (_, args, _) = reg.find_match(...).unwrap()` → use `match` with `Matched(_, args)`

**Step 5: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS (core tests). Runner tests may fail — that's expected, we fix them in Task 6.

**Step 6: Commit**

```
feat(core): refactor StepRegistry to use StepDef and StepMatchResult

Replace StepEntry with CompiledStep wrapping StepDef. find_match
returns StepMatchResult with diagnostics on miss. Add use_library
and register_def methods.
```

---

### Task 5: Snippet generation and fuzzy suggestions

**Files:**
- Create: `src/core/snippet.mbt`
- Create: `src/core/suggest.mbt`
- Test: `src/core/snippet_wbtest.mbt`
- Test: `src/core/suggest_wbtest.mbt`

Note: These go in `src/core/` (not `src/runner/`) because `find_match` in `registry.mbt` calls them directly.

**Step 1: Write snippet tests**

```moonbit
///|
test "generate_snippet for plain step text" {
  let snippet = generate_snippet("hello world", "Given ")
  assert_true(snippet.contains("s.given"))
  assert_true(snippet.contains("hello world"))
  assert_true(snippet.contains("PendingStep"))
}

///|
test "generate_snippet detects integer parameters" {
  let snippet = generate_snippet("I have 42 cucumbers", "Given ")
  assert_true(snippet.contains("{int}"))
}

///|
test "generate_snippet detects quoted string parameters" {
  let snippet = generate_snippet("I say \"hello\"", "When ")
  assert_true(snippet.contains("{string}"))
}

///|
test "generate_snippet for Then keyword" {
  let snippet = generate_snippet("the result is 5", "Then ")
  assert_true(snippet.contains("s.then"))
}

///|
test "generate_snippet for unknown keyword uses step" {
  let snippet = generate_snippet("something", "* ")
  assert_true(snippet.contains("s.step"))
}
```

**Step 2: Write suggestion tests**

```moonbit
///|
test "levenshtein_distance identical strings" {
  assert_eq(levenshtein_distance("abc", "abc"), 0)
}

///|
test "levenshtein_distance one edit" {
  assert_eq(levenshtein_distance("abc", "abd"), 1)
}

///|
test "levenshtein_distance empty strings" {
  assert_eq(levenshtein_distance("", "abc"), 3)
  assert_eq(levenshtein_distance("abc", ""), 3)
}

///|
test "find_suggestions returns close matches" {
  let reg = StepRegistry::new()
  reg.given("I have {int} cucumbers", fn(_args) {  })
  reg.given("I have {int} tomatoes", fn(_args) {  })
  reg.given("something completely different", fn(_args) {  })
  let suggestions = find_suggestions(reg, "I have many cucumbers")
  assert_true(suggestions.length() > 0)
  assert_true(suggestions.length() <= 3)
}
```

**Step 3: Write snippet implementation**

```moonbit
///|
/// Generate a code snippet for implementing an undefined step.
///
/// Detects potential cucumber expression parameters in the step text:
/// integers become {int}, quoted strings become {string}, decimals become {float}.
fn generate_snippet(step_text : String, keyword : String) -> String {
  let method = match keyword {
    "Given " => "given"
    "When " => "when"
    "Then " => "then"
    _ => "step"
  }
  let pattern = infer_pattern(step_text)
  let buf = StringBuilder::new()
  buf.write_string("s.")
  buf.write_string(method)
  buf.write_string("(\"")
  buf.write_string(pattern)
  buf.write_string("\", fn(args) raise {\n")
  buf.write_string("  raise PendingStep(step=\"")
  buf.write_string(pattern)
  buf.write_string("\", keyword=\"")
  buf.write_string(keyword.trim_end(" "))
  buf.write_string("\", message=\"TODO: implement step\")\n")
  buf.write_string("})")
  buf.to_string()
}

///|
/// Infer cucumber expression pattern from concrete step text.
/// Replaces integers with {int}, quoted strings with {string}, decimals with {float}.
fn infer_pattern(text : String) -> String {
  let buf = StringBuilder::new()
  let len = text.length()
  let mut i = 0
  while i < len {
    let ch = text[i]
    // Detect quoted strings: "..."
    if ch == '"' {
      let mut j = i + 1
      while j < len && text[j] != '"' {
        j = j + 1
      }
      if j < len {
        buf.write_string("{string}")
        i = j + 1
        continue
      }
    }
    // Detect numbers: sequences of digits, optionally with decimal point
    if ch >= '0' && ch <= '9' {
      let mut j = i
      let mut has_dot = false
      while j < len && ((text[j] >= '0' && text[j] <= '9') || (text[j] == '.' && !has_dot)) {
        if text[j] == '.' { has_dot = true }
        j = j + 1
      }
      if has_dot {
        buf.write_string("{float}")
      } else {
        buf.write_string("{int}")
      }
      i = j
      continue
    }
    buf.write_char(ch.to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}
```

**Step 4: Write suggestion implementation**

```moonbit
///|
/// Compute Levenshtein edit distance between two strings.
fn levenshtein_distance(a : String, b : String) -> Int {
  let m = a.length()
  let n = b.length()
  if m == 0 { return n }
  if n == 0 { return m }
  // Use two rows for space efficiency
  let mut prev : Array[Int] = Array::make(n + 1, 0)
  let mut curr : Array[Int] = Array::make(n + 1, 0)
  for j = 0; j <= n; j = j + 1 {
    prev[j] = j
  }
  for i = 1; i <= m; i = i + 1 {
    curr[0] = i
    for j = 1; j <= n; j = j + 1 {
      let cost = if a[i - 1] == b[j - 1] { 0 } else { 1 }
      let del = prev[j] + 1
      let ins = curr[j - 1] + 1
      let sub = prev[j - 1] + cost
      curr[j] = min(del, min(ins, sub))
    }
    let tmp = prev
    prev = curr
    curr = tmp
  }
  prev[n]
}

///|
fn min(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

///|
/// Normalize a pattern for comparison: replace {int}, {string}, etc. with placeholders.
fn normalize_pattern(pattern : String) -> String {
  let buf = StringBuilder::new()
  let len = pattern.length()
  let mut i = 0
  while i < len {
    if pattern[i] == '{' {
      let mut j = i + 1
      while j < len && pattern[j] != '}' {
        j = j + 1
      }
      if j < len {
        buf.write_string("_")
        i = j + 1
        continue
      }
    }
    buf.write_char(pattern[i].to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}

///|
/// Find up to 3 registered step patterns closest to the given step text.
fn find_suggestions(registry : StepRegistry, text : String) -> Array[String] {
  let normalized_text = normalize_pattern(text)
  let candidates : Array[(String, Int)] = []
  for entry in registry.entries {
    let normalized_pattern = normalize_pattern(entry.def.pattern)
    let dist = levenshtein_distance(normalized_text, normalized_pattern)
    // Only suggest if distance is within half the text length (reasonable threshold)
    let threshold = normalized_text.length() / 2
    if dist <= threshold && dist > 0 {
      candidates.push((entry.def.pattern, dist))
    }
  }
  candidates.sort_by(fn(a, b) { a.1.compare(b.1) })
  let result : Array[String] = []
  let limit = if candidates.length() < 3 { candidates.length() } else { 3 }
  for i = 0; i < limit; i = i + 1 {
    result.push(candidates[i].0)
  }
  result
}
```

**Step 5: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 6: Commit**

```
feat(core): add snippet generation and fuzzy step suggestions

Undefined steps produce copy-paste snippets with inferred cucumber
expression parameters. Levenshtein-based fuzzy matching suggests
closest registered patterns.
```

---

### Task 6: Executor changes

**Files:**
- Modify: `src/runner/executor.mbt` — consume StepMatchResult, catch PendingStep, carry diagnostics
- Modify: `src/runner/results.mbt` — add diagnostic field to StepResult
- Modify: `src/runner/executor_wbtest.mbt` — update tests

**Step 1: Add diagnostic field to StepResult**

In `src/runner/results.mbt`, add `diagnostic` field to `StepResult`:

```moonbit
pub(all) struct StepResult {
  text : String
  keyword : String
  status : StepStatus
  duration_ms : Int64
  diagnostic : @core.MoonspecError?
} derive(Show, Eq)
```

**Step 2: Update execute_scenario in executor.mbt**

Change the match on `find_match` from `None/Some` to `Matched/Undefined`, add `PendingStep` catch, and carry diagnostics:

In `execute_scenario` (lines 29-37), replace:
```moonbit
    let status = match registry.find_match(step.text) {
      None => StepStatus::Undefined
      Some((handler, args, _)) =>
        try {
          (handler.0)(args)
          StepStatus::Passed
        } catch {
          e => StepStatus::Failed(e.to_string())
        }
    }
```

With:
```moonbit
    let (status, diagnostic) : (StepStatus, @core.MoonspecError?) = match registry.find_match(step.text, keyword~=keyword) {
      Undefined(step_text~, keyword=kw~, snippet~, suggestions~) =>
        (StepStatus::Undefined, Some(@core.UndefinedStep(step=step_text, keyword=kw, snippet~, suggestions~)))
      Matched(step_def, args) =>
        try {
          (step_def.handler.0)(args)
          (StepStatus::Passed, None)
        } catch {
          @core.PendingStep(step~, keyword=kw~, message~) =>
            (StepStatus::Pending, Some(@core.PendingStep(step~, keyword=kw, message~)))
          e => (StepStatus::Failed(e.to_string()), Some(@core.StepFailed(step=step.text, keyword~=keyword, message=e.to_string())))
        }
    }
```

Update `step_results.push` to include `diagnostic`:
```moonbit
    step_results.push({ text: step.text, keyword, status, duration_ms: 0L, diagnostic })
```

Also update all other `step_results.push` calls (e.g., for skipped steps) to include `diagnostic: None`.

Apply the same changes to `execute_scenario_with_hooks`.

**Step 3: Update executor tests**

In `executor_wbtest.mbt`, update test assertions. Existing tests should still pass since we're only adding a new field. But we need to verify the diagnostic is populated:

Add new test:
```moonbit
///|
test "execute_scenario carries UndefinedStep diagnostic" {
  let registry = @core.StepRegistry::new()
  registry.given("I have {int} cucumbers", fn(_args) {  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "an undefined step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Diagnostic test",
    pickle_id="test-pickle-diag",
    tags=[],
    steps~,
  )
  assert_eq(result.steps[0].status, StepStatus::Undefined)
  assert_true(result.steps[0].diagnostic is Some(_))
}

///|
test "execute_scenario catches PendingStep" {
  let registry = @core.StepRegistry::new()
  registry.given("a pending step", fn(_args) raise {
    raise @core.PendingStep(step="a pending step", keyword="Given", message="TODO")
  })
  let steps : Array[@cucumber_messages.PickleStep] = [
    {
      id: "s1",
      text: "a pending step",
      astNodeIds: [],
      type_: Some(@cucumber_messages.PickleStepType::Context),
      argument: None,
    },
  ]
  let result = execute_scenario(
    registry,
    feature_name="Test Feature",
    scenario_name="Pending test",
    pickle_id="test-pickle-pending",
    tags=[],
    steps~,
  )
  assert_eq(result.steps[0].status, StepStatus::Pending)
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS (all tests including updated executor tests)

**Step 5: Commit**

```
feat(runner): update executor for StepMatchResult and PendingStep

Executor now consumes StepMatchResult, catches PendingStep for
Pending status, and carries MoonspecError diagnostics in StepResult.
```

---

### Task 7: run! throwing variant

**Files:**
- Modify: `src/runner/run.mbt` — add run_or_fail! function
- Test: `src/runner/run_wbtest.mbt` — add tests for run_or_fail!

**Step 1: Write the failing tests**

Add to `src/runner/run_wbtest.mbt`:

```moonbit
///|
struct PassWorld {} derive(Default)

impl @core.World for PassWorld with register_steps(_self, s) {
  s.given("a calculator", fn(_args) {  })
}

///|
async test "run_or_fail succeeds when all pass" {
  let content = "Feature: Simple\n\n  Scenario: Pass\n    Given a calculator\n"
  let result = run_or_fail!(
    PassWorld::default,
    [FeatureSource::Text("test://pass", content)],
  )
  assert_eq(result.summary.passed, 1)
}

///|
struct EmptyWorld {} derive(Default)

impl @core.World for EmptyWorld with register_steps(_self, _s) {  }

///|
async test "run_or_fail raises RunFailed on undefined steps" {
  let content = "Feature: Fail\n\n  Scenario: Undefined\n    Given an undefined step\n"
  let mut caught = false
  try {
    run_or_fail!(EmptyWorld::default, [FeatureSource::Text("test://fail", content)])
    |> ignore
  } catch {
    @core.RunFailed(..) => caught = true
    _ => ()
  }
  assert_true(caught)
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `run_or_fail!` not defined

**Step 3: Write implementation**

Add to `src/runner/run.mbt`:

```moonbit
///|
/// Run all features, raising MoonspecError on any failure.
///
/// This is the ergonomic test API. Use in generated tests and manual tests
/// where you want structured error output instead of manual result inspection.
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
) -> RunResult raise @core.MoonspecError {
  let result = run(factory, features, tag_expr~, scenario_name~, parallel~)
  if result.summary.failed > 0 || result.summary.undefined > 0 || result.summary.pending > 0 {
    let errors = collect_scenario_errors(result)
    let summary = format_summary(result.summary)
    raise @core.RunFailed(summary~, errors~)
  }
  result
}

///|
/// Collect MoonspecError for each non-passing scenario.
fn collect_scenario_errors(result : RunResult) -> Array[@core.MoonspecError] {
  let errors : Array[@core.MoonspecError] = []
  for feature in result.features {
    for scenario in feature.scenarios {
      match scenario.status {
        ScenarioStatus::Passed => continue
        _ => {
          let step_errors : Array[@core.MoonspecError] = []
          for step in scenario.steps {
            match step.diagnostic {
              Some(err) => step_errors.push(err)
              None => ()
            }
          }
          errors.push(@core.ScenarioFailed(
            scenario=scenario.scenario_name,
            feature=feature.name,
            errors=step_errors,
          ))
        }
      }
    }
  }
  errors
}

///|
fn format_summary(summary : RunSummary) -> String {
  let parts : Array[String] = []
  if summary.failed > 0 {
    parts.push(summary.failed.to_string() + " failed")
  }
  if summary.undefined > 0 {
    parts.push(summary.undefined.to_string() + " undefined")
  }
  if summary.pending > 0 {
    parts.push(summary.pending.to_string() + " pending")
  }
  parts.push(summary.total_scenarios.to_string() + " total")
  parts.join(", ")
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 5: Commit**

```
feat(runner): add run_or_fail! throwing variant

Raises MoonspecError::RunFailed with structured error tree on any
non-passing scenario. Replaces assert_eq(result.summary.failed, 0)
pattern in tests.
```

---

### Task 8: Facade re-exports

**Files:**
- Modify: `src/lib.mbt` — re-export new types

**Step 1: Update facade**

Replace `src/lib.mbt` with:

```moonbit
///|
/// moonspec — BDD test framework for MoonBit.
///
/// Re-exports core types and runner functions so users import just
/// `moonrockz/moonspec` and use `@moonspec.World`, `@moonspec.run`, etc.
pub using @core {
  trait World,
  trait Hooks,
  trait StepLibrary,
  type StepRegistry,
  type StepDef,
  type StepArg,
  type StepKeyword,
  type StepSource,
  type StepMatchResult,
  suberror MoonspecError,
  type ScenarioInfo,
  type StepInfo,
}

///|
pub using @runner {type FeatureSource, run, run_with_hooks, run_or_fail}
```

Note: Verify `suberror MoonspecError` is the correct `pub using` syntax for suberrors — it may need to be `type MoonspecError` or `type! MoonspecError`. Check `moon check --all` and adjust.

**Step 2: Run full check**

Run: `moon check --all && mise run test:unit`
Expected: PASS

**Step 3: Commit**

```
feat: re-export new step definition types in facade

Adds StepLibrary, StepDef, StepKeyword, StepSource,
StepMatchResult, MoonspecError, and run_or_fail to public API.
```

---

### Task 9: Update codegen to use run_or_fail!

**Files:**
- Modify: `src/codegen/codegen.mbt` — change generated test code
- Modify: `src/codegen/codegen_wbtest.mbt` — update expected output

**Step 1: Update codegen output**

In `src/codegen/codegen.mbt`, change `generate_per_feature` (line 186-193) and `generate_scenario_runner_test` (line 260-275) to use `run_or_fail!` instead of `run` + `assert_eq`:

In `generate_per_feature`, replace:
```moonbit
    buf.write_string(
      "  let result = @moonspec.run(\n    " +
      config.world +
      "::default, [@moonspec.FeatureSource::File(\"" +
      escape_string(source_path) +
      "\")],\n  )\n",
    )
    buf.write_string("  assert_eq!(result.summary.failed, 0)\n")
```

With:
```moonbit
    buf.write_string(
      "  @moonspec.run_or_fail!(\n    " +
      config.world +
      "::default, [@moonspec.FeatureSource::File(\"" +
      escape_string(source_path) +
      "\")],\n  )\n",
    )
```

Apply similar change to `generate_scenario_runner_test`.

**Step 2: Update codegen tests**

Update `src/codegen/codegen_wbtest.mbt` — change expected output strings from `assert_eq!(result.summary.failed, 0)` to `@moonspec.run_or_fail!`.

**Step 3: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: PASS

**Step 4: Commit**

```
feat(codegen): generate run_or_fail! in test files

Generated tests now use run_or_fail! for structured error output
instead of assert_eq!(result.summary.failed, 0).
```

---

### Task 10: Update e2e and remaining test files

**Files:**
- Modify: `src/runner/e2e_wbtest.mbt` — verify existing tests still pass with new StepResult shape
- Modify: Any other test files that broke from StepResult gaining `diagnostic` field

**Step 1: Check for compilation errors**

Run: `moon check --all`

Look for errors related to:
- `StepResult` struct literal missing `diagnostic` field
- `find_match` return type changes in test files outside core

**Step 2: Fix any breakages**

For any test file that constructs `StepResult` literals directly, add `diagnostic: None`. For test files that pattern-match on `find_match` results, update from `Some/None` to `Matched/Undefined`.

**Step 3: Run full test suite**

Run: `mise run test:unit`
Expected: ALL PASS

**Step 4: Commit**

```
fix: update remaining tests for new StepResult and StepMatchResult types
```

---

### Task 11: Final verification

**Step 1: Full build check**

Run: `moon check --all`
Expected: No errors

**Step 2: Full test suite**

Run: `mise run test:unit`
Expected: ALL PASS

**Step 3: Verify example still works**

Run: `cd examples/calculator && moon test`
Expected: PASS

**Step 4: Review diff**

Run: `git diff main --stat` to verify only expected files changed.

No commit needed — this is verification only.
