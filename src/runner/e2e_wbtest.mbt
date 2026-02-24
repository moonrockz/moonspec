///|
struct CalcWorld {
  mut result_val : Int
} derive(Default)

///|
impl @core.World for CalcWorld with configure(self, setup) {
  setup.given("a calculator", fn(_ctx) { self.result_val = 0 })
  setup.when("I add {int} and {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @core.StepValue::IntVal(a), .. },
        { value: @core.StepValue::IntVal(b), .. },
      ) => self.result_val = a + b
      _ => ()
    }
  })
  setup.when("I subtract {int} from {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @core.StepValue::IntVal(a), .. },
        { value: @core.StepValue::IntVal(b), .. },
      ) => self.result_val = b - a
      _ => ()
    }
  })
  setup.when("I multiply {int} and {int}", fn(ctx) {
    match (ctx[0], ctx[1]) {
      (
        { value: @core.StepValue::IntVal(a), .. },
        { value: @core.StepValue::IntVal(b), .. },
      ) => self.result_val = a * b
      _ => ()
    }
  })
  setup.then("the result should be {int}", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::IntVal(expected), .. } =>
        assert_eq(self.result_val, expected)
      _ => ()
    }
  })
}

///|
async test "end-to-end: calculator feature" {
  let content = "Feature: Calculator\n\n  Background:\n    Given a calculator\n\n  Scenario: Addition\n    When I add 5 and 3\n    Then the result should be 8\n\n  Scenario: Subtraction\n    When I subtract 3 from 10\n    Then the result should be 7\n\n  @slow\n  Scenario Outline: Multiplication\n    When I multiply <a> and <b>\n    Then the result should be <result>\n\n    Examples:\n      | a  | b  | result |\n      | 2  | 3  | 6      |\n      | 10 | 5  | 50     |\n"
  let result = run(
    CalcWorld::default,
    RunOptions([FeatureSource::Text("test://calc", content)]),
  )
  assert_eq(result.summary.total_scenarios, 4) // 2 regular + 2 outline rows
  assert_eq(result.summary.passed, 4)
  assert_eq(result.summary.failed, 0)
}

///|
struct TagWorld {} derive(Default)

///|
impl @core.World for TagWorld with configure(_self, setup) {
  setup.given("a calculator", fn(_ctx) {  })
  setup.when("I add {int} and {int}", fn(_ctx) {  })
  setup.then("the result should be {int}", fn(_ctx) {  })
}

///|
async test "end-to-end: tag filtering" {
  let content = "Feature: Tagged\n\n  @smoke\n  Scenario: Fast\n    Given a calculator\n\n  @slow\n  Scenario: Slow\n    Given a calculator\n"
  let opts = RunOptions([FeatureSource::Text("test://tagged", content)])
  opts.tag_expr("@smoke")
  let result = run(TagWorld::default, opts)
  assert_eq(result.summary.total_scenarios, 1)
}

///|
struct DocWorld {
  mut payload : String
  mut media : String?
  mut users : Array[Map[String, String]]
} derive(Default)

///|
impl @core.World for DocWorld with configure(self, setup) {
  setup.given("a JSON payload", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::DocStringVal(doc), .. } => {
        self.payload = doc.content
        self.media = doc.media_type
      }
      _ => ()
    }
  })
  setup.given("the following users", fn(ctx) {
    match ctx[0] {
      { value: @core.StepValue::DataTableVal(table), .. } =>
        self.users = table.as_maps()
      _ => ()
    }
  })
  setup.then("the payload should contain {string}", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::StringVal(expected), .. } =>
        assert_true(self.payload.contains(expected))
      _ => ()
    }
  })
  setup.then("the media type should be {string}", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::StringVal(expected), .. } =>
        assert_eq(self.media, Some(expected))
      _ => ()
    }
  })
  setup.then("there should be {int} users", fn(ctx) raise {
    match ctx[0] {
      { value: @core.StepValue::IntVal(n), .. } =>
        assert_eq(self.users.length(), n)
      _ => ()
    }
  })
  setup.then("user {int} should have name {string}", fn(ctx) raise {
    match (ctx[0], ctx[1]) {
      (
        { value: @core.StepValue::IntVal(idx), .. },
        { value: @core.StepValue::StringVal(name), .. },
      ) => assert_eq(self.users[idx - 1]["name"], name)
      _ => ()
    }
  })
}

///|
async test "end-to-end: doc string with media type" {
  let content =
    #|Feature: DocString
    #|
    #|  Scenario: JSON payload
    #|    Given a JSON payload
    #|      """json
    #|      {"key": "value"}
    #|      """
    #|    Then the payload should contain "key"
    #|    Then the media type should be "json"
  let result = run(
    DocWorld::default,
    RunOptions([FeatureSource::Text("test://docstring", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}

///|
async test "end-to-end: data table" {
  let content =
    #|Feature: DataTable
    #|
    #|  Scenario: Users
    #|    Given the following users
    #|      | name  | age |
    #|      | Alice | 30  |
    #|      | Bob   | 25  |
    #|    Then there should be 2 users
    #|    Then user 1 should have name "Alice"
  let result = run(
    DocWorld::default,
    RunOptions([FeatureSource::Text("test://datatable", content)]),
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
}

///|
struct AttachWorld {} derive(Default)

///|
impl @core.World for AttachWorld with configure(_self, setup) {
  setup.given("I attach a {string}", fn(ctx) {
    ctx.attach("my note", "text/plain", file_name="note.txt")
  })
}

///|
async test "end-to-end: step attachment emits envelope" {
  let content =
    #|Feature: Attachments
    #|
    #|  Scenario: Attach text
    #|    Given I attach a "note"
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://attach", content)])
  opts.add_sink(messages)
  let result = run(AttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("\"attachment\""))
  assert_true(output.contains("my note"))
}

///|
struct UrlAttachWorld {} derive(Default)

///|
impl @core.World for UrlAttachWorld with configure(_self, setup) {
  setup.given("I attach an external {string}", fn(ctx) {
    ctx.attach_url("https://example.com/img.png", "image/png")
  })
}

///|
async test "end-to-end: attach_url emits ExternalAttachment" {
  let content =
    #|Feature: External
    #|
    #|  Scenario: URL attachment
    #|    Given I attach an external "image"
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([FeatureSource::Text("test://extattach", content)])
  opts.add_sink(messages)
  let result = run(UrlAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("\"externalAttachment\""))
  assert_true(output.contains("https://example.com/img.png"))
}

///|
struct CaseHookAttachWorld {} derive(Default)

///|
impl @core.World for CaseHookAttachWorld with configure(_self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.before_test_case(fn(ctx) { ctx.attach("case setup log", "text/plain") })
}

///|
async test "end-to-end: case hook attachment emits envelope" {
  let content =
    #|Feature: CaseHookAttach
    #|
    #|  Scenario: With hook attachment
    #|    Given a step
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([
    FeatureSource::Text("test://case-hook-attach", content),
  ])
  opts.add_sink(messages)
  let result = run(CaseHookAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("case setup log"))
}

///|
struct StepHookAttachWorld {} derive(Default)

///|
impl @core.World for StepHookAttachWorld with configure(_self, setup) {
  setup.given("a step", fn(_ctx) { () })
  setup.after_test_step(fn(ctx, _result) {
    ctx.attach("step trace", "text/plain")
  })
}

///|
async test "end-to-end: step hook attachment emits envelope" {
  let content =
    #|Feature: StepHookAttach
    #|
    #|  Scenario: With step hook attachment
    #|    Given a step
  let messages = @format.MessagesFormatter::new()
  let opts = RunOptions([
    FeatureSource::Text("test://step-hook-attach", content),
  ])
  opts.add_sink(messages)
  let result = run(StepHookAttachWorld::default, opts)
  assert_eq(result.summary.passed, 1)
  let output = messages.output()
  assert_true(output.contains("step trace"))
}
