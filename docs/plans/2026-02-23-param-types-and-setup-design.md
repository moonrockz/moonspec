# ParameterType Envelopes & Setup Facade Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add custom parameter type registration via a new `Setup` facade, emit ParameterType envelopes, and improve type safety in cucumber-expressions.

**Architecture:** Introduce a `Setup` struct as the user-facing configuration API, replacing direct `StepRegistry` access. Lift `ParamTypeRegistry` out of `StepRegistry` so both live as siblings under `Setup`. Add proper types (`RegexPattern`, `ParamTypeEntry`) to cucumber-expressions to eliminate primitive obsession.

**Scope:** Covers moonspec-kyq (ParameterType envelopes), moonspec-hkz (custom parameter type registration), and type safety improvements in cucumber-expressions.

---

## 1. cucumber-expressions Package Changes

### RegexPattern Newtype

```moonbit
pub(all) struct RegexPattern {
  priv value : String

  fn new(value : String) -> RegexPattern
} derive(Show, Eq)

fn RegexPattern::new(value : String) -> RegexPattern {
  { value }
}

pub fn RegexPattern::to_string(self : RegexPattern) -> String {
  self.value
}
```

Usage: `RegexPattern("red|blue|green")` — reads like a constructor call.

### ParamTypeEntry Struct

Replaces the `(String, ParamType, Array[String])` tuple:

```moonbit
pub(all) struct ParamTypeEntry {
  name : String
  type_ : ParamType
  patterns : Array[RegexPattern]
} derive(Show, Eq)
```

### ParamTypeRegistry Encapsulation

```moonbit
pub(all) struct ParamTypeRegistry {
  priv mut entries : Array[ParamTypeEntry]  // was public, now private
}
```

Updated methods:
- `register(self, name, type_, patterns: Array[RegexPattern])` — uses `RegexPattern`
- `get(self, name) -> ParamTypeEntry?` — returns entry instead of tuple
- `entries_view(self) -> ArrayView[ParamTypeEntry]` — NEW, read-only access for envelope emission

### Breaking Changes (pre-1.0, acceptable)

- `entries` field now private (use `entries_view()`)
- `get()` returns `ParamTypeEntry?` instead of `(ParamType, Array[String])?`
- `register()` takes `Array[RegexPattern]` instead of `Array[String]`
- All internal code and tests updated

---

## 2. Setup Facade (moonspec/core)

### New World Trait

```moonbit
pub(open) trait World {
  configure(Self, Setup) -> Unit   // was: register_steps(Self, StepRegistry)
}
```

### Setup Struct

```moonbit
pub(all) struct Setup {
  priv step_registry : StepRegistry
  priv param_registry : @cucumber_expressions.ParamTypeRegistry
}
```

Public API:

```moonbit
// Step registration (delegates to StepRegistry)
pub fn Setup::given(self, pattern, handler) -> Unit
pub fn Setup::when(self, pattern, handler) -> Unit
pub fn Setup::then(self, pattern, handler) -> Unit
pub fn Setup::step(self, pattern, handler) -> Unit

// Parameter type registration
pub fn Setup::add_param_type(
  self, name: String, patterns: Array[RegexPattern],
) -> Unit

// Library composition
pub fn Setup::use_library(self, library) -> Unit
```

### StepRegistry Simplification

`StepRegistry` drops its owned `ParamTypeRegistry`. Methods that need it take it as an explicit parameter:

```moonbit
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv id_gen : IdGenerator
}

pub fn StepRegistry::register_def(
  self, step_def, param_registry,
) -> Unit
```

The convenience methods (`given`, `when`, `then`, `step`) move to `Setup`.

### StepDefId Struct Constructor

Updated for consistency with `RegexPattern`:

```moonbit
pub(all) struct StepDefId {
  priv value : String

  fn new(value : String) -> StepDefId
} derive(Show, Eq, Hash)
```

Usage: `StepDefId("sd-1")` instead of `StepDefId::from_string("sd-1")`.

---

## 3. ParameterType Envelope Emission (moonspec/runner)

In `run()` and `run_with_hooks()`, after StepDefinition envelopes and before TestCase envelopes:

1. Iterate `param_registry.entries_view()`
2. Filter out built-in types (int, float, string, word, anonymous "")
3. For each custom entry, emit a ParameterType envelope:

```json
{
  "parameterType": {
    "id": "pt-1",
    "name": "color",
    "regularExpressions": ["red|blue|green"],
    "preferForRegularExpressionMatch": false,
    "useForSnippets": true
  }
}
```

ID generation uses `IdGenerator` with `"pt-N"` prefix.

Canonical ordering: Meta → Source → GherkinDocument → ParseError → Pickle → StepDefinition → **ParameterType** → TestCase → execution → TestRunFinished

---

## 4. User-Facing API Example

```moonbit
struct MyWorld { mut color : String } derive(Default)

impl @moonspec.World for MyWorld with configure(self, setup) {
  setup.add_param_type("color", [RegexPattern("red|blue|green")])
  setup.given("I pick a {color} cucumber", fn(args) {
    match args[0] { CustomArg(c) => self.color = c | _ => () }
  })
}
```

---

## 5. Package Change Map

| Package | Changes |
|---------|---------|
| **cucumber-expressions** | Add `RegexPattern`, `ParamTypeEntry`; make entries private; add `entries_view()`; update `register()`/`get()` |
| **moonspec/core** | Add `Setup` struct; rename `World.register_steps` → `World.configure`; simplify `StepRegistry`; update `StepDefId` to struct constructor |
| **moonspec/runner** | Create `Setup` in `run()`; emit ParameterType envelopes; update `StepRegistry` usage |
| **moonspec/format** | No changes (envelope-driven) |
| **examples** | Update all World implementations |

## 6. Breaking Changes Summary

All acceptable pre-1.0:

- `World.register_steps` → `World.configure`
- `StepRegistry` no longer user-facing (replaced by `Setup`)
- `StepDefId::from_string` → `StepDefId(value)` (struct constructor)
- `ParamTypeRegistry.entries` now private
- `ParamTypeRegistry.get()` returns `ParamTypeEntry?`
- `ParamTypeRegistry.register()` takes `Array[RegexPattern]`
