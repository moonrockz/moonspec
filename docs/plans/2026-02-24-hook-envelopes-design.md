# Hook Envelope Compliance Design

**Goal:** Full cucumber-messages hook compliance — registration-based hooks on Setup, Hook/TestRunHookStarted/TestRunHookFinished envelope emission, runner consolidation via RunOptions.

**Scope:** Hook envelopes only. Attachment envelopes deferred to a separate issue.

---

## 1. Remove Hooks Trait, Register on Setup

The current `Hooks` trait (`before_scenario`, `after_scenario`, `before_step`, `after_step`) is removed. Hooks become registration-based on `Setup`, matching how steps are registered.

Rename to cucumber terminology:

| Old (trait method)   | New (Setup method)          | Cucumber HookType    |
|----------------------|-----------------------------|----------------------|
| `before_scenario`    | `setup.before_test_case()`  | `BeforeTestCase`     |
| `after_scenario`     | `setup.after_test_case()`   | `AfterTestCase`      |
| `before_step`        | `setup.before_test_step()`  | `BeforeTestStep`     |
| `after_step`         | `setup.after_test_step()`   | `AfterTestStep`      |
| *(new)*              | `setup.before_test_run()`   | `BeforeTestRun`      |
| *(new)*              | `setup.after_test_run()`    | `AfterTestRun`       |

Registration captures source location via MoonBit's `#callsite(autofill(loc))` attribute, populating the `sourceReference` field in Hook envelopes.

```moonbit
impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.before_test_case(fn(info) {
    // runs before each scenario
  })
  setup.given("a step", fn(args) { ... })
  setup.after_test_case(fn(info, result) {
    // runs after each scenario
  })
}
```

Multiple hooks per type are supported (e.g., two `before_test_case` hooks). They execute in registration order.

## 2. HookRegistry

New struct inside `Setup`, sibling to `StepRegistry` and `ParamTypeRegistry`:

```moonbit
pub(all) struct Setup {
  priv step_reg : StepRegistry
  priv param_reg : @cucumber_expressions.ParamTypeRegistry
  priv hook_reg : HookRegistry
}
```

`HookRegistry` stores registered hooks with:
- Unique ID (assigned at registration)
- HookType (which of the 6 types)
- Handler function
- Source location (from `#callsite`)

## 3. RunOptions

Replace the growing parameter lists on `run` / `run_with_hooks` with a single options struct using struct constructor and private fields:

```moonbit
pub(all) struct RunOptions {
  priv features : Array[FeatureSource]
  priv mut parallel_ : Bool              // default: false
  priv mut max_concurrent_ : Int         // default: 4
  priv sinks : Array[&@core.MessageSink]

  fn new(features : Array[FeatureSource]) -> RunOptions
}
```

Builder-style methods for configuration (return `Unit`, use `..` cascade):

```moonbit
pub fn RunOptions::parallel(self, value : Bool) -> Unit
pub fn RunOptions::max_concurrent(self, value : Int) -> Unit
pub fn RunOptions::add_sink(self, sink : &@core.MessageSink) -> Unit
```

Usage with MoonBit's `..` cascade syntax:

```moonbit
let opts = RunOptions(features)
  ..parallel(true)
  ..max_concurrent(4)
  ..add_sink(my_formatter)
run(MyWorld::default, opts)
```

## 4. Runner Consolidation

- **Single `run(factory, options)`** replaces both `run` and `run_with_hooks`
- **Single `execute_scenario`** replaces both variants — checks for hooks at runtime
- **Single sequential/parallel path** — no more `_with_hooks` duplicates
- The `W : @core.Hooks` type constraint is removed entirely — hooks are runtime configuration, not compile-time traits

## 5. Envelope Emission

### Hook Envelopes (planning phase)

One `Hook` envelope per registered hook, emitted after ParameterType envelopes and before TestCase:

```json
{
  "hook": {
    "id": "hook-1",
    "name": "",
    "sourceReference": { "uri": "src/world.mbt", "location": { "line": 12 } },
    "type": "BEFORE_TEST_CASE"
  }
}
```

### TestRunHookStarted / TestRunHookFinished (run boundaries)

For `before_test_run` hooks: emit `TestRunHookStarted` before calling the hook, `TestRunHookFinished` after (with result status and duration).

For `after_test_run` hooks: same pattern, at the end of the run.

```json
{
  "testRunHookStarted": {
    "id": "trhs-1",
    "testRunStartedId": "tr-1",
    "hookId": "hook-1",
    "timestamp": { "seconds": 1234, "nanos": 0 }
  }
}
```

### Test-case and test-step hooks (execution phase)

Per the cucumber protocol, test-case hooks are modeled as special test steps within the `TestCase` envelope. Each `TestCase` gets additional hook-type test steps (before/after) that reference the `Hook` envelope's ID via `hookId`. At execution time, these hook steps emit `TestStepStarted` / `TestStepFinished` like regular steps.

Similarly, `before_test_step` / `after_test_step` wrap each regular step.

### Emission Order

```
Meta
Source, GherkinDocument, ParseError
Pickle
StepDefinition
ParameterType
Hook                          ← new
TestCase (includes hook steps) ← updated
TestRunStarted
TestRunHookStarted/Finished   ← new (before_test_run)
TestCaseStarted
  TestStepStarted/Finished    ← includes hook steps
TestCaseFinished
TestRunHookStarted/Finished   ← new (after_test_run)
TestRunFinished
```

## 6. Testing Strategy

- Test hook registration on Setup (unit)
- Test Hook envelope emission (count, fields, ordering)
- Test TestRunHookStarted/Finished for before/after test run
- Test hook steps appear in TestCase envelope
- Test multiple hooks per type execute in order
- Test hook failure propagation (before_test_case failure skips steps)
- Test that existing hook behavior is preserved after migration
