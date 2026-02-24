# Full Cucumber Expression Parameter Types — Design

## Problem

Two gaps in our cucumber-expressions library vs the upstream spec:

1. **Missing parameter types** — the spec defines 11 built-in types; we implement 5. Missing: `{double}`, `{long}`, `{byte}`, `{short}`, `{bigdecimal}`, `{biginteger}`.
2. **No transformer functions** — upstream, each parameter type has a transformer that converts matched text to a typed value. Our library returns raw strings and pushes conversion to moonspec's `StepArg::from_param`.

## Scope

Two repos, three concerns:

1. **cucumber-expressions library** — add 6 new `ParamType` variants, transformer functions on `ParamTypeEntry`, built-in transformers for all 11 types, `tonyfettes/any` for type-erased custom transformer return values
2. **moonspec core** — `StepArg` becomes a struct with `value: StepValue` (pattern-matchable enum) + `raw: String` (original text). Add 6 new `StepValue` variants. Update `Setup.add_param_type` to accept transformer callbacks. Simplify `from_param`.

## Design

### Transformer Architecture

Matching upstream (Java, JavaScript, etc.): the transformer lives in the cucumber-expressions library alongside the regex pattern. `Expression.match_` returns already-transformed values instead of raw strings.

```
Expression.match_("I have 42 cucumbers")
  → regex matches "42"
  → looks up {int} transformer
  → transformer(["42"]) → @any.of(42)
  → returns Param { value: @any.of(42), type_: Int, raw: "42" }
```

### Layer 1: cucumber-expressions library

**`ParamType` enum** gains 6 variants:

```moonbit
pub(all) enum ParamType {
  Int; Float; String_; Word; Anonymous
  Double_; Long; Byte; Short; BigDecimal; BigInteger
  Custom(String)
} derive(Show, Eq, ToJson, FromJson)
```

**Transformer function type** — uses `tonyfettes/any` for type erasure:

```moonbit
type Transformer (Array[String]) -> @any.Any raise Error
```

Receives captured group strings (arity matches capture groups in the regex). Returns a type-erased `Any` value. Can raise on parse failure.

**`ParamTypeEntry` gains a transformer field:**

```moonbit
pub(all) struct ParamTypeEntry {
  name : String
  type_ : ParamType
  patterns : Array[RegexPattern]
  transformer : Transformer
}
```

**Updated `Param` struct** — carries both transformed value and raw text:

```moonbit
pub(all) struct Param {
  value : @any.Any    // type-erased transformed value
  type_ : ParamType   // which parameter type matched
  raw : String        // original matched text
} derive(Show, Eq)
```

**Built-in transformers** — registered in `ParamTypeRegistry::default()`:

| Type | Transformer | Returns |
|------|------------|---------|
| `{int}` | `parse_int(groups[0])` | `@any.of(Int)` |
| `{float}` | `parse_double(groups[0])` | `@any.of(Double)` |
| `{double}` | `parse_double(groups[0])` | `@any.of(Double)` |
| `{long}` | `Int64::from_string(groups[0])` | `@any.of(Int64)` |
| `{byte}` | parse int, cast to Byte | `@any.of(Byte)` |
| `{short}` | `parse_int(groups[0])` | `@any.of(Int)` |
| `{string}` | identity | `@any.of(String)` |
| `{word}` | identity | `@any.of(String)` |
| `{bigdecimal}` | `Decimal::from_string(groups[0])` | `@any.of(@decimal.Decimal)` |
| `{biginteger}` | `BigInt::from_string(groups[0])` | `@any.of(BigInt)` |
| `{}` (anon) | identity | `@any.of(String)` |

**Custom type transformers** — users provide `(Array[String]) -> @any.Any`:

```moonbit
// Custom {color} returns an actual Color value
reg.register("color", ParamType::Custom("color"),
  [RegexPattern("red|green|blue")],
  transformer=fn(groups) { @any.of(Color::from_string(groups[0])) },
)
```

Default transformer (no transformer provided) boxes the raw string: `fn(groups) { @any.of(groups[0]) }`.

**New dependencies for cucumber-expressions:**
- `tonyfettes/any` — for type-erased `Any` values
- `moonbitlang/core/strconv` — for `parse_int`, `parse_double`
- `moonbitlang/x/decimal` — for `Decimal::from_string` (already depends on `moonbitlang/x`)

### Layer 2: moonspec core

**`StepArg` changes from enum to struct** — exposes both typed value and raw text:

```moonbit
pub(all) struct StepArg {
  value : StepValue   // typed converted value (pattern-matchable)
  raw : String        // original matched text
} derive(Show, Eq)
```

**New `StepValue` enum** — hybrid: closed enum for built-ins, `Any` for customs:

```moonbit
pub(all) enum StepValue {
  IntVal(Int)
  FloatVal(Double)
  DoubleVal(Double)
  LongVal(Int64)
  ByteVal(Byte)
  ShortVal(Int)
  StringVal(String)
  WordVal(String)
  BigDecimalVal(@decimal.Decimal)
  BigIntegerVal(BigInt)
  CustomVal(@any.Any)
} derive(Show, Eq)
```

**`StepArg::from_param` maps `Param` → `StepArg`:**

Extracts the `Any` value from `Param`, uses `any.try_to()` to dispatch to the correct `StepValue` variant based on `ParamType`, and carries the raw string through.

**Pattern matching ergonomics** — struct destructuring works naturally:

```moonbit
// Match typed value, ignore raw
match args[0] {
  { value: IntVal(n), .. } => use(n)
}

// Match both
match args[0] {
  { value: IntVal(n), raw } => println("\{n} from '\{raw}'")
}

// Custom types — extract actual typed value
match args[0] {
  { value: CustomVal(any), .. } => {
    let color : Color = any.to()
  }
}
```

**`Setup.add_param_type` gains optional transformer:**

```moonbit
// With transformer — returns typed value
setup.add_param_type("color", ["red|green|blue"],
  transformer=fn(groups) { @any.of(Color::from_string(groups[0])) },
)

// Without transformer — defaults to boxing raw string
setup.add_param_type_strings("direction", ["north|south|east|west"])
```

**Breaking changes in moonspec:**
- `StepArg` changes from enum to struct (all handler pattern matches need updating)
- `StepArg::IntArg(n)` becomes `{ value: IntVal(n), .. }`
- `Setup.add_param_type` signature changes

**New dependency for moonspec:**
- `tonyfettes/any` — for `CustomVal(@any.Any)` and transformer return type

## Rejected Alternatives

- **Store BigDecimal/BigInteger as raw strings** — rejected. `BigInt` is in core and `Decimal` is in `moonbitlang/x` which we consider a base library.
- **Transformers in moonspec only** — rejected. Upstream spec places transformers in the expression library.
- **`ParamValue` closed enum for everything** — rejected. Custom types become second-class (`CustomVal(String)`). With `Any`, custom types are first-class — `{color}` returns actual `Color`, not a string.
- **`Any` for everything (no enum)** — rejected. Loses compile-time exhaustive matching for built-in types. Hybrid approach gives both: enum for built-ins, `Any` for customs.
- **Expose only typed value, hide raw text** — rejected. Users need raw text for diagnostics, logging, and custom parsing.
