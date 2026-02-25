///|
test "FromStepArg: Int from IntVal" {
  let arg : StepArg = { value: IntVal(42), raw: "42" }
  let result : Int = FromStepArg::from_step_arg(arg)
  assert_eq(result, 42)
}

///|
test "FromStepArg: Int from non-IntVal raises" {
  let arg : StepArg = { value: StringVal("hello"), raw: "hello" }
  let mut raised = false
  try {
    let _ : Int = FromStepArg::from_step_arg(arg)
  } catch {
    _ => raised = true
  }
  assert_true(raised)
}

///|
test "FromStepArg: Double from FloatVal" {
  let arg : StepArg = { value: FloatVal(3.14), raw: "3.14" }
  let result : Double = FromStepArg::from_step_arg(arg)
  assert_eq(result, 3.14)
}

///|
test "FromStepArg: Double from DoubleVal" {
  let arg : StepArg = { value: DoubleVal(2.718), raw: "2.718" }
  let result : Double = FromStepArg::from_step_arg(arg)
  assert_eq(result, 2.718)
}

///|
test "FromStepArg: Int64 from LongVal" {
  let arg : StepArg = { value: LongVal(9999999999L), raw: "9999999999" }
  let result : Int64 = FromStepArg::from_step_arg(arg)
  assert_eq(result, 9999999999L)
}

///|
test "FromStepArg: Byte from ByteVal" {
  let arg : StepArg = { value: ByteVal(b'\xFF'), raw: "255" }
  let result : Byte = FromStepArg::from_step_arg(arg)
  assert_eq(result, b'\xFF')
}

///|
test "FromStepArg: String from StringVal" {
  let arg : StepArg = { value: StringVal("hello"), raw: "hello" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq(result, "hello")
}

///|
test "FromStepArg: String from WordVal" {
  let arg : StepArg = { value: WordVal("world"), raw: "world" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq(result, "world")
}

///|
test "FromStepArg: String from AnonymousVal" {
  let arg : StepArg = { value: AnonymousVal("anon"), raw: "anon" }
  let result : String = FromStepArg::from_step_arg(arg)
  assert_eq(result, "anon")
}

///|
test "FromStepArg: BigInt from BigIntegerVal" {
  let arg : StepArg = { value: BigIntegerVal(42N), raw: "42" }
  let result : BigInt = FromStepArg::from_step_arg(arg)
  assert_eq(result, 42N)
}

///|
test "FromStepArg: DataTable from DataTableVal" {
  let dt = DataTable::from_rows([["name", "qty"], ["apple", "3"]])
  let arg : StepArg = { value: DataTableVal(dt), raw: "" }
  let result : DataTable = FromStepArg::from_step_arg(arg)
  assert_eq(result.row_count(), 2)
}

///|
test "FromStepArg: DocString from DocStringVal" {
  let ds : DocString = { content: "hello world", media_type: None }
  let arg : StepArg = { value: DocStringVal(ds), raw: "" }
  let result : DocString = FromStepArg::from_step_arg(arg)
  assert_eq(result.content, "hello world")
}
