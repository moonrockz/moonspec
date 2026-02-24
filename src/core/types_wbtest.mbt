///|
test "StepArg struct destructuring" {
  let arg = StepArg::{ value: IntVal(42), raw: "42" }
  match arg {
    { value: IntVal(n), raw } => {
      assert_eq(n, 42)
      assert_eq(raw, "42")
    }
    _ => fail("expected IntVal")
  }
}

///|
test "StepArg struct wildcard" {
  let arg = StepArg::{ value: IntVal(42), raw: "42" }
  match arg {
    { value: IntVal(n), .. } => assert_eq(n, 42)
    _ => fail("expected IntVal")
  }
}

///|
test "StepArg from_param Int" {
  let param = @cucumber_expressions.Param::{
    value: @cucumber_expressions.ParamValue::IntVal(42),
    type_: @cucumber_expressions.ParamType::Int,
    raw: "42",
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg.raw, "42")
  match arg {
    { value: IntVal(n), .. } => assert_eq(n, 42)
    _ => fail("")
  }
}

///|
test "StepArg from_param Float" {
  let param = @cucumber_expressions.Param::{
    value: @cucumber_expressions.ParamValue::FloatVal(3.14),
    type_: @cucumber_expressions.ParamType::Float,
    raw: "3.14",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: FloatVal(f), .. } => assert_eq(f, 3.14)
    _ => fail("")
  }
}

///|
test "StepArg from_param String_" {
  let param = @cucumber_expressions.Param::{
    value: @cucumber_expressions.ParamValue::StringVal("hello"),
    type_: @cucumber_expressions.ParamType::String_,
    raw: "hello",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: StringVal(s), .. } => assert_eq(s, "hello")
    _ => fail("")
  }
}

///|
test "StepArg from_param Word" {
  let param = @cucumber_expressions.Param::{
    value: @cucumber_expressions.ParamValue::WordVal("banana"),
    type_: @cucumber_expressions.ParamType::Word,
    raw: "banana",
  }
  let arg = StepArg::from_param(param)
  match arg {
    { value: WordVal(s), .. } => assert_eq(s, "banana")
    _ => fail("")
  }
}

///|
test "StepArg from_param Custom" {
  let param = @cucumber_expressions.Param::{
    value: @cucumber_expressions.ParamValue::CustomVal(@any.of("red")),
    type_: @cucumber_expressions.ParamType::Custom("color"),
    raw: "red",
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg.raw, "red")
}
