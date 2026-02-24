///|
test "StepArg struct destructuring" {
  let arg = StepArg::{ value: IntVal(42), raw: "42" }
  match arg {
    { value: IntVal(n), raw, .. } => {
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

///|
test "Cells constructor and accessors" {
  let cells = Cells(["Alice", "30", "admin"])
  assert_eq(cells.length(), 3)
  assert_eq(cells.get(0), "Alice")
  assert_eq(cells.get(2), "admin")
  let view = cells.values()
  assert_eq(view.length(), 3)
  assert_eq(view[1], "30")
}

///|
test "Row constructor wraps cells" {
  let row = Row(["Alice", "30"])
  assert_eq(row.cells.length(), 2)
  assert_eq(row.cells.get(0), "Alice")
  assert_eq(row.cells.get(1), "30")
}

///|
test "Rows constructor and accessors" {
  let rows = Rows([Row(["a", "b"]), Row(["c", "d"])])
  assert_eq(rows.length(), 2)
  assert_eq(rows.get(0).cells.get(0), "a")
  assert_eq(rows.get(1).cells.get(1), "d")
  let view = rows.values()
  assert_eq(view.length(), 2)
}

///|
test "Column constructor" {
  let col = Column(name="age", index=1)
  assert_eq(col.name, "age")
  assert_eq(col.index, 1)
}

///|
test "Columns accessors and find" {
  let cols = Columns([Column(name="name", index=0), Column(name="age", index=1)])
  assert_eq(cols.length(), 2)
  assert_eq(cols.get(0).name, "name")
  let view = cols.values()
  assert_eq(view.length(), 2)
  match cols.find("age") {
    Some(c) => {
      assert_eq(c.name, "age")
      assert_eq(c.index, 1)
    }
    None => fail("expected to find 'age'")
  }
  assert_true(cols.find("missing") is None)
}

///|
test "DataTable constructor derives columns from header row" {
  let table = DataTable([["name", "age"], ["Alice", "30"], ["Bob", "25"]])
  assert_eq(table.row_count(), 3)
  assert_eq(table.col_count(), 2)
  assert_eq(table.columns.get(0).name, "name")
  assert_eq(table.columns.get(1).name, "age")
  assert_eq(table.columns.get(1).index, 1)
  assert_eq(table.rows.get(1).cells.get(0), "Alice")
  assert_eq(table.rows.get(2).cells.get(1), "25")
}

///|
test "DataTable.as_maps skips header row" {
  let table = DataTable([["name", "age"], ["Alice", "30"], ["Bob", "25"]])
  let maps = table.as_maps()
  assert_eq(maps.length(), 2)
  assert_eq(maps[0]["name"], "Alice")
  assert_eq(maps[0]["age"], "30")
  assert_eq(maps[1]["name"], "Bob")
  assert_eq(maps[1]["age"], "25")
}

///|
test "DataTable empty" {
  let table = DataTable([])
  assert_eq(table.row_count(), 0)
  assert_eq(table.col_count(), 0)
  assert_eq(table.as_maps().length(), 0)
}

///|
test "DocString constructor with media type" {
  let doc = DocString(content="hello world", media_type="json")
  assert_eq(doc.content, "hello world")
  assert_eq(doc.media_type, Some("json"))
}

///|
test "DocString constructor without media type" {
  let doc = DocString(content="plain text")
  assert_eq(doc.content, "plain text")
  assert_eq(doc.media_type, None)
}

///|
test "StepArg with DocStringVal" {
  let doc = DocString(content="hello", media_type="json")
  let arg : StepArg = { value: DocStringVal(doc), raw: "" }
  match arg {
    { value: DocStringVal(d), .. } => {
      assert_eq(d.content, "hello")
      assert_eq(d.media_type, Some("json"))
    }
    _ => fail("expected DocStringVal")
  }
}

///|
test "StepArg with DataTableVal" {
  let table = DataTable([["name"], ["Alice"]])
  let arg : StepArg = { value: DataTableVal(table), raw: "" }
  match arg {
    { value: DataTableVal(t), .. } => {
      assert_eq(t.row_count(), 2)
      assert_eq(t.rows.get(1).cells.get(0), "Alice")
    }
    _ => fail("expected DataTableVal")
  }
}

///|
test "Ctx op_get returns StepArg" {
  let args = [StepArg::{ value: IntVal(42), raw: "42" }]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx[0].value, IntVal(42))
}

///|
test "Ctx arg method" {
  let args = [StepArg::{ value: StringVal("hello"), raw: "hello" }]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx.arg(0).raw, "hello")
}

///|
test "Ctx args returns view" {
  let args = [
    StepArg::{ value: IntVal(1), raw: "1" },
    StepArg::{ value: IntVal(2), raw: "2" },
  ]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  let view = ctx.args()
  assert_eq(view.length(), 2)
}

///|
test "Ctx scenario and step accessors" {
  let args : Array[StepArg] = []
  let info : ScenarioInfo = {
    feature_name: "MyFeature",
    scenario_name: "MyScenario",
    tags: ["@smoke"],
  }
  let step : StepInfo = { keyword: "When ", text: "I do something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx.scenario().feature_name, "MyFeature")
  assert_eq(ctx.scenario().tags[0], "@smoke")
  assert_eq(ctx.step().keyword, "When ")
  assert_eq(ctx.step().text, "I do something")
}

///|
test "Ctx value convenience accessor" {
  let args = [
    StepArg::{ value: IntVal(42), raw: "42" },
    StepArg::{ value: StringVal("hello"), raw: "hello" },
  ]
  let info : ScenarioInfo = { feature_name: "F", scenario_name: "S", tags: [] }
  let step : StepInfo = { keyword: "Given ", text: "something" }
  let ctx = Ctx::new(args, info, step)
  assert_eq(ctx.value(0), IntVal(42))
  assert_eq(ctx.value(1), StringVal("hello"))
}

///|
test "Ctx attach text" {
  let ctx = Ctx::new([], { feature_name: "F", scenario_name: "S", tags: [] }, {
    keyword: "Given ",
    text: "step",
  })
  ctx.attach("hello", "text/plain")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    Embedded(body~, encoding~, media_type~, file_name~) => {
      assert_eq(body, "hello")
      assert_eq(encoding.to_json().stringify(), "\"IDENTITY\"")
      assert_eq(media_type, "text/plain")
      assert_eq(file_name, None)
    }
    _ => fail("expected Embedded attachment")
  }
}

///|
test "Ctx attach_bytes base64 encodes" {
  let ctx = Ctx::new([], { feature_name: "F", scenario_name: "S", tags: [] }, {
    keyword: "Given ",
    text: "step",
  })
  ctx.attach_bytes(b"hello", "application/octet-stream")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    Embedded(body~, encoding~, media_type~, ..) => {
      assert_eq(body, "aGVsbG8=")
      assert_eq(encoding.to_json().stringify(), "\"BASE64\"")
      assert_eq(media_type, "application/octet-stream")
    }
    _ => fail("expected Embedded attachment")
  }
}

///|
test "Ctx attach_url" {
  let ctx = Ctx::new([], { feature_name: "F", scenario_name: "S", tags: [] }, {
    keyword: "Given ",
    text: "step",
  })
  ctx.attach_url("https://example.com/img.png", "image/png")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    External(url~, media_type~) => {
      assert_eq(url, "https://example.com/img.png")
      assert_eq(media_type, "image/png")
    }
    _ => fail("expected External attachment")
  }
}

///|
test "Ctx attach with file_name" {
  let ctx = Ctx::new([], { feature_name: "F", scenario_name: "S", tags: [] }, {
    keyword: "Given ",
    text: "step",
  })
  ctx.attach("some notes", "text/plain", file_name="notes.txt")
  assert_eq(ctx.attachments.length(), 1)
  match ctx.attachments[0] {
    Embedded(file_name~, ..) => assert_eq(file_name, Some("notes.txt"))
    _ => fail("expected Embedded attachment")
  }
}

///|
test "HookResult Passed" {
  let result : HookResult = Passed
  match result {
    Passed => ()
    _ => fail("expected Passed")
  }
}

///|
test "HookResult Failed with StepFailed" {
  let result : HookResult = Failed([
    HookError::StepFailed(
      step="I add 1 and 2",
      keyword=StepKeyword::When,
      message="assertion failed",
    ),
  ])
  match result {
    Failed(errors) => {
      assert_eq(errors.length(), 1)
      match errors[0] {
        StepFailed(step~, keyword~, message~) => {
          assert_eq(step, "I add 1 and 2")
          assert_eq(keyword, StepKeyword::When)
          assert_eq(message, "assertion failed")
        }
        _ => fail("expected StepFailed")
      }
    }
    _ => fail("expected Failed")
  }
}

///|
test "HookResult Failed with ScenarioFailed" {
  let result : HookResult = Failed([
    HookError::ScenarioFailed(
      feature_name="Calculator",
      scenario_name="Addition",
      message="step failed",
    ),
  ])
  match result {
    Failed(errors) => {
      assert_eq(errors.length(), 1)
      match errors[0] {
        ScenarioFailed(feature_name~, scenario_name~, message~) => {
          assert_eq(feature_name, "Calculator")
          assert_eq(scenario_name, "Addition")
          assert_eq(message, "step failed")
        }
        _ => fail("expected ScenarioFailed")
      }
    }
    _ => fail("expected Failed")
  }
}
