# Testing Strategies

This guide covers the runtime options and patterns that control how moonspec selects, executes, retries, and reports your scenarios.

## Tag Filtering

Tags are annotations on Features, Rules, and Scenarios. moonspec supports boolean tag expressions to select which scenarios run.

### Basics

Tags declared on a Feature are inherited by every Scenario inside it. A Scenario's effective tag set is the union of its own tags and all ancestor tags.

```gherkin
@smoke
Feature: User login

  @fast
  Scenario: Login with valid credentials
    # effective tags: @smoke, @fast
    Given a registered user
    When the user logs in
    Then login succeeds

  @slow
  Scenario: Login with expired session
    # effective tags: @smoke, @slow
    Given an expired session
    When the user logs in
    Then the session is renewed
```

### Tag Expressions

Pass a tag expression string to `opts.tag_expr()` to filter scenarios before execution:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/login.feature"),
])
opts.tag_expr("@smoke and not @slow")
let result = @moonspec.run(MyWorld::default, opts)
```

The expression language supports the following operators:

| Expression                     | Meaning                                   |
|-------------------------------|-------------------------------------------|
| `@smoke`                      | Scenarios tagged `@smoke`                 |
| `not @slow`                   | Scenarios *not* tagged `@slow`            |
| `@smoke and not @slow`        | Tagged `@smoke` but not `@slow`           |
| `@smoke or @regression`       | Tagged `@smoke` or `@regression` (or both)|
| `(@smoke or @fast) and not @wip` | Compound with parentheses              |

Operator precedence from lowest to highest: `or`, `and`, `not`. Use parentheses to override.

An empty expression matches all scenarios.

### Example: Cross-Feature Filtering

Tag expressions work across multiple feature files:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
  @moonspec.FeatureSource::File("features/checkout.feature"),
  @moonspec.FeatureSource::File("features/inventory.feature"),
])
opts.tag_expr("@smoke")
let result = @moonspec.run(MyWorld::default, opts)
// Only scenarios tagged @smoke from all three features
```

---

## Scenario Outlines

Scenario Outlines let you run the same scenario structure with different data. Placeholders in angle brackets are substituted with values from the Examples table.

### Basic Outline

```gherkin
Feature: Calculator

  Scenario Outline: Addition
    Given the calculator is reset
    When I add <a> and <b>
    Then the result is <sum>

    Examples:
      | a  | b  | sum |
      | 1  | 2  | 3   |
      | 10 | 20 | 30  |
      | -1 | 1  | 0   |
```

Each row in the Examples table produces a separate scenario at compile time. The generated scenario names include the parameter values for identification:

- `Addition (a=1, b=2, sum=3)`
- `Addition (a=10, b=20, sum=30)`
- `Addition (a=-1, b=1, sum=0)`

### Multiple Examples Blocks

A single Scenario Outline can have multiple Examples blocks. This is useful for grouping related data or applying different tags to subsets:

```gherkin
Feature: Checkout

  Scenario Outline: Apply discount
    Given a cart with total <total>
    When I apply coupon "<coupon>"
    Then the discount is <discount>

    @valid-coupons
    Examples: Valid coupons
      | total | coupon  | discount |
      | 100   | SAVE10  | 10       |
      | 200   | SAVE20  | 40       |

    @expired-coupons
    Examples: Expired coupons
      | total | coupon  | discount |
      | 100   | OLD50   | 0        |
```

Tags from Examples blocks are merged with Feature and Scenario tags. In the example above, the first two scenarios have the `@valid-coupons` tag and the third has `@expired-coupons`.

### How Substitution Works

Placeholders like `<a>` in step text are replaced literally with the corresponding cell value from each row. Substitution also applies inside DocStrings and DataTable arguments attached to steps.

Step definitions match against the substituted text, so a step definition matching `"I add {int} and {int}"` handles all rows of the Addition outline above.

---

## Parallel Execution

By default, moonspec runs scenarios sequentially. Enable parallel execution to run scenarios concurrently.

### Configuration

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
  @moonspec.FeatureSource::File("features/checkout.feature"),
])
opts.parallel(true)          // enable concurrent execution
opts.max_concurrent(4)       // at most 4 scenarios at once (default: 4)
```

### Isolation

Each scenario receives a fresh World instance created by the factory function. Because worlds are never shared between concurrent scenarios, parallel execution is safe without additional synchronization.

```moonbit
// Each scenario gets its own EcomWorld via this factory
@moonspec.run_or_fail(EcomWorld::default, opts)
```

### Requirements

Parallel execution relies on MoonBit's async runtime. Your test must be declared `async` and run with the JavaScript target:

```moonbit
async test "parallel ecommerce tests" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.parallel(true)
  opts.max_concurrent(8)
  @moonspec.run_or_fail(EcomWorld::default, opts) |> ignore
}
```

```bash
moon test --target js
```

The `--target js` flag is required because MoonBit's async primitives currently require the JavaScript backend.

---

## Retrying Flaky Tests

moonspec can automatically retry failed scenarios with a fresh World on each attempt.

### Global Retry

Set a global retry count that applies to all scenarios:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/flaky.feature"),
])
opts.retries(2) // retry failed scenarios up to 2 additional times
```

With `retries(2)`, a failing scenario gets up to 3 total attempts (1 original + 2 retries).

### Per-Scenario Retry

Use the `@retry(N)` tag to override the global setting for individual scenarios:

```gherkin
Feature: External API

  @retry(3)
  Scenario: Fetch exchange rates
    Given the API is available
    When I request exchange rates
    Then rates are returned

  @retry(0)
  Scenario: Validate cached response
    # This scenario never retries, even with a global retry setting
    Given a cached response
    When I validate the cache
    Then the cache is valid
```

The `@retry(N)` tag takes priority over the global `retries` value. Use `@retry(0)` to explicitly opt a scenario out of retries. The maximum allowed value is 100.

### How Retries Work

- **Fresh World per attempt.** Each retry creates a new World instance via the factory function. No state leaks between attempts.
- **Immediate retry.** A failed scenario is retried immediately, before moving on to the next scenario.
- **Only failures trigger retries.** Scenarios with Undefined, Pending, or Skipped status are not retried.
- **Final result counts.** Only the last attempt's outcome appears in the `RunResult`. If a scenario fails twice then passes on the third attempt, it counts as passed.
- **`RunSummary.retried` tracks retried scenarios.** This count includes any scenario that required more than one attempt, regardless of final outcome.

### Cucumber Messages

When sinks are attached, each attempt emits its own `TestCaseStarted` / `TestCaseFinished` envelope pair. The `TestCaseStarted` envelope includes an `attempt` field (0-indexed), and the `TestCaseFinished` envelope includes a `willBeRetried` flag indicating whether another attempt will follow.

---

## Dry-Run Mode

Dry-run mode validates that all steps have matching definitions without actually executing any step handlers or hooks.

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.dry_run(true)
let result = @moonspec.run(MyWorld::default, opts)
```

### Behavior

- **Matched steps** are reported as `Skipped("dry run")`.
- **Undefined steps** are reported as `Undefined` with generated snippets suggesting step definitions.
- **No hooks** are called (before/after test case, before/after step).
- **No retries** are attempted.

### Use Case: CI Validation

Dry-run mode is useful in CI pipelines to verify that all Gherkin steps have corresponding step definitions before committing to a full test run:

```moonbit
async test "step coverage check" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.dry_run(true)
  // run_or_fail raises if any steps are undefined
  @moonspec.run_or_fail(MyWorld::default, opts) |> ignore
}
```

---

## Skipping Scenarios

### Skip Tags

Use the `@skip` or `@ignore` tag to skip a scenario entirely:

```gherkin
Feature: Payments

  @skip
  Scenario: Pay with cryptocurrency
    Given a crypto wallet
    When I pay with Bitcoin
    Then payment is processed

  @ignore("blocked by API vendor")
  Scenario: Pay with wire transfer
    Given a bank account
    When I initiate a wire transfer
    Then transfer is queued
```

Skipped scenarios do not execute any steps or hooks. The optional reason in parentheses (e.g., `@skip("not-ready")` or `@ignore("blocked")`) is propagated to results and Cucumber Messages output.

### Custom Skip Tags

By default, `@skip` and `@ignore` are recognized as skip tags. You can configure additional skip tags:

```moonbit
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/payments.feature"),
])
opts.skip_tags(["@skip", "@ignore", "@wip"])
```

This can also be set in `moonspec.json5`:

```json5
{
  "skip_tags": ["@skip", "@ignore", "@wip"]
}
```

### Limitations

Gherkin tags cannot contain spaces. The tokenizer splits at whitespace, so tags like `@skip("not ready")` will not parse correctly. Use single-word or underscore-separated reasons instead:

```gherkin
# Good
@skip("not_ready")
@ignore("blocked_by_api")

# Bad — will not parse as expected
@skip("not ready")
```

### Skip Tags vs Tag Expressions

Skip tags and tag expressions serve different purposes and operate at different stages:

| Aspect | Tag expressions | Skip tags |
|--------|----------------|-----------|
| Purpose | Select which scenarios to run | Prevent execution of matched scenarios |
| When applied | During scenario selection (filtering) | After selection, before execution |
| Retry behavior | Filtered scenarios never enter the runner | Skipped scenarios bypass retry logic |
| API | `opts.tag_expr("@smoke")` | `opts.skip_tags(["@skip"])` |

Both can be used together. Tag expressions filter first, then skip tags are checked on the filtered set.

---

## Formatters

Formatters receive Cucumber Messages events during a test run and produce output in various formats. They implement the `MessageSink` trait.

### Pretty Formatter

Human-readable colored console output with pass/fail markers:

```moonbit
let fmt = @format.PrettyFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
println(fmt.output())
```

Disable colors for CI environments or file output:

```moonbit
let fmt = @format.PrettyFormatter::new(no_color=true)
```

Sample output:

```
Feature: Shopping Cart

  Scenario: Add item to cart
    ✓ Given an empty cart
    ✓ When I add "Laptop" to the cart
    ✓ Then the cart contains 1 item

1 scenario (1 passed)
```

### Messages Formatter

Standard Cucumber Messages in NDJSON (newline-delimited JSON) format for integration with external tools, reporting dashboards, and the Cucumber ecosystem:

```moonbit
let fmt = @format.MessagesFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
let ndjson = fmt.output() // each line is a JSON envelope
```

### JUnit Formatter

JUnit XML output for CI/CD systems (Jenkins, GitHub Actions, GitLab CI):

```moonbit
let fmt = @format.JUnitFormatter::new()
let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(fmt)
let result = @moonspec.run(MyWorld::default, opts)
let xml = fmt.output()
```

The XML follows the standard JUnit format:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="3" failures="0">
  <testsuite name="Shopping Cart" tests="3">
    <testcase name="Add item to cart" classname="Shopping Cart"/>
    <testcase name="Remove item from cart" classname="Shopping Cart"/>
    <testcase name="Empty cart" classname="Shopping Cart"/>
  </testsuite>
</testsuites>
```

### Using Multiple Formatters

You can attach multiple sinks to a single run. Each receives the same stream of Cucumber Messages envelopes:

```moonbit
let pretty = @format.PrettyFormatter::new()
let messages = @format.MessagesFormatter::new()
let junit = @format.JUnitFormatter::new()

let opts = @moonspec.RunOptions::new([
  @moonspec.FeatureSource::File("features/cart.feature"),
])
opts.add_sink(pretty)
opts.add_sink(messages)
opts.add_sink(junit)

let result = @moonspec.run(MyWorld::default, opts)
println(pretty.output())  // console output
// messages.output()       // NDJSON for tooling
// junit.output()          // XML for CI
```

### Custom Sinks

Any type implementing the `MessageSink` trait can be used as a sink:

```moonbit
pub(open) trait MessageSink {
  on_message(Self, @cucumber_messages.Envelope) -> Unit
}
```

Register custom sinks with `opts.add_sink(sink)`.

---

## Report Output

Formatters can be configured with output destinations so results are automatically written when the run completes.

### Local Development

For local development, the default pretty formatter provides colored console output:

```json5
{
  "formatters": [
    { "type": "pretty", "output": "stdout" }
  ]
}
```

### CI/CD Integration

For CI pipelines, output JUnit XML alongside console output:

```json5
{
  "formatters": [
    { "type": "pretty", "output": "stderr" },
    { "type": "junit", "output": "reports/results.xml" }
  ]
}
```

### Cucumber Messages

For integration with Cucumber ecosystem tools, use the messages formatter:

```json5
{
  "formatters": [
    { "type": "messages", "output": "reports/messages.ndjson" }
  ]
}
```

---

## Running Tests

### Basic Invocation

moonspec tests are standard MoonBit tests. Run them with the `moon test` command targeting JavaScript:

```bash
moon test --target js
```

The `--target js` flag is required for async execution and parallel support.

### Feature Sources

moonspec supports multiple ways to load feature files:

```moonbit
// Load from the filesystem
let file_source = @moonspec.FeatureSource::File("features/cart.feature")

// Provide Gherkin text directly (useful for tests and dynamic content)
let text_source = @moonspec.FeatureSource::Text(
  "inline://cart.feature",
  #|Feature: Cart
  #|  Scenario: Add item
  #|    Given an empty cart
  #|    When I add "Laptop" to the cart
  #|    Then the cart contains 1 item
  ,
)
```

### Multi-Feature Runs

Pass multiple feature sources to run them together:

```moonbit
async test "all ecommerce features" {
  @moonspec.run_or_fail(
    EcomWorld::default,
    @moonspec.RunOptions::new([
      @moonspec.FeatureSource::File("features/cart.feature"),
      @moonspec.FeatureSource::File("features/checkout.feature"),
      @moonspec.FeatureSource::File("features/inventory.feature"),
    ]),
  )
  |> ignore
}
```

### `run` vs `run_or_fail`

moonspec provides two entry points:

| Function | Behavior on failure |
|----------|-------------------|
| `run` | Returns a `RunResult` with summary and per-scenario details |
| `run_or_fail` | Raises a `MoonspecError` if any scenario fails, is undefined, or is pending |

Use `run_or_fail` in test functions where you want the test to fail on any non-passing scenario. Use `run` when you need to inspect results programmatically:

```moonbit
async test "check specific results" {
  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
  ])
  let result = @moonspec.run(MyWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 3)
  assert_eq(result.summary.passed, 3)
  assert_eq(result.summary.failed, 0)
}
```

### Combining Options

All options compose freely:

```moonbit
async test "full configuration example" {
  let pretty = @format.PrettyFormatter::new()
  let junit = @format.JUnitFormatter::new()

  let opts = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
  ])
  opts.tag_expr("@smoke and not @slow")
  opts.parallel(true)
  opts.max_concurrent(8)
  opts.retries(1)
  opts.skip_tags(["@skip", "@ignore", "@wip"])
  opts.add_sink(pretty)
  opts.add_sink(junit)

  @moonspec.run_or_fail(EcomWorld::default, opts) |> ignore
  println(pretty.output())
}
```
