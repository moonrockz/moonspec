# Assertions and Matchers Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add ergonomic assertions across three layers: a standalone `moonrockz/expect` package, moonspec core improvements (`run_or_fail` returns `Unit`, step context enrichment), and `moonspec/expect` for RunResult assertions.

**Architecture:** The standalone `moonrockz/expect` package provides `expect(x).to_equal(y)` style matchers usable in any MoonBit project. Moonspec core changes `run_or_fail` to return `Unit` (breaking) and enriches step failure messages with step context. A new `moonspec/expect` subpackage extends the expect pattern for RunResult inspection.

**Tech Stack:** MoonBit, mooncakes package system, MoonBit traits (`Eq`, `Show`)

---

### Task 1: Create `moonrockz/expect` Standalone Package — Core Types

This task creates the standalone expect library with the `Expectation[T]` wrapper and `to_equal` / `to_not_equal` matchers.

**Files:**
- Create: `expect/moon.mod.json`
- Create: `expect/src/moon.pkg`
- Create: `expect/src/expect.mbt`
- Create: `expect/src/expect_wbtest.mbt`

**Context:** The `expect` package is a sibling project to `moonspec` in the same repo. It has its own `moon.mod.json`. MoonBit uses traits like `Eq` and `Show` for generic constraints. All matchers raise `Error` on failure with descriptive messages.

**Step 1: Create package scaffolding**

Create `expect/moon.mod.json`:
```json
{
  "name": "moonrockz/expect",
  "version": "0.1.0",
  "source": "src/"
}
```

Create `expect/src/moon.pkg`:
```
{}
```

**Step 2: Write failing tests for `to_equal` and `to_not_equal`**

Create `expect/src/expect_wbtest.mbt`:
```moonbit
///|
test "expect to_equal passes on equal values" {
  expect(42).to_equal(42)
}

///|
test "expect to_equal fails on unequal values" {
  let mut caught = false
  try {
    expect(3).to_equal(5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected 3 to equal 5"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_not_equal passes on unequal values" {
  expect(3).to_not_equal(5)
}

///|
test "expect to_not_equal fails on equal values" {
  let mut caught = false
  try {
    expect(42).to_not_equal(42)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected 42 to not equal 42"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_equal works with strings" {
  expect("hello").to_equal("hello")
}

///|
test "expect to_equal fails with string mismatch" {
  let mut caught = false
  try {
    expect("hello").to_equal("world")
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected hello to equal world"))
    }
  }
  assert_true(caught)
}
```

**Step 3: Run tests to verify they fail**

Run: `cd expect && moon test --target js 2>&1`
Expected: FAIL — `expect` function not defined

**Step 4: Implement `Expectation` and equality matchers**

Create `expect/src/expect.mbt`:
```moonbit
///|
/// Wraps a value for fluent assertion chaining.
pub struct Expectation[T] {
  actual : T
}

///|
/// Create an expectation on a value.
pub fn expect[T](actual : T) -> Expectation[T] {
  { actual, }
}

///|
/// Assert the actual value equals the expected value.
pub fn[T : Eq + Show] Expectation::to_equal(
  self : Expectation[T],
  expected : T,
) -> Unit raise Error {
  if self.actual != expected {
    raise "Expected \{self.actual} to equal \{expected}"
  }
}

///|
/// Assert the actual value does not equal the given value.
pub fn[T : Eq + Show] Expectation::to_not_equal(
  self : Expectation[T],
  other : T,
) -> Unit raise Error {
  if self.actual == other {
    raise "Expected \{self.actual} to not equal \{other}"
  }
}
```

**Step 5: Run tests to verify they pass**

Run: `cd expect && moon test --target js 2>&1`
Expected: All tests PASS

**Step 6: Commit**

```bash
git add expect/
git commit -m "feat(expect): add standalone expect package with to_equal and to_not_equal"
```

---

### Task 2: `moonrockz/expect` — Boolean and Option Matchers

**Files:**
- Modify: `expect/src/expect.mbt`
- Modify: `expect/src/expect_wbtest.mbt`

**Step 1: Write failing tests**

Append to `expect/src/expect_wbtest.mbt`:
```moonbit
///|
test "expect to_be_true passes" {
  expect(true).to_be_true()
}

///|
test "expect to_be_true fails on false" {
  let mut caught = false
  try {
    expect(false).to_be_true()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected false to be true"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_false passes" {
  expect(false).to_be_false()
}

///|
test "expect to_be_false fails on true" {
  let mut caught = false
  try {
    expect(true).to_be_false()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected true to be false"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_some passes on Some" {
  let opt : Int? = Some(42)
  expect(opt).to_be_some()
}

///|
test "expect to_be_some fails on None" {
  let mut caught = false
  try {
    let opt : Int? = None
    expect(opt).to_be_some()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("Expected None to be Some"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_none passes on None" {
  let opt : Int? = None
  expect(opt).to_be_none()
}

///|
test "expect to_be_none fails on Some" {
  let mut caught = false
  try {
    let opt : Int? = Some(42)
    expect(opt).to_be_none()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be None"))
    }
  }
  assert_true(caught)
}
```

**Step 2: Run tests to verify they fail**

Run: `cd expect && moon test --target js 2>&1`
Expected: FAIL — methods not defined

**Step 3: Implement boolean and option matchers**

Append to `expect/src/expect.mbt`:
```moonbit
///|
/// Assert the actual boolean value is true.
pub fn Expectation::to_be_true(self : Expectation[Bool]) -> Unit raise Error {
  if not(self.actual) {
    raise "Expected false to be true"
  }
}

///|
/// Assert the actual boolean value is false.
pub fn Expectation::to_be_false(self : Expectation[Bool]) -> Unit raise Error {
  if self.actual {
    raise "Expected true to be false"
  }
}

///|
/// Assert the actual Option value is Some.
pub fn[T : Show] Expectation::to_be_some(
  self : Expectation[T?],
) -> Unit raise Error {
  match self.actual {
    Some(_) => ()
    None => raise "Expected None to be Some"
  }
}

///|
/// Assert the actual Option value is None.
pub fn[T : Show] Expectation::to_be_none(
  self : Expectation[T?],
) -> Unit raise Error {
  match self.actual {
    None => ()
    Some(_) => raise "Expected \{self.actual} to be None"
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `cd expect && moon test --target js 2>&1`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add expect/
git commit -m "feat(expect): add boolean and option matchers"
```

---

### Task 3: `moonrockz/expect` — Collection and String Matchers

**Files:**
- Modify: `expect/src/expect.mbt`
- Modify: `expect/src/expect_wbtest.mbt`

**Step 1: Write failing tests**

Append to `expect/src/expect_wbtest.mbt`:
```moonbit
///|
test "expect string to_contain passes" {
  expect("hello world").to_contain("world")
}

///|
test "expect string to_contain fails" {
  let mut caught = false
  try {
    expect("hello").to_contain("xyz")
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to contain"))
    }
  }
  assert_true(caught)
}

///|
test "expect array to_contain passes" {
  expect([1, 2, 3]).to_contain(2)
}

///|
test "expect array to_contain fails" {
  let mut caught = false
  try {
    expect([1, 2, 3]).to_contain(5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to contain"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_be_empty passes on empty array" {
  let arr : Array[Int] = []
  expect(arr).to_be_empty()
}

///|
test "expect to_be_empty fails on non-empty array" {
  let mut caught = false
  try {
    expect([1, 2]).to_be_empty()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be empty"))
    }
  }
  assert_true(caught)
}

///|
test "expect to_have_length passes" {
  expect([1, 2, 3]).to_have_length(3)
}

///|
test "expect to_have_length fails" {
  let mut caught = false
  try {
    expect([1, 2]).to_have_length(5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to have length 5"))
    }
  }
  assert_true(caught)
}

///|
test "expect string to_be_empty passes" {
  expect("").to_be_empty()
}

///|
test "expect string to_be_empty fails" {
  let mut caught = false
  try {
    expect("hello").to_be_empty()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("to be empty"))
    }
  }
  assert_true(caught)
}

///|
test "expect string to_have_length passes" {
  expect("hello").to_have_length(5)
}
```

**Step 2: Run tests to verify they fail**

Run: `cd expect && moon test --target js 2>&1`
Expected: FAIL — methods not defined

**Step 3: Implement collection and string matchers**

Append to `expect/src/expect.mbt`:
```moonbit
///|
/// Assert the string contains the given substring.
pub fn Expectation::to_contain(
  self : Expectation[String],
  substring : String,
) -> Unit raise Error {
  if not(self.actual.contains(substring)) {
    raise "Expected \"\{self.actual}\" to contain \"\{substring}\""
  }
}

///|
/// Assert the array contains the given element.
pub fn[T : Eq + Show] Expectation::to_contain(
  self : Expectation[Array[T]],
  element : T,
) -> Unit raise Error {
  if not(self.actual.contains(element)) {
    raise "Expected \{self.actual} to contain \{element}"
  }
}

///|
/// Assert the array is empty.
pub fn[T : Show] Expectation::to_be_empty(
  self : Expectation[Array[T]],
) -> Unit raise Error {
  if self.actual.length() > 0 {
    raise "Expected \{self.actual} to be empty, but has \{self.actual.length()} elements"
  }
}

///|
/// Assert the string is empty.
pub fn Expectation::to_be_empty(
  self : Expectation[String],
) -> Unit raise Error {
  if self.actual.length() > 0 {
    raise "Expected \"\{self.actual}\" to be empty, but has length \{self.actual.length()}"
  }
}

///|
/// Assert the array has the given length.
pub fn[T : Show] Expectation::to_have_length(
  self : Expectation[Array[T]],
  expected : Int,
) -> Unit raise Error {
  let actual = self.actual.length()
  if actual != expected {
    raise "Expected \{self.actual} to have length \{expected}, but has length \{actual}"
  }
}

///|
/// Assert the string has the given length.
pub fn Expectation::to_have_length(
  self : Expectation[String],
  expected : Int,
) -> Unit raise Error {
  let actual = self.actual.length()
  if actual != expected {
    raise "Expected \"\{self.actual}\" to have length \{expected}, but has length \{actual}"
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `cd expect && moon test --target js 2>&1`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add expect/
git commit -m "feat(expect): add collection and string matchers"
```

---

### Task 4: `run_or_fail` Returns `Unit`

This is the breaking change. Modify `run_or_fail` to return `Unit`, update all call sites to remove `|> ignore`.

**Files:**
- Modify: `src/runner/run.mbt:816-830`
- Modify: `src/runner/run_wbtest.mbt` (tests for run_or_fail)
- Modify: `src/codegen/codegen.mbt:162-166, 243-246`
- Modify: `src/codegen/codegen_wbtest.mbt`
- Modify: All `examples/**/` generated and manual test files

**Step 1: Change `run_or_fail` return type to `Unit`**

In `src/runner/run.mbt`, change lines 816-830 from:
```moonbit
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  options : RunOptions,
) -> RunResult {
  let result = run(factory, options)
  if result.parse_errors.length() > 0 ||
    result.summary.failed > 0 ||
    result.summary.undefined > 0 ||
    result.summary.pending > 0 {
    let errors = collect_scenario_errors(result)
    let summary = format_run_summary(result.summary)
    raise @core.run_failed_error(summary~, errors~)
  }
  result
}
```

To:
```moonbit
pub async fn[W : @core.World] run_or_fail(
  factory : () -> W,
  options : RunOptions,
) -> Unit {
  let result = run(factory, options)
  if result.parse_errors.length() > 0 ||
    result.summary.failed > 0 ||
    result.summary.undefined > 0 ||
    result.summary.pending > 0 {
    let errors = collect_scenario_errors(result)
    let summary = format_run_summary(result.summary)
    raise @core.run_failed_error(summary~, errors~)
  }
}
```

**Step 2: Update runner tests**

In `src/runner/run_wbtest.mbt`, the "run_or_fail succeeds when all pass" test currently captures the result. Change it to just call without capturing:

Find and update the test at ~line 57-65 — remove `let result =` and any result assertions, since the function now returns Unit. For the "raises RunFailed" test, the `try` block stays the same since it catches the error.

**Step 3: Remove `|> ignore` from codegen output**

In `src/codegen/codegen.mbt`, change line 163-166 from:
```moonbit
buf.write_string(
  "  @moonspec.run_or_fail(\n    " +
  config.world +
  "::default, options,\n  )\n  |> ignore\n",
)
```
To:
```moonbit
buf.write_string(
  "  @moonspec.run_or_fail(\n    " +
  config.world +
  "::default, options,\n  )\n",
)
```

Apply same change at line 243-246.

**Step 4: Update codegen tests**

In `src/codegen/codegen_wbtest.mbt`, update any assertions checking for `|> ignore` in generated output.

**Step 5: Remove `|> ignore` from all example files**

Update every file that has `run_or_fail(...)\n  |> ignore`:
- `examples/calculator/src/calculator_feature_wbtest.mbt` (lines 8-9, 15-16, 22-23, 29-30)
- `examples/calculator/src/calculator_wbtest.mbt` (lines 28-29)
- `examples/bank-account/src/bank_account_feature_wbtest.mbt` (lines 6-9)
- `examples/bank-account/src/bank_account_wbtest.mbt` (lines 23-24, 41-42)
- `examples/ecommerce/src/cart_feature_wbtest.mbt` (lines 8-9, 15-16, 22-23)
- `examples/ecommerce/src/checkout_feature_wbtest.mbt` (lines 8-9, 15-16)
- `examples/ecommerce/src/inventory_feature_wbtest.mbt` (lines 8-9, 15-16)
- `examples/ecommerce/src/multi_feature_wbtest.mbt` (lines 4-9)
- `examples/todolist/src/todolist_feature_wbtest.mbt` (lines 8-9, 15-16, 22-23, 29-30)

**Step 6: Update READMEs**

Update `README.md` and `README.mbt.md` — remove all `|> ignore` after `run_or_fail` calls.

**Step 7: Run tests**

Run: `mise run test:unit 2>&1`
Expected: All tests PASS

**Step 8: Commit**

```bash
git add -A
git commit -m "feat!: run_or_fail returns Unit instead of RunResult

BREAKING CHANGE: run_or_fail no longer returns RunResult. Use run()
to inspect results. Callers no longer need |> ignore."
```

---

### Task 5: Step Context Enrichment in Executor

Enrich step failure messages with step keyword and text so users see which step failed.

**Files:**
- Modify: `src/runner/executor.mbt:439-449`
- Modify: `src/runner/run_wbtest.mbt` (add enrichment test)

**Step 1: Write a failing test**

Add to `src/runner/run_wbtest.mbt`:
```moonbit
///|
async test "step failure messages include step context" {
  let content =
    "Feature: Context\n\n  Scenario: Fail\n    Given a value of 1\n    Then the value should be 99\n"
  let result = run(
    ContextWorld::default,
    RunOptions::new([FeatureSource::Text("test://context", content)]),
  )
  // Find the failed step's diagnostic message
  let scenario = result.features[0].scenarios[0]
  let failed_step = scenario.steps.iter().find_first(fn(s) {
    match s.status {
      StepStatus::Failed(_) => true
      _ => false
    }
  })
  match failed_step {
    Some(step) =>
      match step.status {
        StepStatus::Failed(msg) => {
          assert_true(msg.contains("Then"))
          assert_true(msg.contains("the value should be 99"))
        }
        _ => fail!("expected Failed status")
      }
    None => fail!("expected a failed step")
  }
}
```

Also define the test world near other test worlds in `run_wbtest.mbt`:
```moonbit
struct ContextWorld {
  mut value : Int
} derive(Default)

impl @core.World for ContextWorld with configure(self, setup) {
  setup.given1("a value of {int}", fn(n : Int) { self.value = n })
  setup.then1("the value should be {int}", fn(expected : Int) {
    assert_eq!(self.value, expected)
  })
}
```

**Step 2: Run test to verify it fails**

Run: `mise run test:unit 2>&1`
Expected: FAIL — the failure message doesn't contain step context yet

**Step 3: Enrich error messages in executor catch block**

In `src/runner/executor.mbt`, change lines 439-449 from:
```moonbit
            e =>
              (
                StepStatus::Failed(e.to_string()),
                Some(
                  @core.step_failed_error(
                    step=step.text,
                    keyword~,
                    message=e.to_string(),
                  ),
                ),
              )
```

To:
```moonbit
            e => {
              let enriched =
                "Step '" + step.text + "' (" + keyword + "): " + e.to_string()
              (
                StepStatus::Failed(enriched),
                Some(
                  @core.step_failed_error(
                    step=step.text,
                    keyword~,
                    message=enriched,
                  ),
                ),
              )
            }
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit 2>&1`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add src/runner/executor.mbt src/runner/run_wbtest.mbt
git commit -m "feat(runner): enrich step failure messages with step context"
```

---

### Task 6: `moonspec/expect` — RunResult Assertions

Create the moonspec-specific expect subpackage for RunResult assertions.

**Files:**
- Create: `src/expect/moon.pkg`
- Create: `src/expect/run_result.mbt`
- Create: `src/expect/run_result_wbtest.mbt`

**Context:** This subpackage imports both `moonrockz/expect` (for the `Expectation` type) and `moonrockz/moonspec/runner` (for `RunResult`, `RunSummary`, etc.). It extends `Expectation` with methods specific to moonspec result types.

**Step 1: Create package scaffolding**

Create `src/expect/moon.pkg`:
```
import {
  "moonrockz/expect",
  "moonrockz/moonspec/runner",
}

import "wbtest" {
  "moonrockz/moonspec/core",
}
```

**Step 2: Write failing tests**

Create `src/expect/run_result_wbtest.mbt`:
```moonbit
///|
test "expect RunResult to_have_passed on passing result" {
  let result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 3,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      retried: 0,
      duration_ms: 0L,
    },
    parse_errors: [],
  }
  @expect.expect(result).to_have_passed()
}

///|
test "expect RunResult to_have_passed fails on failures" {
  let result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 1,
      failed: 2,
      undefined: 0,
      pending: 0,
      skipped: 0,
      retried: 0,
      duration_ms: 0L,
    },
    parse_errors: [],
  }
  let mut caught = false
  try {
    @expect.expect(result).to_have_passed()
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("2 failed"))
    }
  }
  assert_true(caught)
}

///|
test "expect RunResult to_have_failed passes on failures" {
  let result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 3,
      passed: 1,
      failed: 2,
      undefined: 0,
      pending: 0,
      skipped: 0,
      retried: 0,
      duration_ms: 0L,
    },
    parse_errors: [],
  }
  @expect.expect(result).to_have_failed()
}

///|
test "expect RunSummary to_have checks counts" {
  let summary : @runner.RunSummary = {
    total_scenarios: 5,
    passed: 3,
    failed: 1,
    undefined: 1,
    pending: 0,
    skipped: 0,
    retried: 0,
    duration_ms: 0L,
  }
  @expect.expect(summary).to_have(passed=3)
  @expect.expect(summary).to_have(failed=1)
  @expect.expect(summary).to_have(passed=3, failed=1)
}

///|
test "expect RunSummary to_have fails on mismatch" {
  let summary : @runner.RunSummary = {
    total_scenarios: 5,
    passed: 3,
    failed: 1,
    undefined: 1,
    pending: 0,
    skipped: 0,
    retried: 0,
    duration_ms: 0L,
  }
  let mut caught = false
  try {
    @expect.expect(summary).to_have(passed=5)
  } catch {
    e => {
      caught = true
      assert_true(e.to_string().contains("passed"))
    }
  }
  assert_true(caught)
}

///|
test "expect RunResult to_have_no_parse_errors passes" {
  let result : @runner.RunResult = {
    features: [],
    summary: {
      total_scenarios: 0,
      passed: 0,
      failed: 0,
      undefined: 0,
      pending: 0,
      skipped: 0,
      retried: 0,
      duration_ms: 0L,
    },
    parse_errors: [],
  }
  @expect.expect(result).to_have_no_parse_errors()
}
```

**Step 3: Run tests to verify they fail**

Run: `mise run test:unit 2>&1`
Expected: FAIL — methods not defined

**Step 4: Implement RunResult assertions**

Create `src/expect/run_result.mbt`:
```moonbit
///|
/// Assert the run passed (no failures, undefined, or pending steps).
pub fn @expect.Expectation::to_have_passed(
  self : @expect.Expectation[@runner.RunResult],
) -> Unit raise Error {
  let s = self.actual.summary
  if s.failed > 0 || s.undefined > 0 || s.pending > 0 {
    let parts : Array[String] = []
    if s.failed > 0 {
      parts.push(s.failed.to_string() + " failed")
    }
    if s.undefined > 0 {
      parts.push(s.undefined.to_string() + " undefined")
    }
    if s.pending > 0 {
      parts.push(s.pending.to_string() + " pending")
    }
    raise "Expected run to have passed, but: " + parts.join(", ")
  }
}

///|
/// Assert the run had failures.
pub fn @expect.Expectation::to_have_failed(
  self : @expect.Expectation[@runner.RunResult],
) -> Unit raise Error {
  if self.actual.summary.failed == 0 {
    raise "Expected run to have failed, but all \{self.actual.summary.passed} scenarios passed"
  }
}

///|
/// Assert the run had no parse errors.
pub fn @expect.Expectation::to_have_no_parse_errors(
  self : @expect.Expectation[@runner.RunResult],
) -> Unit raise Error {
  let count = self.actual.parse_errors.length()
  if count > 0 {
    raise "Expected no parse errors, but found \{count}"
  }
}

///|
/// Assert the run summary has specific counts.
/// Only provided fields are checked; omitted fields are ignored.
pub fn @expect.Expectation::to_have(
  self : @expect.Expectation[@runner.RunSummary],
  passed? : Int,
  failed? : Int,
  undefined? : Int,
  pending? : Int,
  skipped? : Int,
) -> Unit raise Error {
  let s = self.actual
  let mismatches : Array[String] = []
  match passed {
    Some(expected) =>
      if s.passed != expected {
        mismatches.push(
          "passed: expected \{expected}, got \{s.passed}",
        )
      }
    None => ()
  }
  match failed {
    Some(expected) =>
      if s.failed != expected {
        mismatches.push(
          "failed: expected \{expected}, got \{s.failed}",
        )
      }
    None => ()
  }
  match undefined {
    Some(expected) =>
      if s.undefined != expected {
        mismatches.push(
          "undefined: expected \{expected}, got \{s.undefined}",
        )
      }
    None => ()
  }
  match pending {
    Some(expected) =>
      if s.pending != expected {
        mismatches.push(
          "pending: expected \{expected}, got \{s.pending}",
        )
      }
    None => ()
  }
  match skipped {
    Some(expected) =>
      if s.skipped != expected {
        mismatches.push(
          "skipped: expected \{expected}, got \{s.skipped}",
        )
      }
    None => ()
  }
  if mismatches.length() > 0 {
    raise "Run summary mismatch: " + mismatches.join(", ")
  }
}
```

**Step 5: Run tests to verify they pass**

Run: `mise run test:unit 2>&1`
Expected: All tests PASS

**Step 6: Re-export from facade**

Add `moonspec/expect` to `src/moon.pkg` imports and re-export in `src/lib.mbt` if needed, or leave as a separate import users add explicitly. Given this is opt-in, leave it as a separate package users import directly.

**Step 7: Commit**

```bash
git add src/expect/
git commit -m "feat(expect): add RunResult and RunSummary assertions"
```

---

### Task 7: Update Documentation

Update READMEs and guide docs to show the new assertion patterns.

**Files:**
- Modify: `README.md`
- Modify: `README.mbt.md`

**Step 1: Add assertions section to README.md**

Add a new section after "World and Step Definitions" covering:
- The `moonrockz/expect` package and its matchers
- Step context enrichment (automatic, no user action needed)
- `moonspec/expect` for RunResult assertions
- Migration note: `run_or_fail` no longer needs `|> ignore`

**Step 2: Update README.mbt.md Quick Start**

Ensure the Quick Start shows `run_or_fail` without `|> ignore`.

**Step 3: Commit**

```bash
git add README.md README.mbt.md
git commit -m "docs: add assertions and matchers documentation"
```
