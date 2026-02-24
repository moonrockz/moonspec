# Full Cucumber Expression Parameter Types — Design

## Problem

Two gaps in our cucumber-expressions library vs the upstream spec:

1. **Missing parameter types** — the spec defines 11 built-in types; we implement 5. Missing: `{double}`, `{long}`, `{byte}`, `{short}`, `{bigdecimal}`, `{biginteger}`.
2. **No transformer functions** — upstream, each parameter type has a transformer that converts matched text to a typed value. Our library returns raw strings and pushes conversion to moonspec's `StepArg::from_param`.

## Scope

Two repos, three concerns:

1. **cucumber-expressions library** — add 6 new `ParamType` variants, `ParamValue` enum with typed built-in values + `CustomVal(@any.Any)` for custom types, transformer functions on `ParamTypeEntry`, built-in transformers for all 11 types
2. **moonspec core** — `StepArg` becomes a struct with `value: StepValue` (pattern-matchable enum mirroring `ParamValue`) + `raw: String` (original text). Update `Setup.add_param_type` to accept transformer callbacks. Simplify `from_param`.

## Design

### Transformer Architecture

Matching upstream (Java, JavaScript, etc.): the transformer lives in the cucumber-expressions library alongside the regex pattern. `Expression.match_` returns already-transformed `ParamValue` values instead of raw strings.

```
Expression.match_("I have 42 cucumbers")
  → regex matches "42"
  → looks up {int} transformer
  → transformer(["42"]) → ParamValue::IntVal(42)
  → returns Param { value: IntVal(42), type_: Int, raw: "42" }
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

**New `ParamValue` enum** — hybrid: closed variants for built-ins, `Any` for customs:

```moonbit
pub(all) enum ParamValue {
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

Built-in types get concrete typed variants with compile-time pattern matching. Custom types use `CustomVal(@any.Any)` for type-erased transformer results — this is the only place `Any` appears.

**Transformer function type:**

```moonbit
type Transformer (Array[String]) -> ParamValue raise Error
```

Receives captured group strings (arity matches capture groups in the regex). Returns a `ParamValue`. Can raise on parse failure.

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
  value : ParamValue  // typed transformed value
  type_ : ParamType   // which parameter type matched
  raw : String        // original matched text
} derive(Show, Eq)
```

**Built-in transformers** — registered in `ParamTypeRegistry::default()`:

| Type | Transformer | Returns |
|------|------------|---------|
| `{int}` | `parse_int(groups[0])` | `IntVal(Int)` |
| `{float}` | `parse_double(groups[0])` | `FloatVal(Double)` |
| `{double}` | `parse_double(groups[0])` | `DoubleVal(Double)` |
| `{long}` | `Int64::from_string(groups[0])` | `LongVal(Int64)` |
| `{byte}` | parse int, cast to Byte | `ByteVal(Byte)` |
| `{short}` | `parse_int(groups[0])` | `ShortVal(Int)` |
| `{string}` | identity | `StringVal(String)` |
| `{word}` | identity | `WordVal(String)` |
| `{bigdecimal}` | `Decimal::from_string(groups[0])` | `BigDecimalVal(Decimal)` |
| `{biginteger}` | `BigInt::from_string(groups[0])` | `BigIntegerVal(BigInt)` |
| `{}` (anon) | identity | `StringVal(String)` |

**Custom type transformers** — users return `CustomVal(@any.Any)`:

```moonbit
// Custom {color} returns an actual Color value wrapped in Any
reg.register("color", ParamType::Custom("color"),
  [RegexPattern("red|green|blue")],
  transformer=fn(groups) { CustomVal(@any.of(Color::from_string(groups[0]))) },
)
```

Default transformer (no transformer provided): `fn(groups) { CustomVal(@any.of(groups[0])) }`.

**New dependencies for cucumber-expressions:**
- `tonyfettes/any` — for `CustomVal(@any.Any)` only
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

**`StepValue` enum** — mirrors `ParamValue` from the library:

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

**`StepArg::from_param` maps `ParamValue` → `StepValue`** — trivial 1:1 mapping:

```moonbit
pub fn StepArg::from_param(param : @cucumber_expressions.Param) -> StepArg {
  let value : StepValue = match param.value {
    IntVal(n) => IntVal(n)
    FloatVal(f) => FloatVal(f)
    DoubleVal(f) => DoubleVal(f)
    LongVal(n) => LongVal(n)
    ByteVal(b) => ByteVal(b)
    ShortVal(n) => ShortVal(n)
    StringVal(s) => StringVal(s)
    WordVal(s) => WordVal(s)
    BigDecimalVal(d) => BigDecimalVal(d)
    BigIntegerVal(bi) => BigIntegerVal(bi)
    CustomVal(any) => CustomVal(any)
  }
  { value, raw: param.raw }
}
```

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

// Custom types — extract actual typed value from Any
match args[0] {
  { value: CustomVal(any), .. } => {
    let color : Color = any.to()
  }
}
```

**`Setup.add_param_type` gains optional transformer:**

```moonbit
// With transformer — returns typed custom value
setup.add_param_type("color", ["red|green|blue"],
  transformer=fn(groups) {
    @cucumber_expressions.ParamValue::CustomVal(@any.of(Color::from_string(groups[0])))
  },
)

// Without transformer — defaults to CustomVal(@any.of(raw_string))
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
- **`Any` for everything** — rejected. Loses compile-time exhaustive matching for built-in types. `Any` is only used for custom types where the return type is unknown at library compile time.
- **No `ParamValue` enum, just `Any` on Param** — rejected. Same reason. Built-in types should be pattern-matchable without runtime type checks.
- **Expose only typed value, hide raw text** — rejected. Users need raw text for diagnostics, logging, and custom parsing.
