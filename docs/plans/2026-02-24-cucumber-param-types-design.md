# Full Cucumber Expression Parameter Types — Design

## Problem

The upstream [Cucumber Expressions spec](https://github.com/cucumber/cucumber-expressions/blob/main/README.md#parameter-types) defines 11 built-in parameter types. Our `cucumber-expressions` library only implements 5 (int, float, string, word, anonymous). The remaining 6 are missing: `{double}`, `{long}`, `{byte}`, `{short}`, `{bigdecimal}`, `{biginteger}`.

## Scope

Two layers need updates:

1. **cucumber-expressions library** — add 6 new `ParamType` variants and register them in `ParamTypeRegistry::default()`
2. **moonspec core** — add 6 new `StepArg` variants with typed conversion in `from_param`

## Design

### Layer 1: cucumber-expressions library

**ParamType enum** gains 6 variants:

| Variant | Expression | Regex | Same pattern as |
|---------|-----------|-------|-----------------|
| `Double_` | `{double}` | float regex | `Float` |
| `Long` | `{long}` | int regex | `Int` |
| `Byte` | `{byte}` | int regex | `Int` |
| `Short` | `{short}` | int regex | `Int` |
| `BigDecimal` | `{bigdecimal}` | float regex | `Float` |
| `BigInteger` | `{biginteger}` | int regex | `Int` |

The library does zero value conversion — it only matches text and returns raw `String` captures with a `ParamType` identifier.

### Layer 2: moonspec core

**StepArg enum** gains 6 variants with typed values:

| Variant | MoonBit Type | Conversion |
|---------|-------------|------------|
| `DoubleArg(Double)` | `Double` | `@strconv.parse_double` |
| `LongArg(Int64)` | `Int64` | `Int64::from_string` |
| `ByteArg(Byte)` | `Byte` | parse int, validate 0–255, cast |
| `ShortArg(Int)` | `Int` | parse int, validate -32768..32767 |
| `BigDecimalArg(@decimal.Decimal)` | `@decimal.Decimal` | `Decimal::from_string` |
| `BigIntegerArg(BigInt)` | `BigInt` | `BigInt::from_string` |

**Dependencies:**
- `BigInt` — already in `moonbitlang/core/bigint` (no new dep)
- `Decimal` — from `moonbitlang/x/decimal` (new dep for moonspec)

## Rejected Alternatives

- **Store BigDecimal/BigInteger as raw strings** — rejected because `BigInt` is in core and `Decimal` is in `moonbitlang/x` which we consider a base library. Typed values are more ergonomic for step handlers.
