# Parse-Once Pickle Pipeline Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor moonspec's execution pipeline to parse features once, compile to Pickles, and execute from Pickles — matching the canonical cucumber architecture.

**Architecture:** FeatureCache (parse-once) → Pickle Compiler (flatten/expand) → PickleFilter (tags/names) → Runner (execute Pickles). Each phase is a distinct, testable component. The `@cucumber_messages.Pickle` types are already defined.

**Tech Stack:** MoonBit, `moonrockz/gherkin` (parser), `moonrockz/cucumber-messages` (Pickle types), `moonbitlang/core` (Map), `moonbitlang/async` (parallel execution)

**Design doc:** `docs/plans/2026-02-22-parse-once-pickle-pipeline-design.md`

**Build/test command:** `mise run test:unit` (from moonspec directory)

---

### Task 1: Update FeatureSource enum

**Files:**
- Modify: `src/runner/results.mbt:1-7`

**Step 1: Update the enum**

Replace `FeatureSource` with path-carrying variants:

```moonbit
///|
/// Input source for a feature to be loaded into the cache.
pub(all) enum FeatureSource {
  Text(String, String)              // (path, content)
  File(String)                      // (path)
  Parsed(String, @gherkin.Feature)  // (path, feature)
} derive(Show, Eq)
```

**Step 2: Run build to see all compile errors**

Run: `mise run test:unit`
Expected: Compile errors in test files that use old `FeatureSource::Text(content)` and `FeatureSource::Parsed(feature)` signatures.

**Step 3: Do NOT fix test errors yet — they will be fixed in later tasks**

Note the errors for reference. This task only changes the enum definition.

**Step 4: Commit**

```bash
git add src/runner/results.mbt
git commit -m "refactor(runner)!: add path to all FeatureSource variants"
```

---

### Task 2: Create FeatureCache

**Files:**
- Create: `src/runner/cache.mbt`
- Test: `src/runner/cache_wbtest.mbt`

**Step 1: Write failing tests**

Create `src/runner/cache_wbtest.mbt`:

```moonbit
///|
test "FeatureCache::new creates empty cache" {
  let cache = FeatureCache::new()
  assert_eq(cache.size(), 0)
}

///|
test "FeatureCache::load_text parses and stores feature" {
  let cache = FeatureCache::new()
  cache.load_text!("test://simple", "Feature: Simple\n\n  Scenario: S1\n    Given a step\n")
  assert_eq(cache.size(), 1)
  assert_true(cache.contains("test://simple"))
  let feature = cache.get("test://simple")
  assert_true(feature is Some(_))
}

///|
test "FeatureCache::load_text overwrites on same path" {
  let cache = FeatureCache::new()
  cache.load_text!("test://a", "Feature: First\n\n  Scenario: S1\n    Given a step\n")
  cache.load_text!("test://a", "Feature: Second\n\n  Scenario: S1\n    Given a step\n")
  assert_eq(cache.size(), 1)
  let feature = cache.get("test://a").unwrap()
  assert_eq(feature.name, "Second")
}

///|
test "FeatureCache::load_parsed stores directly" {
  let source = @gherkin.Source::from_string("Feature: Parsed\n\n  Scenario: S1\n    Given a step\n")
  let doc = @gherkin.parse(source) catch { _ => panic() }
  let feature = doc.feature.unwrap()
  let cache = FeatureCache::new()
  cache.load_parsed("test://parsed", feature)
  assert_eq(cache.size(), 1)
  assert_eq(cache.get("test://parsed").unwrap().name, "Parsed")
}

///|
test "FeatureCache::features returns all entries" {
  let cache = FeatureCache::new()
  cache.load_text!("test://a", "Feature: A\n\n  Scenario: S\n    Given a step\n")
  cache.load_text!("test://b", "Feature: B\n\n  Scenario: S\n    Given a step\n")
  let entries = cache.features()
  assert_eq(entries.length(), 2)
}

///|
test "FeatureCache::load_from_source handles all variants" {
  let cache = FeatureCache::new()
  cache.load_from_source!(FeatureSource::Text("test://text", "Feature: T\n\n  Scenario: S\n    Given a step\n"))
  cache.load_from_source!(FeatureSource::File("nonexistent.feature")) catch {
    _ => () // Expected: file not found
  }
  assert_eq(cache.size(), 1)
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `FeatureCache` not defined.

**Step 3: Write implementation**

Create `src/runner/cache.mbt`:

```moonbit
///|
/// In-memory cache of parsed Gherkin features, keyed by path.
/// Mutation is controlled — only `load_*` methods can add entries.
pub struct FeatureCache {
  priv cache : Map[String, @gherkin.Feature]
}

///|
/// Create an empty feature cache.
pub fn FeatureCache::new() -> FeatureCache {
  { cache: {} }
}

///|
/// Load a feature from a file path. Idempotent — skips if already cached.
pub fn FeatureCache::load_file(self : FeatureCache, path : String) -> Unit raise Error {
  if self.cache.contains(path) {
    return
  }
  let content = @fs.read_file_to_string(path)
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  match doc.feature {
    Some(feature) => self.cache.set(path, feature)
    None => ()
  }
}

///|
/// Load a feature from inline text. Always overwrites existing entry.
pub fn FeatureCache::load_text(
  self : FeatureCache,
  path : String,
  content : String,
) -> Unit raise Error {
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  match doc.feature {
    Some(feature) => self.cache.set(path, feature)
    None => ()
  }
}

///|
/// Store a pre-parsed feature directly.
pub fn FeatureCache::load_parsed(
  self : FeatureCache,
  path : String,
  feature : @gherkin.Feature,
) -> Unit {
  self.cache.set(path, feature)
}

///|
/// Load a feature from any FeatureSource variant.
pub fn FeatureCache::load_from_source(
  self : FeatureCache,
  source : FeatureSource,
) -> Unit raise Error {
  match source {
    Text(path, content) => self.load_text!(path, content)
    File(path) => self.load_file!(path)
    Parsed(path, feature) => self.load_parsed(path, feature)
  }
}

///|
/// Look up a cached feature by path.
pub fn FeatureCache::get(self : FeatureCache, path : String) -> @gherkin.Feature? {
  self.cache.get(path)
}

///|
/// Return all cached features as (path, feature) pairs.
pub fn FeatureCache::features(self : FeatureCache) -> Array[(String, @gherkin.Feature)] {
  let result : Array[(String, @gherkin.Feature)] = []
  self.cache.each(fn(k, v) { result.push((k, v)) })
  result
}

///|
/// Check if a path is cached.
pub fn FeatureCache::contains(self : FeatureCache, path : String) -> Bool {
  self.cache.contains(path)
}

///|
/// Number of cached features.
pub fn FeatureCache::size(self : FeatureCache) -> Int {
  self.cache.size()
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: Cache tests PASS (other tests may still fail from Task 1 enum change).

**Step 5: Commit**

```bash
git add src/runner/cache.mbt src/runner/cache_wbtest.mbt
git commit -m "feat(runner): add FeatureCache with parse-once semantics"
```

---

### Task 3: Create Pickle Compiler

**Files:**
- Create: `src/runner/compiler.mbt`
- Test: `src/runner/compiler_wbtest.mbt`
- Modify: `src/runner/moon.pkg.json` (add `moonrockz/cucumber-messages` import)

**Step 1: Add cucumber-messages dependency**

Update `src/runner/moon.pkg.json`:

```json
{
  "import": [
    "moonrockz/moonspec/core",
    "moonrockz/gherkin",
    "moonrockz/cucumber-expressions",
    "moonrockz/cucumber-messages",
    "moonbitlang/async",
    "moonbitlang/x/fs"
  ]
}
```

**Step 2: Write failing tests**

Create `src/runner/compiler_wbtest.mbt`:

```moonbit
///|
test "compile_pickles: single scenario produces one pickle" {
  let cache = FeatureCache::new()
  cache.load_text!("test://simple", "Feature: Simple\n\n  Scenario: S1\n    Given a step\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].name, "S1")
  assert_eq(pickles[0].uri, "test://simple")
  assert_eq(pickles[0].steps.length(), 1)
  assert_eq(pickles[0].steps[0].text, "a step")
}

///|
test "compile_pickles: background steps prepended" {
  let cache = FeatureCache::new()
  cache.load_text!("test://bg", "Feature: BG\n\n  Background:\n    Given setup\n\n  Scenario: S1\n    When action\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].steps.length(), 2)
  assert_eq(pickles[0].steps[0].text, "setup")
  assert_eq(pickles[0].steps[1].text, "action")
}

///|
test "compile_pickles: scenario outline expanded" {
  let cache = FeatureCache::new()
  cache.load_text!("test://outline", "Feature: Outline\n\n  Scenario Outline: Add\n    Given I have <a>\n\n    Examples:\n      | a   |\n      | one |\n      | two |\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 2)
  assert_eq(pickles[0].steps[0].text, "I have one")
  assert_eq(pickles[1].steps[0].text, "I have two")
}

///|
test "compile_pickles: tags inherited from feature and scenario" {
  let cache = FeatureCache::new()
  cache.load_text!("test://tags", "@feature-tag\nFeature: Tagged\n\n  @scenario-tag\n  Scenario: S1\n    Given a step\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  let tag_names = pickles[0].tags.map(fn(t) { t.name })
  assert_true(tag_names.contains("@feature-tag"))
  assert_true(tag_names.contains("@scenario-tag"))
}

///|
test "compile_pickles: step types mapped from keywords" {
  let cache = FeatureCache::new()
  cache.load_text!("test://types", "Feature: Types\n\n  Scenario: S1\n    Given context\n    When action\n    Then outcome\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles[0].steps[0].type_, Some(@cucumber_messages.PickleStepType::Context))
  assert_eq(pickles[0].steps[1].type_, Some(@cucumber_messages.PickleStepType::Action))
  assert_eq(pickles[0].steps[2].type_, Some(@cucumber_messages.PickleStepType::Outcome))
}

///|
test "compile_pickles: empty scenario produces no pickles" {
  let cache = FeatureCache::new()
  cache.load_text!("test://empty", "Feature: Empty\n\n  Scenario: No steps\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 0)
}

///|
test "compile_pickles: multiple features from cache" {
  let cache = FeatureCache::new()
  cache.load_text!("test://a", "Feature: A\n\n  Scenario: S1\n    Given a\n")
  cache.load_text!("test://b", "Feature: B\n\n  Scenario: S2\n    Given b\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 2)
}

///|
test "compile_pickles: unique pickle ids" {
  let cache = FeatureCache::new()
  cache.load_text!("test://multi", "Feature: Multi\n\n  Scenario: S1\n    Given a\n\n  Scenario: S2\n    Given b\n")
  let pickles = compile_pickles(cache)
  assert_true(pickles[0].id != pickles[1].id)
}
```

**Step 3: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `compile_pickles` not defined.

**Step 4: Write implementation**

Create `src/runner/compiler.mbt`:

```moonbit
///|
/// Counter for generating unique pickle IDs within a compilation run.
struct IdCounter {
  mut next : Int
}

///|
fn IdCounter::new() -> IdCounter {
  { next: 0 }
}

///|
fn IdCounter::next_id(self : IdCounter, prefix : String) -> String {
  let id = prefix + "-" + self.next.to_string()
  self.next = self.next + 1
  id
}

///|
/// Compile all cached features into Pickles.
/// Each Scenario becomes one Pickle; each Scenario Outline Examples row
/// becomes one Pickle with placeholders interpolated.
pub fn compile_pickles(cache : FeatureCache) -> Array[@cucumber_messages.Pickle] {
  let pickles : Array[@cucumber_messages.Pickle] = []
  let counter = IdCounter::new()
  for entry in cache.features() {
    let (uri, feature) = entry
    let feature_tags = feature.tags
    // Collect feature-level background steps
    let feature_bg_steps : Array[@gherkin.Step] = []
    for child in feature.children {
      match child {
        @gherkin.FeatureChild::Background(bg) =>
          for s in bg.steps {
            feature_bg_steps.push(s)
          }
        _ => ()
      }
    }
    for child in feature.children {
      match child {
        @gherkin.FeatureChild::Scenario(scenario) =>
          compile_scenario(
            pickles, counter, uri, feature.language,
            feature_tags, feature_bg_steps, scenario,
          )
        @gherkin.FeatureChild::Rule(rule) =>
          compile_rule(
            pickles, counter, uri, feature.language,
            feature_tags, feature_bg_steps, rule,
          )
        _ => ()
      }
    }
  }
  pickles
}

///|
fn compile_rule(
  pickles : Array[@cucumber_messages.Pickle],
  counter : IdCounter,
  uri : String,
  language : String,
  parent_tags : Array[@gherkin.Tag],
  parent_bg_steps : Array[@gherkin.Step],
  rule : @gherkin.Rule,
) -> Unit {
  // Collect rule-level background
  let rule_bg_steps : Array[@gherkin.Step] = parent_bg_steps.copy()
  for child in rule.children {
    match child {
      @gherkin.RuleChild::Background(bg) =>
        for s in bg.steps {
          rule_bg_steps.push(s)
        }
      _ => ()
    }
  }
  // Merge parent tags with rule tags
  let merged_tags : Array[@gherkin.Tag] = parent_tags.copy()
  for t in rule.tags {
    merged_tags.push(t)
  }
  for child in rule.children {
    match child {
      @gherkin.RuleChild::Scenario(scenario) =>
        compile_scenario(pickles, counter, uri, language, merged_tags, rule_bg_steps, scenario)
      _ => ()
    }
  }
}

///|
fn compile_scenario(
  pickles : Array[@cucumber_messages.Pickle],
  counter : IdCounter,
  uri : String,
  language : String,
  parent_tags : Array[@gherkin.Tag],
  bg_steps : Array[@gherkin.Step],
  scenario : @gherkin.Scenario,
) -> Unit {
  // Merge all inherited tags
  let all_tags : Array[@cucumber_messages.PickleTag] = []
  for t in parent_tags {
    all_tags.push({ name: t.name, astNodeId: t.id })
  }
  for t in scenario.tags {
    all_tags.push({ name: t.name, astNodeId: t.id })
  }
  if scenario.examples.is_empty() {
    // Regular scenario — skip if no steps
    if scenario.steps.is_empty() && bg_steps.is_empty() {
      return
    }
    let steps = build_pickle_steps(counter, bg_steps, scenario.steps)
    let pickle : @cucumber_messages.Pickle = {
      id: counter.next_id("pickle"),
      uri,
      name: scenario.name,
      language,
      steps,
      tags: all_tags,
      astNodeIds: [scenario.id],
      location: None,
    }
    pickles.push(pickle)
  } else {
    // Scenario Outline — one pickle per Examples row
    for examples in scenario.examples {
      let headers = match examples.table_header {
        Some(header_row) => header_row.cells.map(fn(c) { c.value })
        None => continue
      }
      // Include examples-level tags
      let outline_tags = all_tags.copy()
      for t in examples.tags {
        outline_tags.push({ name: t.name, astNodeId: t.id })
      }
      for row in examples.table_body {
        let values = row.cells.map(fn(c) { c.value })
        // Interpolate step text
        let expanded_steps : Array[@gherkin.Step] = scenario.steps.map(fn(s) {
          let mut text = s.text
          for i = 0; i < headers.length(); i = i + 1 {
            text = string_replace_compiler(text, "<" + headers[i] + ">", values[i])
          }
          { ..s, text }
        })
        // Build scenario name with parameter values
        let params : Array[String] = []
        for i = 0; i < headers.length(); i = i + 1 {
          params.push(headers[i] + "=" + values[i])
        }
        let pickle_name = scenario.name + " (" + params.join(", ") + ")"
        let steps = build_pickle_steps(counter, bg_steps, expanded_steps)
        let pickle : @cucumber_messages.Pickle = {
          id: counter.next_id("pickle"),
          uri,
          name: pickle_name,
          language,
          steps,
          tags: outline_tags,
          astNodeIds: [scenario.id, row.id],
          location: None,
        }
        pickles.push(pickle)
      }
    }
  }
}

///|
fn build_pickle_steps(
  counter : IdCounter,
  bg_steps : Array[@gherkin.Step],
  scenario_steps : Array[@gherkin.Step],
) -> Array[@cucumber_messages.PickleStep] {
  let result : Array[@cucumber_messages.PickleStep] = []
  for s in bg_steps {
    result.push(gherkin_step_to_pickle_step(counter, s))
  }
  for s in scenario_steps {
    result.push(gherkin_step_to_pickle_step(counter, s))
  }
  result
}

///|
fn gherkin_step_to_pickle_step(
  counter : IdCounter,
  step : @gherkin.Step,
) -> @cucumber_messages.PickleStep {
  let type_ : @cucumber_messages.PickleStepType? = match step.keyword_type {
    @gherkin.KeywordType::Context => Some(@cucumber_messages.PickleStepType::Context)
    @gherkin.KeywordType::Action => Some(@cucumber_messages.PickleStepType::Action)
    @gherkin.KeywordType::Outcome => Some(@cucumber_messages.PickleStepType::Outcome)
    @gherkin.KeywordType::Conjunction => None // inherits from previous
    @gherkin.KeywordType::Unknown => Some(@cucumber_messages.PickleStepType::Unknown)
  }
  {
    id: counter.next_id("step"),
    text: step.text,
    astNodeIds: [step.id],
    type_,
    argument: None, // TODO: handle DocString and DataTable in follow-up
  }
}

///|
/// String replace helper (same logic as outline.mbt, kept local to compiler).
fn string_replace_compiler(s : String, old : String, new_val : String) -> String {
  let buf = StringBuilder::new()
  let s_len = s.length()
  let old_len = old.length()
  if old_len == 0 {
    return s
  }
  let mut i = 0
  while i < s_len {
    if i + old_len <= s_len {
      let mut matches = true
      for j = 0; j < old_len; j = j + 1 {
        if s[i + j] != old[j] {
          matches = false
          break
        }
      }
      if matches {
        buf.write_string(new_val)
        i = i + old_len
        continue
      }
    }
    buf.write_char(s[i].to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}
```

**Step 5: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: Compiler tests PASS.

**Step 6: Commit**

```bash
git add src/runner/compiler.mbt src/runner/compiler_wbtest.mbt src/runner/moon.pkg.json
git commit -m "feat(runner): add Pickle compiler from FeatureCache"
```

---

### Task 4: Create PickleFilter

**Files:**
- Create: `src/runner/filter.mbt`
- Test: `src/runner/filter_pickle_wbtest.mbt`

**Step 1: Write failing tests**

Create `src/runner/filter_pickle_wbtest.mbt`:

```moonbit
///|
fn make_test_pickle(
  name : String,
  tags~ : Array[String] = [],
  uri~ : String = "test://feature",
) -> @cucumber_messages.Pickle {
  let pickle_tags = tags.map(fn(t) {
    let tag : @cucumber_messages.PickleTag = { name: t, astNodeId: "t1" }
    tag
  })
  {
    id: "p-" + name,
    uri,
    name,
    language: "en",
    steps: [{ id: "s1", text: "a step", astNodeIds: ["s1"], type_: None, argument: None }],
    tags: pickle_tags,
    astNodeIds: ["sc1"],
    location: None,
  }
}

///|
test "PickleFilter: no filters passes all" {
  let pickles = [
    make_test_pickle("S1"),
    make_test_pickle("S2"),
  ]
  let filter = PickleFilter::new()
  let result = filter.apply(pickles)
  assert_eq(result.length(), 2)
}

///|
test "PickleFilter: tag filter" {
  let pickles = [
    make_test_pickle("Smoke", tags=["@smoke"]),
    make_test_pickle("Slow", tags=["@slow"]),
  ]
  let filter = PickleFilter::new().with_tags!("@smoke")
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "Smoke")
}

///|
test "PickleFilter: name filter" {
  let pickles = [
    make_test_pickle("Login valid"),
    make_test_pickle("Login invalid"),
    make_test_pickle("Logout"),
  ]
  let filter = PickleFilter::new().with_names(["Login valid"])
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "Login valid")
}

///|
test "PickleFilter: combined tag and name" {
  let pickles = [
    make_test_pickle("A", tags=["@smoke"]),
    make_test_pickle("B", tags=["@smoke"]),
    make_test_pickle("C", tags=["@slow"]),
  ]
  let filter = PickleFilter::new().with_tags!("@smoke").with_names(["A"])
  let result = filter.apply(pickles)
  assert_eq(result.length(), 1)
  assert_eq(result[0].name, "A")
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `PickleFilter` not defined.

**Step 3: Write implementation**

Create `src/runner/filter.mbt`:

```moonbit
///|
/// Filter compiled pickles by tags, names, or URI+line.
pub struct PickleFilter {
  tag_expression : TagExpression
  scenario_names : Array[String]
}

///|
pub fn PickleFilter::new() -> PickleFilter {
  { tag_expression: Always, scenario_names: [] }
}

///|
pub fn PickleFilter::with_tags(self : PickleFilter, expr : String) -> PickleFilter raise Error {
  let parsed = TagExpression::parse(expr)
  { ..self, tag_expression: parsed }
}

///|
pub fn PickleFilter::with_names(self : PickleFilter, names : Array[String]) -> PickleFilter {
  { ..self, scenario_names: names }
}

///|
/// Apply all active filters. Filters are AND'd.
pub fn PickleFilter::apply(
  self : PickleFilter,
  pickles : Array[@cucumber_messages.Pickle],
) -> Array[@cucumber_messages.Pickle] {
  let result : Array[@cucumber_messages.Pickle] = []
  for pickle in pickles {
    if self.matches(pickle) {
      result.push(pickle)
    }
  }
  result
}

///|
fn PickleFilter::matches(self : PickleFilter, pickle : @cucumber_messages.Pickle) -> Bool {
  // Tag filter
  let tag_names = pickle.tags.map(fn(t) { t.name })
  if not(self.tag_expression.matches(tag_names)) {
    return false
  }
  // Name filter
  if not(self.scenario_names.is_empty()) {
    let mut name_match = false
    for name in self.scenario_names {
      if pickle.name == name {
        name_match = true
        break
      }
    }
    if not(name_match) {
      return false
    }
  }
  true
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: Filter tests PASS.

**Step 5: Commit**

```bash
git add src/runner/filter.mbt src/runner/filter_pickle_wbtest.mbt
git commit -m "feat(runner): add PickleFilter for tag and name filtering"
```

---

### Task 5: Refactor Runner to execute Pickles

**Files:**
- Modify: `src/runner/run.mbt` (entire file)
- Modify: `src/runner/executor.mbt:4-49` (update to accept PickleStep)
- Modify: `src/runner/parallel.mbt` (entire file)
- Modify: `src/runner/results.mbt:78-85` (add pickle_id to ScenarioResult)

**Step 1: Add pickle_id to ScenarioResult**

In `src/runner/results.mbt`, update the struct:

```moonbit
///|
/// Result of executing a scenario.
pub(all) struct ScenarioResult {
  feature_name : String
  scenario_name : String
  pickle_id : String
  tags : Array[String]
  steps : Array[StepResult]
  status : ScenarioStatus
  duration_ms : Int64
} derive(Show, Eq)
```

**Step 2: Update execute_scenario to accept PickleSteps**

In `src/runner/executor.mbt`, update `execute_scenario` to work with Pickle data:

```moonbit
///|
/// Execute a single scenario from a compiled Pickle.
pub fn execute_scenario(
  registry : @core.StepRegistry,
  feature_name~ : String,
  scenario_name~ : String,
  pickle_id~ : String,
  tags~ : Array[String],
  steps~ : Array[@cucumber_messages.PickleStep],
) -> ScenarioResult {
  let step_results : Array[StepResult] = []
  let mut failed = false
  for step in steps {
    let keyword = match step.type_ {
      Some(@cucumber_messages.PickleStepType::Context) => "Given "
      Some(@cucumber_messages.PickleStepType::Action) => "When "
      Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
      _ => "* "
    }
    if failed {
      step_results.push({
        text: step.text,
        keyword,
        status: StepStatus::Skipped,
        duration_ms: 0L,
      })
      continue
    }
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
    match status {
      StepStatus::Failed(_) | StepStatus::Undefined => failed = true
      _ => ()
    }
    step_results.push({ text: step.text, keyword, status, duration_ms: 0L })
  }
  let statuses = step_results.map(fn(r) { r.status })
  {
    feature_name,
    scenario_name,
    pickle_id,
    tags,
    steps: step_results,
    status: ScenarioStatus::from_steps(statuses),
    duration_ms: 0L,
  }
}
```

Similarly update `execute_scenario_with_hooks` to accept `PickleStep` array and `pickle_id`.

**Step 3: Rewrite run.mbt with pipeline**

Replace `src/runner/run.mbt` with the full pipeline:

```moonbit
///|
/// Run features through the full pipeline: cache → compile → filter → execute.
///
/// This is the convenience entry point. For fine-grained control, use
/// FeatureCache, compile_pickles, PickleFilter, and execute_pickle directly.
pub async fn[W : @core.World] run(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
) -> RunResult {
  // Phase 1: Load into cache
  let cache = FeatureCache::new()
  for source in features {
    cache.load_from_source!(source)
  }
  // Phase 2: Compile to pickles
  let pickles = compile_pickles(cache)
  // Phase 3: Filter
  let mut filter = PickleFilter::new()
  if tag_expr.length() > 0 {
    filter = filter.with_tags!(tag_expr)
  }
  if scenario_name.length() > 0 {
    filter = filter.with_names([scenario_name])
  }
  let filtered = filter.apply(pickles)
  // Phase 4: Execute
  let scenario_results = if parallel > 0 {
    run_pickles_parallel(factory, filtered, max_concurrent=parallel)
  } else {
    run_pickles_sequential(factory, filtered)
  }
  // Group results by feature (uri)
  let feature_results = group_by_feature(scenario_results, cache)
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
/// Run features with lifecycle hooks through the full pipeline.
pub async fn[W : @core.World + @core.Hooks] run_with_hooks(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr? : String = "",
  scenario_name? : String = "",
  parallel? : Int = 0,
) -> RunResult {
  let cache = FeatureCache::new()
  for source in features {
    cache.load_from_source!(source)
  }
  let pickles = compile_pickles(cache)
  let mut filter = PickleFilter::new()
  if tag_expr.length() > 0 {
    filter = filter.with_tags!(tag_expr)
  }
  if scenario_name.length() > 0 {
    filter = filter.with_names([scenario_name])
  }
  let filtered = filter.apply(pickles)
  let scenario_results = if parallel > 0 {
    run_pickles_parallel_with_hooks(factory, filtered, max_concurrent=parallel)
  } else {
    run_pickles_sequential_with_hooks(factory, filtered)
  }
  let feature_results = group_by_feature(scenario_results, cache)
  let summary = compute_summary(feature_results)
  { features: feature_results, summary }
}

///|
fn[W : @core.World] run_pickles_sequential(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
) -> Array[ScenarioResult] raise Error {
  let results : Array[ScenarioResult] = []
  for pickle in pickles {
    let result = execute_pickle(factory, pickle)
    results.push(result)
  }
  results
}

///|
fn[W : @core.World + @core.Hooks] run_pickles_sequential_with_hooks(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
) -> Array[ScenarioResult] raise Error {
  let results : Array[ScenarioResult] = []
  for pickle in pickles {
    let result = execute_pickle_with_hooks(factory, pickle)
    results.push(result)
  }
  results
}

///|
/// Execute a single pickle: create world, register steps, run.
fn[W : @core.World] execute_pickle(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
) -> ScenarioResult {
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  execute_scenario(
    registry,
    feature_name=pickle_feature_name(pickle),
    scenario_name=pickle.name,
    pickle_id=pickle.id,
    tags=pickle.tags.map(fn(t) { t.name }),
    steps=pickle.steps,
  )
}

///|
/// Execute a single pickle with hooks.
fn[W : @core.World + @core.Hooks] execute_pickle_with_hooks(
  factory : () -> W,
  pickle : @cucumber_messages.Pickle,
) -> ScenarioResult {
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  execute_scenario_with_hooks(
    world,
    registry,
    feature_name=pickle_feature_name(pickle),
    scenario_name=pickle.name,
    pickle_id=pickle.id,
    tags=pickle.tags.map(fn(t) { t.name }),
    steps=pickle.steps,
  )
}

///|
/// Extract feature name from pickle URI (used for result grouping).
fn pickle_feature_name(pickle : @cucumber_messages.Pickle) -> String {
  pickle.uri
}

///|
/// Group flat scenario results back into FeatureResults by URI.
fn group_by_feature(
  results : Array[ScenarioResult],
  cache : FeatureCache,
) -> Array[FeatureResult] {
  let groups : Map[String, Array[ScenarioResult]] = {}
  let order : Array[String] = []
  for r in results {
    let key = r.feature_name
    match groups.get(key) {
      Some(arr) => arr.push(r)
      None => {
        groups.set(key, [r])
        order.push(key)
      }
    }
  }
  let feature_results : Array[FeatureResult] = []
  for uri in order {
    let scenarios = groups.get(uri).or([])
    // Get the actual feature name from the cache
    let name = match cache.get(uri) {
      Some(f) => f.name
      None => uri
    }
    feature_results.push({ name, scenarios, duration_ms: 0L })
  }
  feature_results
}

///|
fn compute_summary(features : Array[FeatureResult]) -> RunSummary {
  let mut total = 0
  let mut passed = 0
  let mut failed = 0
  let mut undefined = 0
  let mut pending = 0
  let mut skipped = 0
  for f in features {
    for s in f.scenarios {
      total = total + 1
      match s.status {
        ScenarioStatus::Passed => passed = passed + 1
        ScenarioStatus::Failed => failed = failed + 1
        ScenarioStatus::Undefined => undefined = undefined + 1
        ScenarioStatus::Pending => pending = pending + 1
        ScenarioStatus::Skipped => skipped = skipped + 1
      }
    }
  }
  {
    total_scenarios: total,
    passed,
    failed,
    undefined,
    pending,
    skipped,
    duration_ms: 0L,
  }
}
```

**Step 4: Rewrite parallel.mbt**

Replace `src/runner/parallel.mbt`:

```moonbit
///|
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    async fn() -> ScenarioResult {
      execute_pickle(factory, pickle)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}

///|
async fn[W : @core.World + @core.Hooks] run_pickles_parallel_with_hooks(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    async fn() -> ScenarioResult {
      execute_pickle_with_hooks(factory, pickle)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
```

**Step 5: Delete old feature.mbt**

Delete `src/runner/feature.mbt` entirely — `resolve_feature()`, `execute_feature()`, `execute_feature_filtered()`, `execute_feature_filtered_with_hooks()`, and `collect_background_steps()` are all replaced by the pipeline.

**Step 6: Delete old outline.mbt**

Delete `src/runner/outline.mbt` — `expand_outline()` and its `string_replace()` helper are replaced by the compiler.

**Step 7: Run build to check compilation**

Run: `mise run test:unit`
Expected: Compile errors in test files (next task).

**Step 8: Commit**

```bash
git add src/runner/run.mbt src/runner/executor.mbt src/runner/parallel.mbt src/runner/results.mbt
git rm src/runner/feature.mbt src/runner/outline.mbt
git commit -m "refactor(runner)!: replace feature execution with Pickle pipeline"
```

---

### Task 6: Migrate all existing tests

**Files:**
- Modify: `src/runner/run_wbtest.mbt`
- Modify: `src/runner/feature_wbtest.mbt`
- Modify: `src/runner/background_wbtest.mbt`
- Modify: `src/runner/filter_wbtest.mbt`
- Modify: `src/runner/e2e_wbtest.mbt`
- Modify: `src/runner/parallel_wbtest.mbt`
- Modify: `src/runner/hooks_wbtest.mbt`
- Modify: `src/runner/executor_wbtest.mbt`
- Delete: `src/runner/outline_wbtest.mbt` (covered by compiler tests)

**Step 1: Update FeatureSource::Text calls**

All tests using `FeatureSource::Text(content)` become `FeatureSource::Text("test://name", content)`. For example, in `run_wbtest.mbt`:

```moonbit
// Before:
let features = [FeatureSource::Text("Feature: One\n\n  Scenario: Pass\n    Given a step\n")]

// After:
let features = [FeatureSource::Text("test://one", "Feature: One\n\n  Scenario: Pass\n    Given a step\n")]
```

Apply this pattern across all test files. Use a descriptive path for each test, e.g. `"test://isolation"`, `"test://hooks-e2e"`.

**Step 2: Update tests that call deleted functions**

Tests in `feature_wbtest.mbt` call `execute_feature()` and `execute_feature_filtered()` which no longer exist. Rewrite these to use the `run()` convenience function instead:

```moonbit
///|
test "feature parses and runs all scenarios" {
  let feature_content = "Feature: Simple math\n\n  Scenario: Addition\n    Given I have 5 cucumbers\n    When I eat 3 cucumbers\n    Then I should have 2 cucumbers\n\n  Scenario: No eating\n    Given I have 10 cucumbers\n    Then I should have 10 cucumbers\n"
  let result = run(CucumberWorld::default, [FeatureSource::Text("test://math", feature_content)])
  assert_eq(result.features[0].name, "Simple math")
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
}
```

**Step 3: Update executor_wbtest.mbt**

Tests that call `execute_scenario` directly need updated signatures to pass `pickle_id` and `PickleStep` arrays instead of `(String, String)` tuples.

**Step 4: Update hooks_wbtest.mbt**

Tests calling `execute_scenario_with_hooks` need the same signature updates.

**Step 5: Delete outline_wbtest.mbt**

The outline expansion logic is now tested via `compiler_wbtest.mbt`.

**Step 6: Run all tests**

Run: `mise run test:unit`
Expected: ALL tests PASS.

**Step 7: Commit**

```bash
git add src/runner/*_wbtest.mbt
git rm src/runner/outline_wbtest.mbt
git commit -m "test(runner): migrate all tests to Pickle pipeline"
```

---

### Task 7: Update codegen

**Files:**
- Modify: `src/codegen/codegen.mbt:200-336` (PerScenario mode)

**Step 1: Update PerScenario codegen**

Replace `generate_scenario_runner_test` to emit `File(path)` with `scenario_name` filter instead of embedding feature text:

```moonbit
fn generate_scenario_runner_test(
  buf : StringBuilder,
  feature_name : String,
  scenario_name : String,
  source_path : String,
  config : CodegenConfig,
  _background_steps : Array[@gherkin.Step],
  _scenario_steps : Array[@gherkin.Step],
  _tags : Array[@gherkin.Tag],
) -> Unit {
  let test_name = "Feature: " + feature_name + " / Scenario: " + scenario_name
  buf.write_string("async test \"" + escape_string(test_name) + "\" {\n")
  if config.world.length() > 0 {
    buf.write_string(
      "  let result = @moonspec.run(\n    " +
      config.world +
      "::default, [@moonspec.FeatureSource::File(\"" +
      escape_string(source_path) +
      "\")],\n    scenario_name=\"" +
      escape_string(scenario_name) +
      "\",\n  )\n",
    )
    buf.write_string("  assert_eq!(result.summary.failed, 0)\n")
  } else {
    buf.write_string("  // Source: " + source_path + "\n")
    buf.write_string("  ignore(\"\")\n")
  }
  buf.write_string("}\n")
}
```

**Step 2: Update PerFeature codegen**

Update to use the new `FeatureSource::File` (unchanged signature, just verify it still works).

**Step 3: Update codegen tests**

Tests in `src/codegen/codegen_wbtest.mbt` that assert on generated output will need updating to match the new format (no more embedded `#|` feature text in PerScenario mode).

**Step 4: Run all tests**

Run: `mise run test:unit`
Expected: ALL tests PASS.

**Step 5: Commit**

```bash
git add src/codegen/codegen.mbt src/codegen/codegen_wbtest.mbt
git commit -m "refactor(codegen): emit File+scenario_name instead of embedded text"
```

---

### Task 8: Clean up and verify

**Step 1: Run full test suite**

Run: `mise run test:unit`
Expected: ALL tests PASS.

**Step 2: Check for unused imports or dead code**

Look for any remaining references to deleted functions (`resolve_feature`, `execute_feature`, `execute_feature_filtered`, `expand_outline`, `collect_background_steps`).

**Step 3: Verify the public API surface**

Check that the runner package exports:
- `FeatureCache` (new)
- `compile_pickles` (new)
- `PickleFilter` (new)
- `run`, `run_with_hooks` (updated signatures)
- `FeatureSource` (updated variants)
- Result types (unchanged except `ScenarioResult.pickle_id`)

**Step 4: Update the moonspec top-level package if needed**

Check `src/moon.pkg.json` re-exports are correct.

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore(runner): clean up dead code from pipeline refactoring"
```

**Step 6: Close the beads issue**

```bash
bd close moonspec-1e8
```
