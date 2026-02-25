# Typed Step Registration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add arity-suffixed typed step registration methods (`given0`–`given5`, `given0_ctx`–`given5_ctx`, etc.) with a `FromStepArg` trait that auto-extracts typed values from `StepArg`, eliminating manual pattern matching.

**Architecture:** Define a `FromStepArg` trait with implementations for all `StepValue`-backed types. Add generic arity-suffixed methods on `Setup` and `StepDef` that wrap typed lambdas in a `(Ctx) -> Unit raise Error` closure, extracting and converting arguments by index. Start with arities 0–5 (expandable to 22 later via the same pattern).

**Tech Stack:** MoonBit generics with trait constraints, `@decimal.Decimal`, `@any.Any`, `BigInt`

---

### Task 1: FromStepArg Trait and Core Type Implementations

**Files:**
- Create: `src/core/from_step_arg.mbt`
- Test: `src/core/from_step_arg_wbtest.mbt`

**Step 1: Write the failing tests**

Create `src/core/from_step_arg_wbtest.mbt`:

```moonbit
///|
test "FromStepArg: Int from IntVal" {
  let arg : StepArg = { value: IntVal(42), raw: "42" }
  let result : Int = FromStepArg::from_step_arg(arg)
  assert_eq!(result, 42)
}

///|
test "FromStepArg: Int from non-IntVal raises" {
  let arg : StepArg = { value: StringVal("hello"), raw: "hello" }
  let result : Result[Int, _] = try { Ok(FromStepArg::from_step_arg(arg)) } catch { e => Err(e) }
  assert_true!(result.is_err())
}

///|
test "FromStepArg: Double from FloatVal" {
  let arg : StepArg = { value: FloatVal(3.14), raw: "3.14" }
  let result : Double = FromStepArg::from_step_arg(arg)
  assert_eq!(result, 3.14)
}

///|
test "FromStepArg: Double from DoubleVal" {
  let arg : StepArg = { value: DoubleVal(2.718), raw: "2.718" }
  let result : Double = FromStepArg::from_step_arg(arg)
  assert_eq!(result, 2.718)
}

///|
test "FromStepArg: Int64 from LongVal" {
  let arg : StepArg = { value: LongVal(9999999999L), raw: "9999999999" }
  let result : Int64 = FromStepArg::from_step_arg(arg)
  assert_eq!(result, 9999999999L)
}

///|
test "FromStepArg: Byte from ByteVal" {
  let arg : StepArg = { value: ByteVal(b'\xFF'), raw: "255" }
  let result : Byte = FromStepArg::from_step_arg(arg)
  assert_eq!(result, b'\xFF')
}

///|
test "FromStepArg: String from StringVal" {
  let arg : StepArg = { value: StringVal("hello"), raw: "hello" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq!(result, "hello")
}

///|
test "FromStepArg: String from WordVal" {
  let arg : StepArg = { value: WordVal("world"), raw: "world" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq!(result, "world")
}

///|
test "FromStepArg: String from AnonymousVal" {
  let arg : StepArg = { value: AnonymousVal("anon"), raw: "anon" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq!(result, "anon")
}

///|
test "FromStepArg: BigInt from BigIntegerVal" {
  let arg : StepArg = { value: BigIntegerVal(42N), raw: "42" }
  let result : BigInt = FromStepArg::from_step_arg(arg)
  assert_eq!(result, 42N)
}

///|
test "FromStepArg: DataTable from DataTableVal" {
  let dt = DataTable::from_rows([["name", "qty"], ["apple", "3"]])
  let arg : StepArg = { value: DataTableVal(dt), raw: "" }
  let result : DataTable = FromStepArg::from_step_arg(arg)
  assert_eq!(result.row_count(), 2)
}

///|
test "FromStepArg: DocString from DocStringVal" {
  let ds : DocString = { content: "hello world", media_type: None }
  let arg : StepArg = { value: DocStringVal(ds), raw: "" }
  let result : DocString = FromStepArg::from_step_arg(arg)
  assert_eq!(result.content, "hello world")
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `FromStepArg` trait not defined

**Step 3: Write the trait and all implementations**

Create `src/core/from_step_arg.mbt`:

```moonbit
///|
/// Trait for extracting typed values from step arguments.
/// Implementations convert a StepArg into the target type,
/// raising an Error if the StepValue variant doesn't match.
pub(open) trait FromStepArg {
  from_step_arg(StepArg) -> Self raise Error
}

///|
impl FromStepArg for Int with from_step_arg(arg) {
  match arg.value {
    IntVal(v) => v
    other => raise "expected IntVal, got \{other}"
  }
}

///|
impl FromStepArg for Double with from_step_arg(arg) {
  match arg.value {
    FloatVal(v) => v
    DoubleVal(v) => v
    other => raise "expected FloatVal or DoubleVal, got \{other}"
  }
}

///|
impl FromStepArg for Int64 with from_step_arg(arg) {
  match arg.value {
    LongVal(v) => v
    other => raise "expected LongVal, got \{other}"
  }
}

///|
impl FromStepArg for Byte with from_step_arg(arg) {
  match arg.value {
    ByteVal(v) => v
    other => raise "expected ByteVal, got \{other}"
  }
}

///|
impl FromStepArg for String with from_step_arg(arg) {
  match arg.value {
    StringVal(v) => v
    WordVal(v) => v
    AnonymousVal(v) => v
    other => raise "expected StringVal, WordVal, or AnonymousVal, got \{other}"
  }
}

///|
impl FromStepArg for BigInt with from_step_arg(arg) {
  match arg.value {
    BigIntegerVal(v) => v
    other => raise "expected BigIntegerVal, got \{other}"
  }
}

///|
impl FromStepArg for @decimal.Decimal with from_step_arg(arg) {
  match arg.value {
    BigDecimalVal(v) => v
    other => raise "expected BigDecimalVal, got \{other}"
  }
}

///|
impl FromStepArg for @any.Any with from_step_arg(arg) {
  match arg.value {
    CustomVal(v) => v
    other => raise "expected CustomVal, got \{other}"
  }
}

///|
impl FromStepArg for DataTable with from_step_arg(arg) {
  match arg.value {
    DataTableVal(v) => v
    other => raise "expected DataTableVal, got \{other}"
  }
}

///|
impl FromStepArg for DocString with from_step_arg(arg) {
  match arg.value {
    DocStringVal(v) => v
    other => raise "expected DocStringVal, got \{other}"
  }
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: All new tests PASS (plus all existing tests still pass)

**Step 5: Commit**

```bash
git add src/core/from_step_arg.mbt src/core/from_step_arg_wbtest.mbt
git commit -m "feat(core): add FromStepArg trait with implementations for all StepValue types"
```

---

### Task 2: Typed Setup Methods (given0–given5, given0_ctx–given5_ctx, all keywords)

**Files:**
- Create: `src/core/setup_typed.mbt`
- Test: `src/core/setup_typed_wbtest.mbt`

**Context:** Each typed method wraps the user's typed handler in a `(Ctx) -> Unit raise Error` closure that extracts `StepArg` values by index and calls `FromStepArg::from_step_arg()` on each one. The `_ctx` variants pass `Ctx` as the last argument to the handler. We implement for all 4 keywords (`given`, `when`, `then`, `step`) and arities 0–5 (both plain and `_ctx`). That's 4 × 6 × 2 = 48 methods.

**Step 1: Write the failing tests**

Create `src/core/setup_typed_wbtest.mbt`:

```moonbit
///|
test "Setup::given0 registers and runs zero-arg handler" {
  let setup = Setup::new()
  let called = [false]
  setup.given0("an empty cart", fn() { called[0] = true })
  let reg = setup.step_registry()
  assert_eq!(reg.len(), 1)
  // Verify handler runs via Ctx
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "an empty cart" },
  )
  let step_def = reg.step_defs()[0]
  (step_def.handler._).call(ctx)
  assert_true!(called[0])
}

///|
test "Setup::given1 extracts Int arg" {
  let setup = Setup::new()
  let captured : Array[Int] = []
  setup.given1("I have {int} items", fn(count : Int) { captured.push(count) })
  let reg = setup.step_registry()
  assert_eq!(reg.len(), 1)
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 5 items" },
  )
  let step_def = reg.step_defs()[0]
  (step_def.handler._).call(ctx)
  assert_eq!(captured[0], 5)
}

///|
test "Setup::given2 extracts String and Int args" {
  let setup = Setup::new()
  let names : Array[String] = []
  let prices : Array[Int] = []
  setup.given2("I add {string} at {int}", fn(name : String, price : Int) {
    names.push(name)
    prices.push(price)
  })
  let reg = setup.step_registry()
  let ctx = Ctx::new(
    [{ value: StringVal("apple"), raw: "apple" }, { value: IntVal(3), raw: "3" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I add apple at 3" },
  )
  (reg.step_defs()[0].handler._).call(ctx)
  assert_eq!(names[0], "apple")
  assert_eq!(prices[0], 3)
}

///|
test "Setup::given1_ctx passes Ctx as last arg" {
  let setup = Setup::new()
  let captured_feature : Array[String] = []
  setup.given1_ctx("I have {int} items", fn(count : Int, ctx : Ctx) {
    ignore(count)
    captured_feature.push(ctx.scenario().feature_name)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(5), raw: "5" }],
    { feature_name: "test_feature", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 5 items" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(captured_feature[0], "test_feature")
}

///|
test "Setup::given1 raises on arity mismatch" {
  let setup = Setup::new()
  setup.given1("I have {int} items", fn(_count : Int) { () })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have items" },
  )
  let result : Result[Unit, _] = try {
    Ok((setup.step_registry().step_defs()[0].handler._).call(ctx))
  } catch {
    e => Err(e)
  }
  assert_true!(result.is_err())
}

///|
test "Setup::when1 works for When keyword" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.when1("I search for {string}", fn(query : String) { captured.push(query) })
  let ctx = Ctx::new(
    [{ value: StringVal("moonbit"), raw: "moonbit" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "When ", text: "I search for moonbit" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(captured[0], "moonbit")
}

///|
test "Setup::then1 works for Then keyword" {
  let setup = Setup::new()
  let captured : Array[Int] = []
  setup.then1("I should see {int} results", fn(count : Int) { captured.push(count) })
  let ctx = Ctx::new(
    [{ value: IntVal(10), raw: "10" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Then ", text: "I should see 10 results" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(captured[0], 10)
}

///|
test "Setup::step0 works for Step keyword" {
  let setup = Setup::new()
  let called = [false]
  setup.step0("something happens", fn() { called[0] = true })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "* ", text: "something happens" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_true!(called[0])
}

///|
test "Setup::given0_ctx passes Ctx with zero args" {
  let setup = Setup::new()
  let captured : Array[String] = []
  setup.given0_ctx("an empty cart", fn(ctx : Ctx) {
    captured.push(ctx.scenario().scenario_name)
  })
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "my_scenario", tags: [] },
    { keyword: "Given ", text: "an empty cart" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(captured[0], "my_scenario")
}

///|
test "Setup::given3 extracts three args" {
  let setup = Setup::new()
  let result : Array[(String, Int, String)] = []
  setup.given3(
    "I add {string} qty {int} note {string}",
    fn(name : String, qty : Int, note : String) { result.push((name, qty, note)) },
  )
  let ctx = Ctx::new(
    [
      { value: StringVal("apple"), raw: "apple" },
      { value: IntVal(3), raw: "3" },
      { value: StringVal("fresh"), raw: "fresh" },
    ],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I add apple qty 3 note fresh" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(result[0], ("apple", 3, "fresh"))
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `given0`, `given1`, etc. not defined on `Setup`

**Step 3: Implement all typed Setup methods**

Create `src/core/setup_typed.mbt`. The file contains methods for all 4 keywords × arities 0–5 × plain and `_ctx` variants. Below is the complete implementation. Each keyword delegates to the existing `self.given/when/then/step` method by wrapping the typed handler in a `(Ctx) -> Unit raise Error` closure.

**Private helper** to extract and validate args:

```moonbit
///|
/// Validate that the context has exactly the expected number of step arguments.
fn validate_arity(ctx : Ctx, expected : Int) -> Unit raise Error {
  let actual = ctx.args().length()
  if actual != expected {
    raise "expected \{expected} step args, got \{actual}"
  }
}

// --- given ---

///|
pub fn Setup::given0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::given0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

///|
pub fn[A : FromStepArg] Setup::given1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::given1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::given2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::given2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::given3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::given3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::given4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::given4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::given5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::given5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// --- when ---
// Identical pattern to given, replacing self.given(...) with self.when(...)

///|
pub fn Setup::when0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::when0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

///|
pub fn[A : FromStepArg] Setup::when1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::when1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::when2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::when2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::when3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::when3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::when4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::when4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::when5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::when5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// --- then ---
// Identical pattern, replacing self.when(...) with self.then(...)

///|
pub fn Setup::then0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::then0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

///|
pub fn[A : FromStepArg] Setup::then1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::then1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::then2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::then2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::then3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::then3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::then4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::then4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::then5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::then5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// --- step ---
// Identical pattern, replacing self.then(...) with self.step(...)

///|
pub fn Setup::step0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::step0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

///|
pub fn[A : FromStepArg] Setup::step1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::step1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::step2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::step2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::step3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::step3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::step4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::step4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::step5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::step5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}
```

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add src/core/setup_typed.mbt src/core/setup_typed_wbtest.mbt
git commit -m "feat(core): add typed Setup methods given0-given5, when0-when5, then0-then5, step0-step5 with _ctx variants"
```

---

### Task 3: Typed StepDef Factory Methods (given0–given5, given0_ctx–given5_ctx, all keywords)

**Files:**
- Create: `src/core/step_def_typed.mbt`
- Test: `src/core/step_def_typed_wbtest.mbt`

**Context:** Same pattern as Setup but for `StepDef` factory constructors. Each method creates a `StepDef` struct wrapping the typed handler in a `StepHandler((Ctx) -> Unit raise Error)`. These are used in the `StepLibrary` pattern where users return `Array[StepDef]`.

**Step 1: Write the failing tests**

Create `src/core/step_def_typed_wbtest.mbt`:

```moonbit
///|
test "StepDef::given0 creates zero-arg step def" {
  let called = [false]
  let sd = StepDef::given0("an empty cart", fn() { called[0] = true })
  assert_eq!(sd.keyword, StepKeyword::Given)
  assert_eq!(sd.pattern, "an empty cart")
  let ctx = Ctx::new(
    [],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "an empty cart" },
  )
  (sd.handler._).call(ctx)
  assert_true!(called[0])
}

///|
test "StepDef::given1 creates one-arg step def" {
  let captured : Array[Int] = []
  let sd = StepDef::given1("I have {int} items", fn(count : Int) {
    captured.push(count)
  })
  assert_eq!(sd.keyword, StepKeyword::Given)
  let ctx = Ctx::new(
    [{ value: IntVal(7), raw: "7" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 7 items" },
  )
  (sd.handler._).call(ctx)
  assert_eq!(captured[0], 7)
}

///|
test "StepDef::given2 creates two-arg step def" {
  let captured : Array[(String, Int)] = []
  let sd = StepDef::given2("I add {string} at {int}", fn(
    name : String,
    price : Int
  ) { captured.push((name, price)) })
  let ctx = Ctx::new(
    [{ value: StringVal("apple"), raw: "apple" }, { value: IntVal(5), raw: "5" }],
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I add apple at 5" },
  )
  (sd.handler._).call(ctx)
  assert_eq!(captured[0], ("apple", 5))
}

///|
test "StepDef::when1 creates When step def" {
  let sd = StepDef::when1("I press {string}", fn(_s : String) { () })
  assert_eq!(sd.keyword, StepKeyword::When)
}

///|
test "StepDef::then1 creates Then step def" {
  let sd = StepDef::then1("I see {int}", fn(_n : Int) { () })
  assert_eq!(sd.keyword, StepKeyword::Then)
}

///|
test "StepDef::step1 creates Step step def" {
  let sd = StepDef::step1("there are {int}", fn(_n : Int) { () })
  assert_eq!(sd.keyword, StepKeyword::Step)
}

///|
test "StepDef::given1_ctx passes Ctx" {
  let captured : Array[String] = []
  let sd = StepDef::given1_ctx("I have {int}", fn(_n : Int, ctx : Ctx) {
    captured.push(ctx.scenario().feature_name)
  })
  let ctx = Ctx::new(
    [{ value: IntVal(1), raw: "1" }],
    { feature_name: "test_feat", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "I have 1" },
  )
  (sd.handler._).call(ctx)
  assert_eq!(captured[0], "test_feat")
}

///|
test "StepDef::given1 with source" {
  let sd = StepDef::given1(
    "I have {int}",
    fn(_n : Int) { () },
    source=StepSource::new(uri="test.mbt", line=42),
  )
  assert_true!(sd.source.is_empty().not())
}
```

**Step 2: Run tests to verify they fail**

Run: `mise run test:unit`
Expected: FAIL — `StepDef::given0`, etc. not defined

**Step 3: Implement typed StepDef factories**

Create `src/core/step_def_typed.mbt`. Same arity pattern as Setup methods, but returns `StepDef` structs. Each factory creates a `StepDef` with keyword, pattern, and a `StepHandler` wrapping the typed handler. All factories accept an optional `source? : StepSource` parameter.

```moonbit
// --- given ---

///|
pub fn StepDef::given0(
  pattern : String,
  handler : () -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler()
    }),
    source,
    id: None,
  }
}

///|
pub fn StepDef::given0_ctx(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler(ctx)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::given1(
  pattern : String,
  handler : (A) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::given1_ctx(
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a, ctx)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::given2(
  pattern : String,
  handler : (A, B) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::given2_ctx(
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b, ctx)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::given3(
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::given3_ctx(
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c, ctx)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::given4(
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::given4_ctx(
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d, ctx)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::given5(
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::given5_ctx(
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e, ctx)
    }),
    source,
    id: None,
  }
}

// --- when ---
// Same pattern as given, with keyword: When

// (Repeat all 12 methods with keyword: When, method names when0..when5, when0_ctx..when5_ctx)

// --- then ---
// Same pattern with keyword: Then

// (Repeat all 12 methods with keyword: Then, method names then0..then5, then0_ctx..then5_ctx)

// --- step ---
// Same pattern with keyword: Step

// (Repeat all 12 methods with keyword: Step, method names step0..step5, step0_ctx..step5_ctx)
```

**Important:** The full file must contain all 48 factory methods (4 keywords × 6 arities × 2 variants). The pattern is identical — only the keyword enum value and method name prefix change.

**Step 4: Run tests to verify they pass**

Run: `mise run test:unit`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add src/core/step_def_typed.mbt src/core/step_def_typed_wbtest.mbt
git commit -m "feat(core): add typed StepDef factories given0-given5, when0-when5, then0-then5, step0-step5 with _ctx variants"
```

---

### Task 4: Expand Arities from 5 to 9

**Files:**
- Modify: `src/core/setup_typed.mbt`
- Modify: `src/core/step_def_typed.mbt`
- Test: `src/core/setup_typed_wbtest.mbt` (add arity 9 test)
- Test: `src/core/step_def_typed_wbtest.mbt` (add arity 9 test)

**Context:** Extend both Setup and StepDef with arities 6–9. Same mechanical pattern. We cap at 9 initially — expanding to 22 is a future task using the exact same pattern. Steps beyond 5 args are rare in practice; 9 covers virtually all real-world cases.

**Step 1: Add a test for arity 9**

Append to `src/core/setup_typed_wbtest.mbt`:

```moonbit
///|
test "Setup::given9 extracts nine args" {
  let setup = Setup::new()
  let result : Array[Int] = []
  setup.given9(
    "{int} {int} {int} {int} {int} {int} {int} {int} {int}",
    fn(a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int, i : Int) {
      result.push(a + b + c + d + e + f + g + h + i)
    },
  )
  let args : Array[StepArg] = []
  for n = 1; n <= 9; n = n + 1 {
    args.push({ value: IntVal(n), raw: n.to_string() })
  }
  let ctx = Ctx::new(
    args,
    { feature_name: "f", scenario_name: "s", tags: [] },
    { keyword: "Given ", text: "1 2 3 4 5 6 7 8 9" },
  )
  (setup.step_registry().step_defs()[0].handler._).call(ctx)
  assert_eq!(result[0], 45) // 1+2+...+9 = 45
}
```

**Step 2: Run tests to verify the new test fails**

Run: `mise run test:unit`
Expected: FAIL — `given9` not defined

**Step 3: Add arities 6–9 to both files**

Follow the exact same pattern as arities 0–5, adding type parameters F, G, H, I. Add to both `setup_typed.mbt` and `step_def_typed.mbt`.

For arity N, the generic signature has N type parameters each constrained by `FromStepArg`. The body extracts N args by index and calls the handler.

**Step 4: Run tests**

Run: `mise run test:unit`
Expected: All tests PASS

**Step 5: Commit**

```bash
git add src/core/setup_typed.mbt src/core/step_def_typed.mbt src/core/setup_typed_wbtest.mbt src/core/step_def_typed_wbtest.mbt
git commit -m "feat(core): expand typed step methods to arity 9"
```

---

### Task 5: Update Ecommerce Example to Use Typed API

**Files:**
- Modify: `examples/ecommerce/src/cart_steps.mbt`
- Modify: `examples/ecommerce/src/inventory_steps.mbt`

**Context:** Convert the ecommerce example from manual pattern matching to the typed API to validate the ergonomics and serve as documentation. The existing tests in the example project should still pass.

**Step 1: Read the current example files**

Read `examples/ecommerce/src/cart_steps.mbt` and `examples/ecommerce/src/inventory_steps.mbt` to understand the current step definitions.

**Step 2: Convert step definitions to typed API**

Replace patterns like:
```moonbit
@moonspec.StepDef::given("I add {string} with quantity {int} at price {int}", fn(args) {
  match (args[0], args[1], args[2]) {
    ({ value: StringVal(name), .. }, { value: IntVal(qty), .. }, { value: IntVal(price), .. }) => { ... }
    _ => ()
  }
})
```

With:
```moonbit
@moonspec.StepDef::given3("I add {string} with quantity {int} at price {int}", fn(
  name : String,
  qty : Int,
  price : Int
) { ... })
```

**Step 3: Run the example tests**

Run: `mise run test:unit`
Expected: All tests PASS (including ecommerce example tests)

**Step 4: Commit**

```bash
git add examples/ecommerce/src/cart_steps.mbt examples/ecommerce/src/inventory_steps.mbt
git commit -m "refactor(examples): convert ecommerce steps to typed API"
```

---

### Task 6: Expand Arities from 9 to 22

**Files:**
- Modify: `src/core/setup_typed.mbt`
- Modify: `src/core/step_def_typed.mbt`

**Context:** Mechanical expansion from arity 10–22. Same pattern. Type parameter names: A–V (22 letters). No new tests needed beyond a spot-check — the pattern is proven by arities 0–9.

**Step 1: Add arities 10–22**

Follow the exact same pattern. Type parameters: A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V.

**Step 2: Run tests**

Run: `mise run test:unit`
Expected: All tests PASS

**Step 3: Commit**

```bash
git add src/core/setup_typed.mbt src/core/step_def_typed.mbt
git commit -m "feat(core): expand typed step methods to arity 22"
```

---

## Summary

| Task | What | New Files | Methods |
|------|------|-----------|---------|
| 1 | FromStepArg trait + 10 impls | `from_step_arg.mbt`, `from_step_arg_wbtest.mbt` | 10 impls |
| 2 | Typed Setup methods (0–5) | `setup_typed.mbt`, `setup_typed_wbtest.mbt` | 48 methods |
| 3 | Typed StepDef factories (0–5) | `step_def_typed.mbt`, `step_def_typed_wbtest.mbt` | 48 methods |
| 4 | Expand to arity 9 | modify existing | +32 methods each |
| 5 | Update ecommerce example | modify existing | 0 new |
| 6 | Expand to arity 22 | modify existing | +104 methods each |

**Total new public API surface:** ~368 methods (4 keywords × 23 arities × 2 variants × 2 surfaces)
