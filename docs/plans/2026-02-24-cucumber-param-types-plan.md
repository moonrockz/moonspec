# Full Cucumber Expression Parameter Types — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 6 missing built-in parameter types and transformer functions to the cucumber-expressions library, then update moonspec with `StepArg` struct (typed value + raw text), `StepValue` hybrid enum, and custom type transformer support.

**Architecture:** Two repos. First, extend cucumber-expressions with `ParamType` variants, `Transformer` type using `tonyfettes/any`, built-in transformers, and updated `Param` struct. Then update moonspec's `StepArg`/`StepValue` types, simplify `from_param`, and wire transformer callbacks through `Setup`.

**Tech Stack:** MoonBit, tonyfettes/any, moonbitlang/core/bigint, moonbitlang/x/decimal, moonbitlang/core/strconv

---

## Phase 1: cucumber-expressions library

**Repo:** `/home/damian/code/repos/github/moonrockz/cucumber-expressions/`

### Task 1: Add ParamType variants

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

Update the existing `"ParamType equality"` test to include new variants:

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
Expected: FAIL — `Double_`, `Long`, `Byte`, `Short`, `BigDecimal`, `BigInteger` not members of `ParamType`

**Step 3: Add 6 new variants to ParamType enum**

In `src/param_type.mbt`, change lines 21-28:

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

### Task 2: Add Transformer type and tonyfettes/any dependency

**Files:**
- Modify: `moon.mod.json` (add `tonyfettes/any` dependency)
- Modify: `src/moon.pkg` (add imports)
- Modify: `src/param_type.mbt` (add Transformer type, update ParamTypeEntry, update register)
- Modify: `src/param_type_wbtest.mbt`

**Step 1: Add tonyfettes/any dependency**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && moon add tonyfettes/any`

Add imports to `src/moon.pkg`:

```
import {
  "moonbitlang/core/json",
  "moonbitlang/regexp",
  "moonbitlang/core/strconv",
  "moonbitlang/x/decimal" as @decimal,
  "tonyfettes/any" as @any,
}
```

**Step 2: Write failing test for Transformer on ParamTypeEntry**

Add to `src/param_type_wbtest.mbt`:

```moonbit
///|
test "ParamTypeEntry with transformer" {
  let transformer : Transformer = fn(groups) { @any.of(@strconv.parse_int(groups[0])) }
  let entry : ParamTypeEntry = {
    name: "test",
    type_: ParamType::Int,
    patterns: [RegexPattern("\\d+")],
    transformer,
  }
  assert_eq(entry.name, "test")
  let result = (entry.transformer._)(["42"])
  let value : Int = result.to()
  assert_eq(value, 42)
}
```

**Step 3: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: FAIL — `Transformer` type not defined, `transformer` field not on `ParamTypeEntry`

**Step 4: Add Transformer type and update ParamTypeEntry**

In `src/param_type.mbt`, add the Transformer type and update ParamTypeEntry:

```moonbit
///|
/// A transformer function that converts captured regex group strings into a typed value.
/// Receives an array of captured group strings (arity matches capture groups in the regex).
pub(all) type Transformer (Array[String]) -> @any.Any raise Error

///|
/// A registered parameter type entry with name, type, regex patterns, and transformer.
pub(all) struct ParamTypeEntry {
  name : String
  type_ : ParamType
  patterns : Array[RegexPattern]
  transformer : Transformer
} derive(Show, Eq)
```

Update `ParamTypeRegistry::register` to accept a transformer:

```moonbit
///|
pub fn ParamTypeRegistry::register(
  self : ParamTypeRegistry,
  name : String,
  type_ : ParamType,
  patterns : Array[RegexPattern],
  transformer~ : Transformer = fn(groups) { @any.of(groups[0]) },
) -> Unit {
  self.entries.push({ name, type_, patterns, transformer })
}
```

The default transformer boxes the first captured group string.

**Step 5: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS (existing tests keep working because `transformer~` has a default)

**Step 6: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add moon.mod.json src/moon.pkg src/param_type.mbt src/param_type_wbtest.mbt
git commit -m "feat: add Transformer type with tonyfettes/any for type-erased values"
```

---

### Task 3: Add built-in transformers and register all 11 types

**Files:**
- Modify: `src/param_type.mbt:50-67` (ParamTypeRegistry::default)
- Modify: `src/param_type_wbtest.mbt`

**Step 1: Write failing tests for new registry entries and transformers**

Replace the existing `"ParamTypeRegistry::default has 5 built-in types"` test and add new tests in `src/param_type_wbtest.mbt`:

```moonbit
///|
test "ParamTypeRegistry::default has 11 built-in types" {
  let reg = ParamTypeRegistry::default()
  inspect(reg.entries_view().length(), content="11")
}

///|
test "Registry int transformer converts string to Int" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("int").unwrap()
  let result = (entry.transformer._)(["42"])
  let value : Int = result.to()
  assert_eq(value, 42)
}

///|
test "Registry float transformer converts string to Double" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("float").unwrap()
  let result = (entry.transformer._)(["3.14"])
  let value : Double = result.to()
  assert_eq(value, 3.14)
}

///|
test "Registry double transformer converts string to Double" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("double").unwrap()
  let result = (entry.transformer._)(["3.14"])
  let value : Double = result.to()
  assert_eq(value, 3.14)
}

///|
test "Registry long transformer converts string to Int64" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("long").unwrap()
  let result = (entry.transformer._)(["9223372036854775807"])
  let value : Int64 = result.to()
  assert_eq(value, 9223372036854775807L)
}

///|
test "Registry byte transformer converts string to Byte" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("byte").unwrap()
  let result = (entry.transformer._)(["255"])
  let value : Byte = result.to()
  assert_eq(value, b'\xFF')
}

///|
test "Registry short transformer converts string to Int" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("short").unwrap()
  let result = (entry.transformer._)(["8080"])
  let value : Int = result.to()
  assert_eq(value, 8080)
}

///|
test "Registry string transformer returns String" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("string").unwrap()
  let result = (entry.transformer._)(["hello"])
  let value : String = result.to()
  assert_eq(value, "hello")
}

///|
test "Registry word transformer returns String" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("word").unwrap()
  let result = (entry.transformer._)(["banana"])
  let value : String = result.to()
  assert_eq(value, "banana")
}

///|
test "Registry bigdecimal transformer converts string to Decimal" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("bigdecimal").unwrap()
  let result = (entry.transformer._)(["99.99"])
  let value : @decimal.Decimal = result.to()
  assert_eq(value, @decimal.Decimal::from_string("99.99").unwrap())
}

///|
test "Registry biginteger transformer converts string to BigInt" {
  let reg = ParamTypeRegistry::default()
  let entry = reg.get("biginteger").unwrap()
  let result = (entry.transformer._)(["123456789012345678901234567890"])
  let value : BigInt = result.to()
  assert_eq(value, BigInt::from_string("123456789012345678901234567890"))
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

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: FAIL — registry has 5 types not 11, `get("double")` returns None, etc.

**Step 3: Implement built-in transformers and register all 11 types**

In `src/param_type.mbt`, replace `ParamTypeRegistry::default()`:

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
  reg.register("int", ParamType::Int, int_patterns,
    transformer=fn(groups) { @any.of(@strconv.parse_int(groups[0])) },
  )
  reg.register("long", ParamType::Long, int_patterns,
    transformer=fn(groups) { @any.of(Int64::from_string(groups[0])) },
  )
  reg.register("byte", ParamType::Byte, int_patterns,
    transformer=fn(groups) { @any.of(@strconv.parse_int(groups[0]).to_byte()) },
  )
  reg.register("short", ParamType::Short, int_patterns,
    transformer=fn(groups) { @any.of(@strconv.parse_int(groups[0])) },
  )
  reg.register("biginteger", ParamType::BigInteger, int_patterns,
    transformer=fn(groups) { @any.of(BigInt::from_string(groups[0])) },
  )
  // Float types (all share the same regex pattern)
  let float_patterns = [
    RegexPattern("(?:[+-]?(?:\\d+|\\d+\\.\\d*|\\d*\\.\\d+)(?:[eE][+-]?\\d+)?)"),
  ]
  reg.register("float", ParamType::Float, float_patterns,
    transformer=fn(groups) { @any.of(@strconv.parse_double(groups[0])) },
  )
  reg.register("double", ParamType::Double_, float_patterns,
    transformer=fn(groups) { @any.of(@strconv.parse_double(groups[0])) },
  )
  reg.register("bigdecimal", ParamType::BigDecimal, float_patterns,
    transformer=fn(groups) {
      match @decimal.Decimal::from_string(groups[0]) {
        Some(d) => @any.of(d)
        None => raise Error("Invalid bigdecimal: " + groups[0])
      }
    },
  )
  // String and word (identity transformers)
  reg.register("string", ParamType::String_, [
    RegexPattern("\"([^\"\\\\]*(\\\\.[^\"\\\\]*)*)\""),
    RegexPattern("'([^'\\\\]*(\\\\.[^'\\\\]*)*)'"),
  ],
    transformer=fn(groups) { @any.of(groups[0]) },
  )
  reg.register("word", ParamType::Word, [RegexPattern("[^\\s]+")],
    transformer=fn(groups) { @any.of(groups[0]) },
  )
  reg.register("", ParamType::Anonymous, [RegexPattern(".*")],
    transformer=fn(groups) { @any.of(groups[0]) },
  )
  reg
}
```

**Note:** Check that `Int64::from_string` and `BigInt::from_string` have the right signatures (may raise or return Option). Adjust error handling as needed.

**Step 4: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 5: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/param_type.mbt src/param_type_wbtest.mbt
git commit -m "feat: register 11 built-in types with transformers in default registry"
```

---

### Task 4: Update Param struct and Expression.match_ to use transformers

**Files:**
- Modify: `src/expression.mbt:13-23` (Param struct)
- Modify: `src/expression.mbt:62-98` (Expression::match_)
- Modify: `src/expression_wbtest.mbt`
- Modify: `src/spec_wbtest.mbt`

**Step 1: Write failing tests for transformed Param values**

Add to `src/expression_wbtest.mbt`:

```moonbit
///|
test "match returns transformed Int value" {
  let expr = Expression::parse("I have {int} cucumbers")
  let result = expr.match_("I have 42 cucumbers")
  guard result is Some(m) else { fail("expected match") }
  let value : Int = m.params[0].value.to()
  assert_eq(value, 42)
  assert_eq(m.params[0].raw, "42")
  assert_eq(m.params[0].type_, ParamType::Int)
}

///|
test "match returns transformed Double value for float" {
  let expr = Expression::parse("price is {float}")
  let result = expr.match_("price is 3.14")
  guard result is Some(m) else { fail("expected match") }
  let value : Double = m.params[0].value.to()
  assert_eq(value, 3.14)
  assert_eq(m.params[0].raw, "3.14")
}

///|
test "match returns transformed String for string" {
  let expr = Expression::parse("I select {string}")
  let result = expr.match_("I select \"hello\"")
  guard result is Some(m) else { fail("expected match") }
  let value : String = m.params[0].value.to()
  assert_eq(value, "hello")
  assert_eq(m.params[0].raw, "hello")
}

///|
test "match preserves raw text" {
  let expr = Expression::parse("{int} + {int}")
  let result = expr.match_("10 + 20")
  guard result is Some(m) else { fail("expected match") }
  assert_eq(m.params[0].raw, "10")
  assert_eq(m.params[1].raw, "20")
}
```

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: FAIL — `Param` doesn't have `value` as `Any` or `raw` field

**Step 3: Update Param struct and Expression.match_**

In `src/expression.mbt`, update the Param struct:

```moonbit
///|
/// An extracted parameter value with type-erased transformed value and raw text.
pub(all) struct Param {
  value : @any.Any    // type-erased transformed value
  type_ : ParamType   // which parameter type matched
  raw : String        // original matched text
} derive(Show, Eq)
```

Update `Expression` struct to store transformers alongside param_types:

```moonbit
pub(all) struct Expression {
  priv source : String
  priv regex : @regexp.Regexp
  priv param_types : Array[ParamType]
  priv transformers : Array[Transformer]
  priv group_counts : Array[Int]
}
```

Update `Expression::parse_with_registry` to collect transformers:

```moonbit
pub fn Expression::parse_with_registry(
  expression : String,
  registry : ParamTypeRegistry,
) -> Expression raise ExpressionError {
  let ast = parse_expression(expression)
  let param_types = collect_param_types(ast, registry)
  let transformers = collect_transformers(ast, registry)
  let group_counts = collect_group_counts(ast, registry)
  let regex_str = compile(ast, registry)
  let regex = @regexp.compile(regex_str.view()) catch {
    _ =>
      raise ExpressionError::ValidationError(
        position=0,
        message="Failed to compile regex: " + regex_str,
      )
  }
  { source: expression, regex, param_types, transformers, group_counts }
}
```

Add `collect_transformers` function (follows same pattern as `collect_param_types`):

```moonbit
fn collect_transformers(
  node : Node,
  registry : ParamTypeRegistry,
) -> Array[Transformer] {
  let transformers : Array[Transformer] = []
  fn walk(n : Node) {
    match n {
      ParameterNode(name) =>
        match registry.get(name) {
          Some(entry) => transformers.push(entry.transformer)
          None => ()
        }
      ExpressionNode(children) | OptionalNode(children) =>
        for child in children {
          walk(child)
        }
      AlternationNode(arms) =>
        for arm in arms {
          for node in arm {
            walk(node)
          }
        }
      TextNode(_) => ()
    }
  }
  walk(node)
  transformers
}
```

Update `Expression::match_` to apply transformers and populate `raw`:

```moonbit
pub fn Expression::match_(self : Expression, text : String) -> Match? {
  let result = self.regex.match_(text.view())
  guard result is Some(mr) else { return None }
  let params : Array[Param] = []
  let mut group_idx = 1
  for i, type_ in self.param_types {
    let num_groups = self.group_counts[i]
    let raw_value = match type_ {
      ParamType::String_ => {
        let outer = mr.get(group_idx)
        match outer {
          Some(sv) => {
            let s = sv.to_string()
            if (s.has_prefix("\"") && s.has_suffix("\"")) ||
              (s.has_prefix("'") && s.has_suffix("'")) {
              s.view(start_offset=1, end_offset=s.length() - 1).to_string()
            } else {
              s
            }
          }
          None => ""
        }
      }
      _ =>
        match mr.get(group_idx) {
          Some(sv) => sv.to_string()
          None => ""
        }
    }
    // Apply transformer
    let transformed = try {
      (self.transformers[i]._)([raw_value])
    } catch {
      _ => @any.of(raw_value)  // fallback to raw string on transform error
    }
    params.push({ value: transformed, type_, raw: raw_value })
    group_idx = group_idx + num_groups
  }
  Some({ params, })
}
```

**Step 4: Fix existing tests**

Existing tests in `src/expression_wbtest.mbt` and `src/spec_wbtest.mbt` reference `m.params[0].value` as a `String`. These need updating to use `m.params[0].raw` for string comparisons, or extract via `.value.to()`.

Update all existing `spec_wbtest.mbt` tests that check `m.params[0].value` to use `m.params[0].raw`:

```moonbit
// Before:
inspect(m.params[0].value, content="42")

// After:
inspect(m.params[0].raw, content="42")
```

Also update `inspect(m.params[0].type_, content="Int")` — these should still work since `type_` hasn't changed.

**Step 5: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 6: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/expression.mbt src/expression_wbtest.mbt src/spec_wbtest.mbt
git commit -m "feat: Expression.match_ applies transformers, Param carries Any + raw"
```

---

### Task 5: Add expression matching tests for new types

**Files:**
- Modify: `src/spec_wbtest.mbt`

**Step 1: Write expression matching tests for all 6 new types**

Add to `src/spec_wbtest.mbt`:

```moonbit
///|
test "spec/match: double" {
  let expr = Expression::parse("the value is {double}")
  let result = expr.match_("the value is 3.14")
  guard result is Some(m) else { fail("expected match") }
  let value : Double = m.params[0].value.to()
  assert_eq(value, 3.14)
  assert_eq(m.params[0].raw, "3.14")
  assert_eq(m.params[0].type_, ParamType::Double_)
}

///|
test "spec/match: double scientific notation" {
  let expr = Expression::parse("the value is {double}")
  let result = expr.match_("the value is 1.5e10")
  guard result is Some(m) else { fail("expected match") }
  let value : Double = m.params[0].value.to()
  assert_eq(m.params[0].raw, "1.5e10")
}

///|
test "spec/match: long" {
  let expr = Expression::parse("I have {long} items")
  let result = expr.match_("I have 9223372036854775807 items")
  guard result is Some(m) else { fail("expected match") }
  let value : Int64 = m.params[0].value.to()
  assert_eq(value, 9223372036854775807L)
  assert_eq(m.params[0].raw, "9223372036854775807")
}

///|
test "spec/match: byte" {
  let expr = Expression::parse("value is {byte}")
  let result = expr.match_("value is 127")
  guard result is Some(m) else { fail("expected match") }
  let value : Byte = m.params[0].value.to()
  assert_eq(value, b'\x7F')
  assert_eq(m.params[0].raw, "127")
}

///|
test "spec/match: short" {
  let expr = Expression::parse("port is {short}")
  let result = expr.match_("port is 8080")
  guard result is Some(m) else { fail("expected match") }
  let value : Int = m.params[0].value.to()
  assert_eq(value, 8080)
  assert_eq(m.params[0].raw, "8080")
}

///|
test "spec/match: bigdecimal" {
  let expr = Expression::parse("price is {bigdecimal}")
  let result = expr.match_("price is 99.99")
  guard result is Some(m) else { fail("expected match") }
  let value : @decimal.Decimal = m.params[0].value.to()
  assert_eq(value, @decimal.Decimal::from_string("99.99").unwrap())
  assert_eq(m.params[0].raw, "99.99")
}

///|
test "spec/match: biginteger" {
  let expr = Expression::parse("count is {biginteger}")
  let result = expr.match_("count is 123456789012345678901234567890")
  guard result is Some(m) else { fail("expected match") }
  let value : BigInt = m.params[0].value.to()
  assert_eq(value, BigInt::from_string("123456789012345678901234567890"))
  assert_eq(m.params[0].raw, "123456789012345678901234567890")
}
```

**Step 2: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 3: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/spec_wbtest.mbt
git commit -m "test: add expression matching tests for 6 new parameter types"
```

---

### Task 6: Add custom transformer test

**Files:**
- Modify: `src/custom_param_wbtest.mbt`

**Step 1: Write test for custom type with transformer**

Add to `src/custom_param_wbtest.mbt`:

```moonbit
///|
test "Custom type with transformer returns typed value" {
  let reg = ParamTypeRegistry::default()
  reg.register("color", ParamType::Custom("color"), [
    RegexPattern("red|green|blue"),
  ],
    transformer=fn(groups) { @any.of(groups[0].to_upper()) },
  )
  let expr = Expression::parse_with_registry("I select {color}", reg)
  let result = expr.match_("I select red")
  guard result is Some(m) else { fail("expected match") }
  let value : String = m.params[0].value.to()
  assert_eq(value, "RED")
  assert_eq(m.params[0].raw, "red")
}

///|
test "Custom type without transformer defaults to raw string" {
  let reg = ParamTypeRegistry::default()
  reg.register("direction", ParamType::Custom("direction"), [
    RegexPattern("north|south|east|west"),
  ])
  let expr = Expression::parse_with_registry("go {direction}", reg)
  let result = expr.match_("go north")
  guard result is Some(m) else { fail("expected match") }
  let value : String = m.params[0].value.to()
  assert_eq(value, "north")
  assert_eq(m.params[0].raw, "north")
}
```

**Step 2: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 3: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add src/custom_param_wbtest.mbt
git commit -m "test: add custom transformer and default transformer tests"
```

---

### Task 7: Publish cucumber-expressions 0.3.0

**Files:**
- Modify: `moon.mod.json` (version bump)

**Step 1: Run full test suite**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && mise run test:unit`
Expected: ALL PASS

**Step 2: Run `moon info` to regenerate .mbti files**

Run: `cd /home/damian/code/repos/github/moonrockz/cucumber-expressions && moon info`

**Step 3: Bump version to 0.3.0**

In `moon.mod.json`, change `"version": "0.2.0"` to `"version": "0.3.0"`.

**Step 4: Commit, push, publish**

```bash
cd /home/damian/code/repos/github/moonrockz/cucumber-expressions
git add moon.mod.json src/pkg.generated.mbti
git commit -m "chore: bump version to 0.3.0"
git push
moon publish
```

---

## Phase 2: moonspec

**Repo:** `/home/damian/code/repos/github/moonrockz/moonspec/`

### Task 8: Update cucumber-expressions dependency and add tonyfettes/any

**Files:**
- Modify: `moon.mod.json`
- Modify: `src/core/moon.pkg`

**Step 1: Update dependencies**

Run:
```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
moon update
moon add tonyfettes/any
```

Verify `moon.mod.json` shows `"moonrockz/cucumber-expressions": "0.3.0"` and `"tonyfettes/any"`.

**Step 2: Update `src/core/moon.pkg` imports**

```
import {
  "moonrockz/cucumber-expressions" as @cucumber_expressions,
  "moonrockz/cucumber-messages" as @cucumber_messages,
  "moonbitlang/core/strconv",
  "moonbitlang/x/decimal" as @decimal,
  "tonyfettes/any" as @any,
}
```

**Step 3: Build to verify imports resolve**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && moon check`
Expected: May have compile errors from `Param` struct changes — that's expected, we fix in next task.

**Step 4: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add moon.mod.json src/core/moon.pkg
git commit -m "build: update cucumber-expressions to 0.3.0, add tonyfettes/any"
```

---

### Task 9: Replace StepArg enum with StepArg struct + StepValue enum

**Files:**
- Modify: `src/core/types.mbt`
- Modify: `src/core/types_wbtest.mbt`
- Modify: `src/core/registry.mbt:3` (StepHandler type)
- Modify: `src/core/step_def.mbt` (StepDef handler signatures)
- Modify: `src/core/setup.mbt` (given/when/then/step handler signatures)
- Modify: `src/lib.mbt` (re-exports)

**Step 1: Write failing tests for new StepArg struct**

Replace `src/core/types_wbtest.mbt` entirely:

```moonbit
///|
test "StepArg struct has value and raw fields" {
  let arg = StepArg::{ value: IntVal(42), raw: "42" }
  assert_eq(arg.raw, "42")
  match arg {
    { value: IntVal(n), .. } => assert_eq(n, 42)
    _ => fail("expected IntVal")
  }
}

///|
test "StepArg pattern match with both fields" {
  let arg = StepArg::{ value: StringVal("hello"), raw: "hello" }
  match arg {
    { value: StringVal(s), raw } => {
      assert_eq(s, "hello")
      assert_eq(raw, "hello")
    }
    _ => fail("expected StringVal")
  }
}

///|
test "StepArg pattern match with wildcard on raw" {
  let arg = StepArg::{ value: IntVal(42), raw: "42" }
  match arg {
    { value: IntVal(n), raw: _ } => assert_eq(n, 42)
    _ => fail("expected IntVal")
  }
}

///|
test "StepArg from_param converts Int param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(42),
    type_: @cucumber_expressions.ParamType::Int,
    raw: "42",
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg.raw, "42")
  match arg {
    { value: IntVal(n), .. } => assert_eq(n, 42)
    _ => fail("expected IntVal")
  }
}

///|
test "StepArg from_param converts Float param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(3.14),
    type_: @cucumber_expressions.ParamType::Float,
    raw: "3.14",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: FloatVal(f), .. } => assert_eq(f, 3.14)
    _ => fail("expected FloatVal")
  }
}

///|
test "StepArg from_param converts Double_ param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(3.14),
    type_: @cucumber_expressions.ParamType::Double_,
    raw: "3.14",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: DoubleVal(f), .. } => assert_eq(f, 3.14)
    _ => fail("expected DoubleVal")
  }
}

///|
test "StepArg from_param converts Long param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(9223372036854775807L),
    type_: @cucumber_expressions.ParamType::Long,
    raw: "9223372036854775807",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: LongVal(n), .. } => assert_eq(n, 9223372036854775807L)
    _ => fail("expected LongVal")
  }
}

///|
test "StepArg from_param converts Byte param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(b'\xFF'),
    type_: @cucumber_expressions.ParamType::Byte,
    raw: "255",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: ByteVal(b), .. } => assert_eq(b, b'\xFF')
    _ => fail("expected ByteVal")
  }
}

///|
test "StepArg from_param converts Short param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of(8080),
    type_: @cucumber_expressions.ParamType::Short,
    raw: "8080",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: ShortVal(n), .. } => assert_eq(n, 8080)
    _ => fail("expected ShortVal")
  }
}

///|
test "StepArg from_param converts BigDecimal param" {
  let dec = @decimal.Decimal::from_string("99.99").unwrap()
  let param = @cucumber_expressions.Param::{
    value: @any.of(dec),
    type_: @cucumber_expressions.ParamType::BigDecimal,
    raw: "99.99",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: BigDecimalVal(d), .. } =>
      assert_eq(d, @decimal.Decimal::from_string("99.99").unwrap())
    _ => fail("expected BigDecimalVal")
  }
}

///|
test "StepArg from_param converts BigInteger param" {
  let bi = BigInt::from_string("123456789012345678901234567890")
  let param = @cucumber_expressions.Param::{
    value: @any.of(bi),
    type_: @cucumber_expressions.ParamType::BigInteger,
    raw: "123456789012345678901234567890",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: BigIntegerVal(v), .. } =>
      assert_eq(v, BigInt::from_string("123456789012345678901234567890"))
    _ => fail("expected BigIntegerVal")
  }
}

///|
test "StepArg from_param converts String_ param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of("hello"),
    type_: @cucumber_expressions.ParamType::String_,
    raw: "hello",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: StringVal(s), .. } => assert_eq(s, "hello")
    _ => fail("expected StringVal")
  }
}

///|
test "StepArg from_param converts Word param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of("banana"),
    type_: @cucumber_expressions.ParamType::Word,
    raw: "banana",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: WordVal(s), .. } => assert_eq(s, "banana")
    _ => fail("expected WordVal")
  }
}

///|
test "StepArg from_param converts Custom param" {
  let param = @cucumber_expressions.Param::{
    value: @any.of("red"),
    type_: @cucumber_expressions.ParamType::Custom("color"),
    raw: "red",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: CustomVal(any), .. } => {
      let s : String = any.to()
      assert_eq(s, "red")
    }
    _ => fail("expected CustomVal")
  }
}
```

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: FAIL — `StepArg` is still an enum, `StepValue` doesn't exist

**Step 3: Implement StepValue enum and StepArg struct**

Replace `src/core/types.mbt`:

```moonbit
///|
/// A typed value extracted from step text, pattern-matchable for built-in types.
/// Custom types use `CustomVal(@any.Any)` for type-erased transformer results.
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

///|
/// A step argument carrying both the typed value and the original matched text.
pub(all) struct StepArg {
  value : StepValue
  raw : String
} derive(Show, Eq)

///|
/// Convert a cucumber-expressions Param to a StepArg.
/// Uses ParamType to dispatch the Any value to the correct StepValue variant.
pub fn StepArg::from_param(param : @cucumber_expressions.Param) -> StepArg {
  let value : StepValue = match param.type_ {
    @cucumber_expressions.ParamType::Int => {
      let n : Int = param.value.try_to().or(0)
      IntVal(n)
    }
    @cucumber_expressions.ParamType::Float => {
      let f : Double = param.value.try_to().or(0.0)
      FloatVal(f)
    }
    @cucumber_expressions.ParamType::Double_ => {
      let f : Double = param.value.try_to().or(0.0)
      DoubleVal(f)
    }
    @cucumber_expressions.ParamType::Long => {
      let n : Int64 = param.value.try_to().or(0L)
      LongVal(n)
    }
    @cucumber_expressions.ParamType::Byte => {
      let b : Byte = param.value.try_to().or(b'\x00')
      ByteVal(b)
    }
    @cucumber_expressions.ParamType::Short => {
      let n : Int = param.value.try_to().or(0)
      ShortVal(n)
    }
    @cucumber_expressions.ParamType::String_ => {
      let s : String = param.value.try_to().or("")
      StringVal(s)
    }
    @cucumber_expressions.ParamType::Word => {
      let s : String = param.value.try_to().or("")
      WordVal(s)
    }
    @cucumber_expressions.ParamType::Anonymous => {
      let s : String = param.value.try_to().or("")
      StringVal(s)
    }
    @cucumber_expressions.ParamType::BigDecimal => {
      let d : @decimal.Decimal = param.value.try_to().or(
        @decimal.Decimal::from_string("0").unwrap(),
      )
      BigDecimalVal(d)
    }
    @cucumber_expressions.ParamType::BigInteger => {
      let bi : BigInt = param.value.try_to().or(0N)
      BigIntegerVal(bi)
    }
    @cucumber_expressions.ParamType::Custom(_) => CustomVal(param.value)
  }
  { value, raw: param.raw }
}

///|
/// Result of matching step text against the registry.
pub(all) enum StepMatchResult {
  Matched(StepDef, Array[StepArg])
  Undefined(
    step_text~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
}

///|
/// Information about a scenario being executed.
pub(all) struct ScenarioInfo {
  feature_name : String
  scenario_name : String
  tags : Array[String]
} derive(Show, Eq)

///|
/// Information about a step being executed.
pub(all) struct StepInfo {
  keyword : String
  text : String
} derive(Show, Eq)
```

**Step 4: Update StepHandler type**

In `src/core/registry.mbt`, the StepHandler type stays the same — it uses `Array[StepArg]`. No change needed since `StepArg` is now a struct not an enum, but handlers still receive `Array[StepArg]`.

**Step 5: Update lib.mbt re-exports**

Add `StepValue` to re-exports in `src/lib.mbt`:

```moonbit
pub using @core {
  trait World,
  trait StepLibrary,
  type StepRegistry,
  type StepDef,
  type StepArg,
  type StepValue,
  type StepKeyword,
  type StepSource,
  type StepMatchResult,
  type MoonspecError,
  type ScenarioInfo,
  type StepInfo,
  type Setup,
  type HookRegistry,
  type HookType,
  type HookHandler,
  type RegisteredHook,
}
```

**Step 6: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: FAIL — runner tests still use old `StepArg::IntArg(n)` pattern. Fix in next task.

**Step 7: Commit (types compile, unit tests for types pass)**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add src/core/types.mbt src/core/types_wbtest.mbt src/lib.mbt
git commit -m "feat: StepArg struct with StepValue enum and raw text access"
```

---

### Task 10: Migrate all step handler pattern matches

**Files:**
- Modify: `src/runner/feature_wbtest.mbt`
- Modify: `src/runner/e2e_wbtest.mbt`
- Modify: `src/runner/hooks_wbtest.mbt`
- Modify: `src/core/registry_wbtest.mbt`
- Modify: `src/core/step_library_wbtest.mbt`
- Any other files referencing `StepArg::IntArg`, `StepArg::FloatArg`, etc.

**Step 1: Update all pattern matches from enum to struct destructuring**

Replace all occurrences of `StepArg::IntArg(n)` with `{ value: IntVal(n), .. }` (or the appropriate variant).

Example from `src/runner/feature_wbtest.mbt`:

```moonbit
// Before:
@core.StepArg::IntArg(n) => self.total = n

// After:
{ value: @core.StepValue::IntVal(n), .. } => self.total = n
```

Example from `src/runner/e2e_wbtest.mbt`:

```moonbit
// Before:
(@core.StepArg::IntArg(a), @core.StepArg::IntArg(b)) =>

// After:
({ value: @core.StepValue::IntVal(a), .. }, { value: @core.StepValue::IntVal(b), .. }) =>
```

**Step 2: Run full test suite**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS

**Step 3: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add -u
git commit -m "refactor: migrate step handlers from StepArg enum to struct destructuring"
```

---

### Task 11: Update Setup.add_param_type with transformer support

**Files:**
- Modify: `src/core/setup.mbt:40-66`
- Modify: `src/core/setup_wbtest.mbt`

**Step 1: Write failing test for transformer on add_param_type**

Add to `src/core/setup_wbtest.mbt`:

```moonbit
///|
test "Setup.add_param_type with transformer" {
  let setup = Setup::new()
  setup.add_param_type_strings("upper", ["\\w+"],
    transformer=fn(groups) { @any.of(groups[0].to_upper()) },
  )
  setup.given("I say {upper}", fn(args) {
    match args[0] {
      { value: CustomVal(any), raw } => {
        let v : String = any.to()
        assert_eq(v, "HELLO")
        assert_eq(raw, "hello")
      }
      _ => fail("expected CustomVal")
    }
  })
}
```

**Step 2: Run tests to verify they fail**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: FAIL — `add_param_type_strings` doesn't accept `transformer~`

**Step 3: Update Setup.add_param_type methods**

In `src/core/setup.mbt`, update both `add_param_type` and `add_param_type_strings`:

```moonbit
///|
/// Register a custom parameter type with name, regex patterns, and optional transformer.
pub fn Setup::add_param_type(
  self : Setup,
  name : String,
  patterns : Array[@cucumber_expressions.RegexPattern],
  transformer~ : @cucumber_expressions.Transformer = fn(groups) { @any.of(groups[0]) },
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns,
    transformer~,
  )
}

///|
/// Register a custom parameter type with string patterns and optional transformer.
pub fn Setup::add_param_type_strings(
  self : Setup,
  name : String,
  patterns : Array[String],
  transformer~ : @cucumber_expressions.Transformer = fn(groups) { @any.of(groups[0]) },
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns.map(fn(p) { @cucumber_expressions.RegexPattern(p) }),
    transformer~,
  )
}
```

Also update `custom_param_types` to include all new built-in type names:

```moonbit
pub fn Setup::custom_param_types(self : Setup) -> Array[CustomParamTypeInfo] {
  let builtin = [
    "int", "float", "string", "word", "",
    "double", "long", "byte", "short", "bigdecimal", "biginteger",
  ]
  // ... rest unchanged
}
```

**Step 4: Run tests to verify they pass**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS

**Step 5: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add src/core/setup.mbt src/core/setup_wbtest.mbt
git commit -m "feat: Setup.add_param_type accepts transformer callback"
```

---

### Task 12: Final cleanup

**Files:**
- Various

**Step 1: Run `moon fmt`**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && moon fmt`

**IMPORTANT:** Revert `.pkg` file changes:

```bash
git checkout -- src/*/moon.pkg src/*/*/moon.pkg
```

**Step 2: Run `moon info`**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && moon info`

**Step 3: Run full test suite**

Run: `cd /home/damian/code/repos/github/moonrockz/moonspec && mise run test:unit`
Expected: ALL PASS

**Step 4: Commit**

```bash
cd /home/damian/code/repos/github/moonrockz/moonspec
git add -u
git commit -m "chore: format and regenerate mbti after parameter type changes"
```
