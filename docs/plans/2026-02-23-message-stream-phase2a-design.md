# Message Stream Phase 2A: Glue Registration, ParseError & Formatter Migration

## Goal

Emit StepDefinition, ParameterType, and ParseError envelopes, and migrate
PrettyFormatter and JUnitFormatter to be fully envelope-driven MessageSinks.

## Context

Phase 1 (PR #5) established the MessageSink trait and the core envelope stream:
Meta, Source, GherkinDocument, Pickle, TestCase, and the execution lifecycle
envelopes (TestRunStarted/Finished, TestCaseStarted/Finished,
TestStepStarted/Finished). PrettyFormatter and JUnitFormatter implement
MessageSink but their `on_message()` methods are no-ops — they still rely on
direct method calls from the runner.

Phase 2A completes the "planning" portion of the envelope stream (glue
registration metadata) and makes formatters true sinks. Phase 2B (separate
branch) will redesign hooks for cucumber compliance.

## Envelope Ordering After Phase 2A

```
Meta
Source (per feature file)
GherkinDocument | ParseError (per feature file)
Pickle (per scenario)
StepDefinition (per registered step def)
ParameterType (per custom param type)
TestCase (per pickle)
TestRunStarted
  TestCaseStarted / TestStepStarted / TestStepFinished / TestCaseFinished
TestRunFinished
```

## 1. StepDefinition Envelopes

### StepDefId Newtype

Avoid primitive obsession — step definition IDs are a distinct concept:

```moonbit
pub(all) struct StepDefId {
  priv value : String
} derive(Show, Eq, Hash)
```

- Private constructor: only `StepRegistry` mints IDs via its internal
  `IdGenerator`.
- `to_string()` exposes the value for serialization.

### Changes

- Add `id : StepDefId?` to `StepDef`. `None` when user-created, assigned by
  `StepRegistry.register_def()`.
- `StepRegistry` owns an `IdGenerator` and assigns IDs during registration.
- New accessor: `StepRegistry::step_defs() -> Array[StepDef]`.
- `build_test_cases()` wires matched `StepDefId` into
  `TestCase.TestStep.stepDefinitionIds` (currently hardcoded `[]`).
- Emit StepDefinition envelopes after Pickle envelopes, before TestCase.

### cucumber-messages Shape

```json
{
  "stepDefinition": {
    "id": "sd-1",
    "pattern": { "source": "a calculator", "type": "CUCUMBER_EXPRESSION" },
    "sourceReference": { "uri": "steps.mbt", "location": { "line": 10 } }
  }
}
```

## 2. ParameterType Envelopes

- Add `param_types() -> ArrayView[ParamType]` to `ParamTypeRegistry` in the
  `cucumber_expressions` package.
- Emit ParameterType envelopes after StepDefinition, before TestCase.
- Only emit custom types — built-in types (`{int}`, `{float}`, `{string}`,
  `{word}`) are well-known and omitted.
- Thin slice: moonspec doesn't yet expose a public API for custom parameter
  types, so zero envelopes initially. Plumbing is in place for when it does.

### cucumber-messages Shape

```json
{
  "parameterType": {
    "id": "pt-1",
    "name": "color",
    "regularExpressions": ["red|green|blue"],
    "preferForRegularExpressionMatch": false,
    "useForSnippets": true
  }
}
```

## 3. ParseError Envelopes

### Breaking Change to FeatureCache

`load_from_source()` stops raising. Returns `ArrayView[ParseErrorInfo]` — empty
on success, populated on parse failure.

```moonbit
pub(all) struct ParseErrorInfo {
  uri : String
  message : String
  line : Int?
}
```

Features that parse successfully are cached as before. Features that fail are
not cached, and their error info is returned.

### Emission

ParseError envelopes are emitted after GherkinDocument envelopes. A source that
fails to parse gets a ParseError instead of a GherkinDocument.

### RunResult

`RunResult` gains a `parse_errors : Array[ParseErrorInfo]` field. `run_or_fail()`
raises if `parse_errors` is non-empty, in addition to existing failure checks.

### cucumber-messages Shape

```json
{
  "parseError": {
    "source": {
      "uri": "broken.feature",
      "location": { "line": 5 }
    },
    "message": "expected: Feature, got: 'Scenario:'"
  }
}
```

## 4. PrettyFormatter Migration

`on_message()` becomes a state machine that accumulates data from envelopes:

- **GherkinDocument** — store feature name by URI
- **Pickle** — store pickle name/URI by ID
- **TestCaseStarted** — print `Feature:` header (once per feature URI), start
  tracking scenario
- **TestStepFinished** — print step line with pass/fail marker
- **TestCaseFinished** — print scenario status
- **TestRunFinished** — print overall summary

Direct methods removed: `format_feature_start()`, `format_scenario()`,
`format_summary()`.

Internal state: maps for pickles, test cases, feature names; counters for
summary stats.

## 5. JUnitFormatter Migration

`on_message()` buffers envelope data, generates XML on TestRunFinished.

- **GherkinDocument** — store feature name by URI
- **Pickle** — store pickle name/URI by ID
- **TestCase** — store test case ID to pickle ID mapping
- **TestStepFinished** — capture failure messages
- **TestCaseFinished** — finalize test case result
- **TestRunFinished** — generate full JUnit XML from accumulated data

Direct method removed: `format_result()`.

**New dependency:** `Milky2018/xml` for XML generation.

Internal state: lookup maps + `Array[JUnitTestCase]` accumulator.

## 6. Runner Refactoring

- **Build registry once** — currently `build_test_cases()` and each
  `execute_pickle()` create separate registries. Build once at top of `run()`
  and pass down.
- **Remove direct formatter calls** — the runner only calls
  `emit(sinks, envelope)`. Formatters are purely sinks.
- **Parse error collection** — `load_from_source()` returns errors; runner
  emits ParseError envelopes and continues with successfully parsed features.
- **`run_or_fail()`** — raises if `parse_errors` is non-empty or scenarios
  failed/undefined/pending.

## New Dependency

- `Milky2018/xml` — XML generation for JUnitFormatter

## Deferred to Phase 2B

- Hook system redesign (cucumber-compliant BeforeTestRun/AfterTestRun,
  BeforeTestCase/AfterTestCase, hook IDs, tag expressions)
- Hook envelopes
- TestRunHookStarted/TestRunHookFinished envelopes
- Attachment/ExternalAttachment/Suggestion/UndefinedParameterType envelopes
