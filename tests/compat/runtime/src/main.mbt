///|
struct CompatWorld {
  mut counter : Int32
  attempts : Map[String, Int32]
  hook_log : Array[String]
  with_hooks : Bool
}

///|
impl @moonspec.World for CompatWorld with fn configure(self, setup) {
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
async fn run_fixture(label : String, path : String) -> Unit {
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
  let result = @moonspec.run(
    () => CompatWorld::{
      counter: 0,
      attempts,
      hook_log,
      with_hooks: label.has_prefix("hooks"),
    },
    options,
  )
  println(
    "COMPAT:" +
    observation(label, result, messages.output(), hook_log).stringify(),
  )
}

///|
async fn main {
  run_fixture("passing", "fixtures/passing.feature")
  run_fixture("outcomes", "fixtures/outcomes.feature")
  run_fixture("retries-isolation", "fixtures/retries-isolation.feature")
  run_fixture("tag-filter", "fixtures/filtering.feature")
  run_fixture("name-filter", "fixtures/filtering.feature")
  run_fixture("dry-run", "fixtures/outcomes.feature")
  run_fixture("parse-error", "fixtures/invalid.feature")
  run_fixture("hooks", "fixtures/hooks.feature")
  run_fixture("hooks-dry-run", "fixtures/hooks.feature")
}
