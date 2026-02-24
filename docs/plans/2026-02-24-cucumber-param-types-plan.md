# Full Cucumber Expression Parameter Types — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add the 6 missing built-in cucumber expression parameter types ({double}, {long}, {byte}, {short}, {bigdecimal}, {biginteger}) to the cucumber-expressions library and moonspec core.

**Architecture:** Two separate repos need changes. First, extend `ParamType` enum and `ParamTypeRegistry::default()` in `cucumber-expressions` (at `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`), publish a new version. Then update moonspec's `StepArg` enum and `from_param` to handle the new types, and bump the dependency.

**Tech Stack:** MoonBit, moonbitlang/core/bigint (BigInt), moonbitlang/x/decimal (Decimal)

---

### Task 1: Add ParamType variants to cucumber-expressions

**Repo:** `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`

**Files:**
- Modify: `src/param_type.mbt:21-28`
- Modify: `src/param_type_wbtest.mbt`

**Step 1: Write failing tests for new ParamType variants**

Add to `src/param_type_wbtest.mbt`:

```moonbit
///|
test "ParamType::Double_ Show" {
  inspect(ParamType::Double_, content="Double_")
}

///|
test "ParamType::Long Show" {
  inspect(ParamType::Long, content="Long")
}

///|
test "ParamType::Byte Show" {
  inspect(ParamType::Byte, content="Byte")
}

///|
test "ParamType::Short Show" {
  inspect(ParamType::Short, content="Short")
}

///|
test "ParamType::BigDecimal Show" {
  inspect(ParamType::BigDecimal, content="BigDecimal")
}

///|
test "ParamType::BigInteger Show" {
  inspect(ParamType::BigInteger, content="BigInteger")
}
```

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: FAIL — `Double_`, `Long`, `Byte`, `Short`, `BigDecimal`, `BigInteger` are not members of `ParamType`

**Step 3: Add the 6 new variants to ParamType enum**

In `src/param_type.mbt`, change the enum (lines 21-28) to:

```moonbit
///|
/// Parameter types supported by cucumber expressions.
pub(all) enum ParamType {
  Int
  Float
  String_
  Word
  Anonymous
  Double_
  Long
  Byte
  Short
  BigDecimal
  BigInteger
  Custom(String)
} derive(Show, Eq, ToJson, FromJson)
```

**Step 4: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 5: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/param_type.mbt src/param_type_wbtest.mbt
git commit -m "feat: add 6 new ParamType variants for full spec compliance"
```

---

### Task 2: Register new types in ParamTypeRegistry::default()

**Repo:** `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`

**Files:**
- Modify: `src/param_type.mbt:50-67`
- Modify: `src/param_type_wbtest.mbt`

**Step 1: Write failing tests for new registry entries**

Add to `src/param_type_wbtest.mbt`:

```moonbit
///|
test "ParamTypeRegistry::default has 11 built-in types" {
  let reg = ParamTypeRegistry::default()
  inspect(reg.entries_view().length(), content="11")
}

///|
test "Registry get double returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("double") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::Double_)
      inspect(entry.patterns.length(), content="1")
    }
    None => abort("expected double to be registered")
  }
}

///|
test "Registry get long returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("long") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::Long)
      inspect(entry.patterns.length(), content="2")
    }
    None => abort("expected long to be registered")
  }
}

///|
test "Registry get byte returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("byte") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::Byte)
      inspect(entry.patterns.length(), content="2")
    }
    None => abort("expected byte to be registered")
  }
}

///|
test "Registry get short returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("short") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::Short)
      inspect(entry.patterns.length(), content="2")
    }
    None => abort("expected short to be registered")
  }
}

///|
test "Registry get bigdecimal returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("bigdecimal") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::BigDecimal)
      inspect(entry.patterns.length(), content="1")
    }
    None => abort("expected bigdecimal to be registered")
  }
}

///|
test "Registry get biginteger returns correct type and patterns" {
  let reg = ParamTypeRegistry::default()
  match reg.get("biginteger") {
    Some(entry) => {
      assert_true(entry.type_ == ParamType::BigInteger)
      inspect(entry.patterns.length(), content="2")
    }
    None => abort("expected biginteger to be registered")
  }
}
```

Also **update** the existing test `"ParamTypeRegistry::default has 5 built-in types"` — either delete it (since the new `"has 11"` test supersedes it) or update the count. Delete it.

And update `"ParamType equality"` test to include new variants:

```moonbit
///|
test "ParamType equality" {
  assert_true(ParamType::Int == ParamType::Int)
  assert_true(ParamType::Float == ParamType::Float)
  assert_true(ParamType::String_ == ParamType::String_)
  assert_true(ParamType::Word == ParamType::Word)
  assert_true(ParamType::Anonymous == ParamType::Anonymous)
  assert_true(ParamType::Double_ == ParamType::Double_)
  assert_true(ParamType::Long == ParamType::Long)
  assert_true(ParamType::Byte == ParamType::Byte)
  assert_true(ParamType::Short == ParamType::Short)
  assert_true(ParamType::BigDecimal == ParamType::BigDecimal)
  assert_true(ParamType::BigInteger == ParamType::BigInteger)
  assert_true(ParamType::Custom("x") == ParamType::Custom("x"))
  assert_true(ParamType::Int != ParamType::Float)
  assert_true(ParamType::Double_ != ParamType::Float)
  assert_true(ParamType::Long != ParamType::Int)
  assert_true(ParamType::Custom("a") != ParamType::Custom("b"))
}
```

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: FAIL — `reg.get("double")` returns `None`, count is 5 not 11

**Step 3: Register 6 new types in ParamTypeRegistry::default()**

In `src/param_type.mbt`, update `ParamTypeRegistry::default()` (lines 50-67):

```moonbit
///|
/// Create a registry with the 11 built-in parameter types pre-registered.
pub fn ParamTypeRegistry::default() -> ParamTypeRegistry {
  let reg = ParamTypeRegistry::new()
  // Integer types (all share the same regex patterns)
  let int_patterns = [
    RegexPattern("(?:-?\\d+)"),
    RegexPattern("(?:\\d+)"),
  ]
  reg.register("int", ParamType::Int, int_patterns)
  reg.register("long", ParamType::Long, int_patterns)
  reg.register("byte", ParamType::Byte, int_patterns)
  reg.register("short", ParamType::Short, int_patterns)
  reg.register("biginteger", ParamType::BigInteger, int_patterns)
  // Float types (all share the same regex pattern)
  let float_patterns = [
    RegexPattern("(?:[+-]?(?:\\d+|\\d+\\.\\d*|\\d*\\.\\d+)(?:[eE][+-]?\\d+)?)"),
  ]
  reg.register("float", ParamType::Float, float_patterns)
  reg.register("double", ParamType::Double_, float_patterns)
  reg.register("bigdecimal", ParamType::BigDecimal, float_patterns)
  // String and word
  reg.register("string", ParamType::String_, [
    RegexPattern("\"([^\"\\\\]*(\\\\.[^\"\\\\]*)*)\""),
    RegexPattern("'([^'\\\\]*(\\\\.[^'\\\\]*)*)'"),
  ])
  reg.register("word", ParamType::Word, [RegexPattern("[^\\s]+")])
  reg.register("", ParamType::Anonymous, [RegexPattern(".*")])
  reg
}
```

**Step 4: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 5: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/param_type.mbt src/param_type_wbtest.mbt
git commit -m "feat: register 6 new built-in parameter types in default registry"
```

---

### Task 3: Add expression matching tests for new types

**Repo:** `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`

**Files:**
- Modify: `src/spec_wbtest.mbt`

**Step 1: Write expression matching tests**

Add to `src/spec_wbtest.mbt`:

```moonbit
///|
test "spec/match: double" {
  let expr = Expression::parse("the value is {double}")
  let result = expr.match_("the value is 3.14")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="3.14")
  inspect(m.params[0].type_, content="Double_")
}

///|
test "spec/match: double scientific notation" {
  let expr = Expression::parse("the value is {double}")
  let result = expr.match_("the value is 1.5e10")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="1.5e10")
  inspect(m.params[0].type_, content="Double_")
}

///|
test "spec/match: long" {
  let expr = Expression::parse("I have {long} items")
  let result = expr.match_("I have 9223372036854775807 items")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="9223372036854775807")
  inspect(m.params[0].type_, content="Long")
}

///|
test "spec/match: byte" {
  let expr = Expression::parse("value is {byte}")
  let result = expr.match_("value is 127")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="127")
  inspect(m.params[0].type_, content="Byte")
}

///|
test "spec/match: short" {
  let expr = Expression::parse("port is {short}")
  let result = expr.match_("port is 8080")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="8080")
  inspect(m.params[0].type_, content="Short")
}

///|
test "spec/match: bigdecimal" {
  let expr = Expression::parse("price is {bigdecimal}")
  let result = expr.match_("price is 99.99")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="99.99")
  inspect(m.params[0].type_, content="BigDecimal")
}

///|
test "spec/match: biginteger" {
  let expr = Expression::parse("count is {biginteger}")
  let result = expr.match_("count is 123456789012345678901234567890")
  guard result is Some(m) else { fail("expected match") }
  inspect(m.params[0].value, content="123456789012345678901234567890")
  inspect(m.params[0].type_, content="BigInteger")
}
```

**Step 2: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS (types are already registered from Task 2)

**Step 3: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/spec_wbtest.mbt
git commit -m "test: add expression matching tests for new parameter types"
```

---

### Task 4: Publish cucumber-expressions 0.3.0

**Repo:** `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`

**Files:**
- Modify: `moon.mod.json` (version bump)

**Step 1: Run full test suite**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 2: Run `moon info` to regenerate .mbti files**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && moon info`

**Step 3: Bump version in moon.mod.json to 0.3.0**

Change `"version": "0.2.0"` to `"version": "0.3.0"`.

**Step 4: Commit and push**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add moon.mod.json src/pkg.generated.mbti
git commit -m "chore: bump version to 0.3.0"
git push
```

**Step 5: Publish**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && moon publish`

---

### Task 5: Add StepArg variants to moonspec

**Repo:** `/home/damian/code/repos/github/moonrockz/moonspec/`

**Files:**
- Modify: `src/core/types.mbt:1-28`
- Modify: `src/core/types_wbtest.mbt`
- Modify: `src/core/moon.pkg` (add `moonbitlang/x/decimal` import)

**Pre-req:** Run `moon update` in moonspec to pull cucumber-expressions 0.3.0, then `moon install`.

**Step 1: Update moon.pkg to add decimal import**

In `src/core/moon.pkg`, add the `moonbitlang/x/decimal` import:

```
import {
  "moonrockz/cucumber-expressions" as @cucumber_expressions,
  "moonrockz/cucumber-messages" as @cucumber_messages,
  "moonbitlang/core/strconv",
  "moonbitlang/x/decimal" as @decimal,
}
```

**Step 2: Write failing tests for new StepArg variants**

Add to `src/core/types_wbtest.mbt`:

```moonbit
///|
test "StepArg from_param converts Double_ param" {
  let param = @cucumber_expressions.Param::{
    value: "3.14",
    type_: @cucumber_expressions.ParamType::Double_,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::DoubleArg(3.14))
}

///|
test "StepArg from_param converts Long param" {
  let param = @cucumber_expressions.Param::{
    value: "9223372036854775807",
    type_: @cucumber_expressions.ParamType::Long,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::LongArg(9223372036854775807L))
}

///|
test "StepArg from_param converts Byte param" {
  let param = @cucumber_expressions.Param::{
    value: "255",
    type_: @cucumber_expressions.ParamType::Byte,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::ByteArg(b'\xFF'))
}

///|
test "StepArg from_param converts Short param" {
  let param = @cucumber_expressions.Param::{
    value: "8080",
    type_: @cucumber_expressions.ParamType::Short,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::ShortArg(8080))
}

///|
test "StepArg from_param converts BigDecimal param" {
  let param = @cucumber_expressions.Param::{
    value: "99.99",
    type_: @cucumber_expressions.ParamType::BigDecimal,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::BigDecimalArg(@decimal.Decimal::from_string("99.99").unwrap()))
}

///|
test "StepArg from_param converts BigInteger param" {
  let param = @cucumber_expressions.Param::{
    value: "123456789012345678901234567890",
    type_: @cucumber_expressions.ParamType::BigInteger,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::BigIntegerArg(BigInt::from_string("123456789012345678901234567890")))
}
```

**Step 3: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: FAIL — `DoubleArg`, `LongArg`, etc. are not members of `StepArg`

**Step 4: Add new StepArg variants and from_param branches**

In `src/core/types.mbt`, update the StepArg enum and from_param:

```moonbit
///|
/// A typed step argument extracted from step text via Cucumber Expressions.
pub(all) enum StepArg {
  IntArg(Int)
  FloatArg(Double)
  StringArg(String)
  WordArg(String)
  CustomArg(String)
  DoubleArg(Double)
  LongArg(Int64)
  ByteArg(Byte)
  ShortArg(Int)
  BigDecimalArg(@decimal.Decimal)
  BigIntegerArg(BigInt)
} derive(Show, Eq)

///|
/// Convert a cucumber-expressions Param to a typed StepArg.
pub fn StepArg::from_param(param : @cucumber_expressions.Param) -> StepArg {
  match param.type_ {
    @cucumber_expressions.ParamType::Int => {
      let n = @strconv.parse_int(param.value) catch { _ => 0 }
      IntArg(n)
    }
    @cucumber_expressions.ParamType::Float => {
      let f = @strconv.parse_double(param.value) catch { _ => 0.0 }
      FloatArg(f)
    }
    @cucumber_expressions.ParamType::Double_ => {
      let f = @strconv.parse_double(param.value) catch { _ => 0.0 }
      DoubleArg(f)
    }
    @cucumber_expressions.ParamType::Long => {
      let n = Int64::from_string(param.value) catch { _ => 0L }
      LongArg(n)
    }
    @cucumber_expressions.ParamType::Byte => {
      let n = @strconv.parse_int(param.value) catch { _ => 0 }
      ByteArg(n.to_byte())
    }
    @cucumber_expressions.ParamType::Short => {
      let n = @strconv.parse_int(param.value) catch { _ => 0 }
      ShortArg(n)
    }
    @cucumber_expressions.ParamType::BigDecimal => {
      let d = @decimal.Decimal::from_string(param.value)
      match d {
        Some(dec) => BigDecimalArg(dec)
        None => BigDecimalArg(@decimal.Decimal::from_string("0").unwrap())
      }
    }
    @cucumber_expressions.ParamType::BigInteger => {
      let bi = BigInt::from_string(param.value)
      BigIntegerArg(bi)
    }
    @cucumber_expressions.ParamType::String_ => StringArg(param.value)
    @cucumber_expressions.ParamType::Word => WordArg(param.value)
    @cucumber_expressions.ParamType::Anonymous => StringArg(param.value)
    @cucumber_expressions.ParamType::Custom(_) => CustomArg(param.value)
  }
}
```

**Note:** `BigInt::from_string` may raise — check if it returns `BigInt` or `BigInt?`. Adjust accordingly. `Decimal::from_string` returns `Decimal?`.

**Step 5: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS

**Step 6: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add src/core/moon.pkg src/core/types.mbt src/core/types_wbtest.mbt
git commit -m "feat: add 6 new StepArg variants for full parameter type support"
```

---

### Task 6: Update lib.mbt re-exports and run moon info

**Repo:** `/home/damian/code/repos/github/moonrockz/moonspec/`

**Files:**
- Modify: `src/lib.mbt` (if StepArg re-exports need updating)
- Regenerate: `src/core/pkg.generated.mbti`

**Step 1: Check if lib.mbt re-exports StepArg**

Read `src/lib.mbt` and check if `StepArg` or individual variants are re-exported. If the enum is re-exported, the new variants come along automatically.

**Step 2: Run `moon info` to regenerate .mbti files**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && moon info`

**Step 3: Run full test suite**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS (same count or more than before)

**Step 4: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add src/core/pkg.generated.mbti src/lib.mbt
git commit -m "chore: regenerate mbti after new StepArg variants"
```

---

### Task 7: Final cleanup

**Repo:** `/home/damian/code/repos/github/moonrockz/moonspec/`

**Step 1: Run `moon fmt`**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && moon fmt`

**IMPORTANT:** `moon fmt` rewrites `.pkg` files with new syntax that breaks builds. After running, revert any `.pkg` changes:

```bash
git checkout -- src/*/moon.pkg src/*/*/moon.pkg
```

**Step 2: Run full test suite one final time**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS

**Step 3: Commit formatting changes (if any)**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add -u
git commit -m "style: format after parameter type additions"
```
