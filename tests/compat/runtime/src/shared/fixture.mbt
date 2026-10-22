///|
pub struct CompatWorld {
  mut counter : Int32
  attempts : Map[String, Int32]
  hook_log : Array[String]
  with_hooks : Bool
}

///|
pub impl @moonspec.World for CompatWorld with fn configure(self, setup) {
  setup.given("pass", _ctx => ())
  setup.given("fail", fn(_ctx) raise { raise Failure("expected failure") })
  setup.given("pending", fn(_ctx) raise {
    raise @core.pending_step_error(
      step="pending",
      keyword="Given",
      message="not implemented",
    )
  })
  setup.given1("counter is {int}", fn(expected : Int32) raise {
    assert_eq(self.counter, expected)
  })
  setup.when1("counter becomes {int}", fn(value : Int32) {
    self.counter = value
  })
  setup.given("fail once in a fresh world", fn(ctx) raise {
    assert_eq(self.counter, 0)
    self.counter = 99
    let name = ctx.scenario().scenario_name
    let previous = self.attempts.get(name).unwrap_or(0)
    self.attempts.set(name, previous + 1)
    if previous == 0 {
      raise Failure("transient failure")
    }
  })
  setup.given("attach evidence", ctx => {
    self.hook_log.push(
      "handler:" + ctx.scenario().scenario_name + ":" + ctx.step().text,
    )
    ctx.attach("step evidence", "text/plain", file_name="evidence.txt")
    ctx.attach_bytes(
      b"abc",
      "application/octet-stream",
      file_name="evidence.bin",
    )
    ctx.attach_url("https://example.test/evidence", "text/uri-list")
  })
  if self.with_hooks {
    setup.before_test_run(ctx => {
      self.hook_log.push("before_run")
      ctx.attach("before run", "text/plain")
    })
    setup.after_test_run(fn(ctx, result) {
      self.hook_log.push("after_run:" + hook_status(result))
      ctx.attach("after run", "text/plain")
    })
    setup.before_test_case(ctx => {
      let name = ctx.scenario().scenario_name
      self.hook_log.push("before_case:" + name)
      ctx.attach("before case:" + name, "text/plain")
    })
    setup.after_test_case(fn(ctx, result) {
      let name = ctx.scenario().scenario_name
      self.hook_log.push("after_case:" + name + ":" + hook_status(result))
      ctx.attach("after case:" + name, "text/plain")
    })
    setup.before_test_step(ctx => {
      let name = ctx.scenario().scenario_name + ":" + ctx.step().text
      self.hook_log.push("before_step:" + name)
      ctx.attach("before step:" + name, "text/plain")
    })
    setup.after_test_step(fn(ctx, result) {
      let name = ctx.scenario().scenario_name + ":" + ctx.step().text
      self.hook_log.push("after_step:" + name + ":" + hook_status(result))
      ctx.attach("after step:" + name, "text/plain")
    })
  }
}

///|
fn hook_status(result : @moonspec.HookResult) -> String {
  match result {
    Passed => "Passed"
    Failed(_) => "Failed"
  }
}

///|
fn step_status(status : @moonspec.StepStatus) -> String {
  match status {
    Passed => "Passed"
    Failed(_) => "Failed"
    Undefined => "Undefined"
    Pending => "Pending"
    Skipped(_) => "Skipped"
  }
}

///|
fn scenario_status(status : @moonspec.ScenarioStatus) -> String {
  match status {
    Passed => "Passed"
    Failed => "Failed"
    Undefined => "Undefined"
    Pending => "Pending"
    Skipped(_) => "Skipped"
  }
}

///|
fn observation(
  label : String,
  result : @moonspec.RunResult,
  messages : String,
  hook_log : Array[String],
) -> Json {
  let summary = result.summary
  let scenarios : Array[Json] = []
  for feature in result.features {
    for scenario in feature.scenarios {
      let steps = scenario.steps.map(fn(step) {
        let message = match step.status {
          Failed(message) => message
          _ => ""
        }
        let diagnostic = match step.diagnostic {
          Some(error) => error.to_string()
          None => ""
        }
        let json : Json = {
          "text": Json(step.text),
          "status": Json(step_status(step.status)),
          "message": Json(message),
          "diagnostic": Json(diagnostic),
        }
        json
      })
      scenarios.push({
        "name": Json(scenario.scenario_name),
        "status": Json(scenario_status(scenario.status)),
        "skip_reason": match scenario.status {
          Skipped(Some(reason)) => Json(reason)
          _ => Json::null()
        },
        "steps": Json(steps),
      })
    }
  }
  {
    "fixture": Json(label),
    "summary": {
      "total": Json(summary.total_scenarios),
      "passed": Json(summary.passed),
      "failed": Json(summary.failed),
      "undefined": Json(summary.undefined),
      "pending": Json(summary.pending),
      "skipped": Json(summary.skipped),
      "retried": Json(summary.retried),
    },
    "scenarios": Json(scenarios),
    "parse_errors": Json(
      result.parse_errors.map(fn(error) {
        let json : Json = {
          "uri": Json(error.uri),
          "message": Json(error.message),
          "line": match error.line {
            Some(line) => Json(line)
            None => Json::null()
          },
        }
        json
      }),
    ),
    "messages": Json(messages),
    "hook_log": Json(hook_log),
  }
}

///|
pub fn fixture(label : String, path : String) -> Fixture raise {
  let content = @fs.read_file_to_string(path)
  let messages = @format.MessagesFormatter::new()
  let sources = [@moonspec.FeatureSource::Text(path, content)]
  if label == "parse-error" {
    let valid_path = "fixtures/passing.feature"
    sources.push(
      @moonspec.FeatureSource::Text(
        valid_path,
        @fs.read_file_to_string(valid_path),
      ),
    )
  }
  let options = @moonspec.RunOptions(sources)
  options.retries(2)
  if label == "tag-filter" {
    options.tag_expr("@keep and not @drop")
  }
  if label == "name-filter" {
    options.scenario_name("Selected")
  }
  if label == "dry-run" || label == "hooks-dry-run" {
    options.dry_run(true)
  }
  options.add_sink(messages)
  let attempts : Map[String, Int32] = Map([])
  let hook_log : Array[String] = []
  Fixture::{
    options,
    attempts,
    hook_log,
    with_hooks: label.has_prefix("hooks"),
    messages,
  }
}

///|
pub struct Fixture {
  options : @moonspec.RunOptions
  attempts : Map[String, Int32]
  hook_log : Array[String]
  with_hooks : Bool
  messages : @format.MessagesFormatter
}

///|
pub fn Fixture::world(self : Fixture) -> CompatWorld {
  CompatWorld::{
    counter: 0,
    attempts: self.attempts,
    hook_log: self.hook_log,
    with_hooks: self.with_hooks,
  }
}

///|
pub fn Fixture::emit(
  self : Fixture,
  label : String,
  result : @moonspec.RunResult,
) -> Unit {
  println(
    "COMPAT:" +
    observation(label, result, self.messages.output(), self.hook_log).stringify(),
  )
}

///|
pub fn fixtures() -> Array[(String, String)] {
  [
    ("passing", "fixtures/passing.feature"),
    ("outcomes", "fixtures/outcomes.feature"),
    ("retries-isolation", "fixtures/retries-isolation.feature"),
    ("tag-filter", "fixtures/filtering.feature"),
    ("name-filter", "fixtures/filtering.feature"),
    ("dry-run", "fixtures/outcomes.feature"),
    ("parse-error", "fixtures/invalid.feature"),
    ("hooks", "fixtures/hooks.feature"),
    ("hooks-dry-run", "fixtures/hooks.feature"),
  ]
}

///|
pub fn portable_options() -> @moonspec.RunOptions raise {
  let content = "Feature: Portable\n  Scenario: Parsed\n    Given pass\n"
  let document = @gherkin.parse(
    @gherkin.Source::from_string(content, uri="unreadable/parsed.feature"),
  )
  guard document.feature is Some(feature) else {
    fail("missing parsed feature")
  }
  @moonspec.RunOptions([
    @moonspec.FeatureSource::Text(
      "unreadable/text.feature", "Feature: Portable\n  Scenario: Text\n    Given pass\n",
    ),
    @moonspec.FeatureSource::Parsed("unreadable/parsed.feature", feature),
  ])
}

///|
pub fn portable_world() -> CompatWorld {
  CompatWorld::{
    counter: 0,
    attempts: Map([]),
    hook_log: [],
    with_hooks: false,
  }
}

///|
pub fn verify_report(label : String, report : String) -> Unit raise {
  let fragments = match label {
    "outcomes" =>
      [
        "1 failed", "1 undefined", "1 pending", "Failed", "Undefined", "Pending",
        "expected failure", "not implemented", "missing definition", "s.given", "fixtures/outcomes.feature:",
      ]
    "retries-isolation" =>
      ["Exhausted", "expected failure", "fixtures/retries-isolation.feature:"]
    "dry-run" =>
      [
        "Undefined", "missing definition", "s.given", "fixtures/outcomes.feature:",
      ]
    "parse-error" => ["fixtures/invalid.feature:1", "Feature:"]
    "hooks" => ["Hook failure", "expected failure", "fixtures/hooks.feature:"]
    _ => []
  }
  if fragments.is_empty() {
    assert_eq(report, "")
  } else {
    for fragment in fragments {
      assert_true(
        report.contains(fragment),
        msg=label + ": missing " + fragment + " in " + report,
      )
    }
  }
}

///|
pub extend CompatWorld with @moonspec.World::{configure}

///|
pub suberror ConfigureFailure {
  ConfigureFailure
}

///|
pub struct ConfigureWorld {
  ordinal : Int32
  fail_at : Int32
}

///|
pub impl @moonspec.World for ConfigureWorld with fn configure(self, setup) {
  if self.ordinal == self.fail_at {
    raise ConfigureFailure
  }
  setup.given("fail", fn(_ctx) raise { raise Failure("retry") })
}

///|
pub extend ConfigureWorld with @moonspec.World::{configure}

///|
pub fn configure_world(ordinal : Int32, fail_at : Int32) -> ConfigureWorld {
  ConfigureWorld::{ ordinal, fail_at, }
}

///|
pub fn configure_options() -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions([
    @moonspec.FeatureSource::Text(
      "configure.feature", "Feature: Configure\n  Scenario: Retry\n    Given fail\n",
    ),
  ])
  options.retries(3)
  options
}
