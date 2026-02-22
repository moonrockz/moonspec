///|
test "StepArg::IntArg derives Show" {
  inspect(StepArg::IntArg(42), content="IntArg(42)")
}

///|
test "StepArg::StringArg derives Show" {
  inspect(StepArg::StringArg("hello"), content="StringArg(\"hello\")")
}

///|
test "StepArg from_param converts Int param" {
  let param = @cucumber_expressions.Param::{
    value: "42",
    type_: @cucumber_expressions.ParamType::Int,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::IntArg(42))
}

///|
test "StepArg from_param converts Float param" {
  let param = @cucumber_expressions.Param::{
    value: "3.14",
    type_: @cucumber_expressions.ParamType::Float,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::FloatArg(3.14))
}

///|
test "StepArg from_param converts String_ param" {
  let param = @cucumber_expressions.Param::{
    value: "hello",
    type_: @cucumber_expressions.ParamType::String_,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::StringArg("hello"))
}

///|
test "StepArg from_param converts Word param" {
  let param = @cucumber_expressions.Param::{
    value: "banana",
    type_: @cucumber_expressions.ParamType::Word,
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::WordArg("banana"))
}

///|
test "StepArg from_param converts Custom param" {
  let param = @cucumber_expressions.Param::{
    value: "red",
    type_: @cucumber_expressions.ParamType::Custom("color"),
  }
  let arg = StepArg::from_param(param)
  assert_eq(arg, StepArg::CustomArg("red"))
}
