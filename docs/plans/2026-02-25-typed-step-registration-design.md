# Typed Step Registration Design

## Goal

Improve step registration ergonomics by allowing typed lambda parameters that bind directly to cucumber expression values, eliminating manual pattern matching on `StepArg`/`StepValue`.

## Current State

```moonbit
setup.given("I add {string} with quantity {int}", fn(args) {
  match (args[0], args[1]) {
    ({ value: StringVal(name), .. }, { value: IntVal(qty), .. }) => {
      // use name, qty
    }
    _ => ()
  }
})
```

## Proposed API

```moonbit
// Zero params
setup.given0("an empty cart", fn() { cart.clear() })
setup.given0_ctx("an empty cart", fn(ctx: Ctx) { ... })

// Typed params — values extracted automatically
setup.given1("I have {int} cucumbers", fn(count: Int) { ... })
setup.given1_ctx("I have {int}", fn(count: Int, ctx: Ctx) { ... })

setup.given2("I add {string} at price {int}", fn(name: String, price: Int) { ... })
setup.given2_ctx("I add {string} at price {int}", fn(name: String, price: Int, ctx: Ctx) { ... })

// Up to arity 22
```

Same pattern for `when`, `then`, `step` keywords. Same pattern for `StepDef` factory constructors.

The original `setup.given("pattern", fn(ctx) { ... })` remains unchanged for advanced use cases.

## FromStepArg Trait

```moonbit
pub(open) trait FromStepArg {
  from_step_arg(StepArg) -> Self raise Error
}
```

Implementations for all StepValue-backed types:

| MoonBit Type | StepValue Variant | Expression Type |
|---|---|---|
| `Int` | `IntVal` | `{int}` |
| `Double` | `FloatVal`, `DoubleVal` | `{float}`, `{double}` |
| `Int64` | `LongVal` | `{long}` |
| `Byte` | `ByteVal` | `{byte}` |
| `String` | `StringVal`, `WordVal`, `AnonymousVal` | `{string}`, `{word}`, `{}` |
| `BigInt` | `BigIntegerVal` | `{biginteger}` |
| `@decimal.Decimal` | `BigDecimalVal` | `{bigdecimal}` |
| `@any.Any` | `CustomVal` | custom types |
| `DataTable` | `DataTableVal` | data tables |
| `DocString` | `DocStringVal` | doc strings |

Type mismatches raise `Error` at match time with a descriptive message.

## Method Signatures

Generic with trait constraints:

```moonbit
pub fn[A : FromStepArg] Setup::given1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit

pub fn[A : FromStepArg, B : FromStepArg] Setup::given2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit

// _ctx variants: Ctx is always the last parameter
pub fn[A : FromStepArg] Setup::given1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit
```

## Internal Implementation

Each typed method wraps the handler in a `(Ctx) -> Unit raise Error` closure that:

1. Extracts `StepArg` values from `Ctx` by index
2. Calls `FromStepArg::from_step_arg(arg)` for each typed parameter
3. Validates arity: expression param count must match expected arg count
4. Calls the user's handler with the extracted values
5. For `_ctx` variants, passes the `Ctx` object as the last argument

```moonbit
pub fn[A : FromStepArg, B : FromStepArg] Setup::given2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    let args = ctx.args()
    if args.length() != 2 {
      raise "expected 2 args, got " + args.length().to_string()
    }
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}
```

## Scope

- `Setup` methods: `given0`-`given22`, `given0_ctx`-`given22_ctx` (same for when/then/step)
- `StepDef` factories: `StepDef::given0`-`StepDef::given22`, `StepDef::given0_ctx`-`StepDef::given22_ctx` (same for when/then/step)
- Total: 4 keywords x 23 arities x 2 (with/without ctx) = 184 methods per API surface
- `FromStepArg` trait + implementations for 10 types
- All methods follow the same pattern — generated or macro-expanded

## Backward Compatibility

- Existing `setup.given("pattern", fn(ctx) { ... })` is unchanged
- Existing `StepDef::given("pattern", fn(ctx) { ... })` is unchanged
- New methods are purely additive
