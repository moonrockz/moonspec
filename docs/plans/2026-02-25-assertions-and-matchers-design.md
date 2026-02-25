# Assertions and Matchers Design

**Goal:** Add ergonomic assertion/matcher support across three layers: a standalone expect library, moonspec core improvements, and RunResult-specific assertions.

**Architecture:** Three layered pieces — a standalone `moonrockz/expect` package for general-purpose `expect(x).to_equal(y)` matchers, moonspec core changes (`run_or_fail` returns `Unit`, step context enrichment), and a `moonspec/expect` subpackage for RunResult assertions.

---

## 1. `moonrockz/expect` — Standalone Expect Library

A new mooncakes package, independent of moonspec. Usable in any MoonBit project.

### API

```moonbit
// Entry point
pub fn expect[T](actual : T) -> Expectation[T]

// Equality (T : Eq + Show)
expect(x).to_equal(5)
expect(x).to_not_equal(3)

// Boolean
expect(b).to_be_true()
expect(b).to_be_false()

// Option
expect(opt).to_be_some()
expect(opt).to_be_none()

// Collections/String
expect(s).to_contain("foo")       // String contains substring
expect(arr).to_contain(item)      // Array contains element
expect(arr).to_be_empty()         // length == 0
expect(arr).to_have_length(3)     // length check
```

All matchers raise `Error` with descriptive messages on failure:
- `"Expected 3 to equal 5"`
- `"Expected [Apple, Banana] to contain Widget"`
- `"Expected Some(42) to be None"`

No custom matcher extensibility in v1.

---

## 2. `run_or_fail` Returns `Unit` + Step Context Enrichment

### Breaking change: `run_or_fail` signature

```moonbit
// Before:
pub async fn run_or_fail(factory, options) -> RunResult

// After:
pub async fn run_or_fail(factory, options) -> Unit
```

Users who want `RunResult` use `run()`. Callers no longer need `|> ignore`.

### Step context enrichment

The executor's catch block wraps assertion errors with step context:

```
// Raw assertion error:
"assertion failed: 3 != 5"

// Enriched by executor:
"Step 'the result should be 5' (Then): assertion failed: 3 != 5"
```

This is transparent — works with `assert_eq!`, `expect().to_equal()`, or any error. No changes needed in step handlers.

---

## 3. `moonspec/expect` — RunResult Assertions

A subpackage within moonspec for run result inspection.

### API

```moonbit
// Run-level
expect(result).to_have_passed()
expect(result).to_have_failed()
expect(result).to_have_no_parse_errors()
expect(result).to_have_feature("Cart")

// Summary-level
expect(result.summary).to_have(passed=3)
expect(result.summary).to_have(passed=3, failed=0)
expect(result.summary).to_have(skipped=2)

// Scenario-level
expect(result).to_have_scenario("Addition", status=Passed)
expect(result).to_have_scenario("Division by zero", status=Failed)
```

Failure messages are rich — include failing scenario names and step diagnostics:

```
Expected run to have passed, but 2 scenarios failed:
  Feature: Cart / Scenario: Add item — Step 'the total should be 10': expected 7 to equal 10
  Feature: Cart / Scenario: Remove item — undefined step 'I remove the item'
```

---

## 4. Testing Strategy

**`moonrockz/expect`:**
- Unit tests for each matcher (happy path + failure message verification)
- Test that failures raise with descriptive messages

**`moonspec` core:**
- Update existing tests to drop `|> ignore` from `run_or_fail` calls
- Test step context enrichment — verify failure messages include step keyword and text

**`moonspec/expect`:**
- Integration tests using inline features with known outcomes
- Test each assertion variant and failure message content

**Backwards compatibility:**
- `run_or_fail` returning `Unit` is a breaking change — update all examples, generated code, docs, and codegen output
- Step context enrichment is transparent — no breaking changes
