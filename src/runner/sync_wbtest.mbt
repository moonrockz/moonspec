///|
struct SyncTestWorld {} derive(Default)

///|
pub extend SyncTestWorld with Default::{default}

///|
impl @core.World for SyncTestWorld with fn configure(_self, setup) {
  setup.given("a step", fn(_ctx) {  })
  setup.given("fail", fn(_ctx) raise { raise Failure("sync failure") })
  setup.given("pending", fn(_ctx) raise {
    raise @core.pending_step_error(
      step="pending",
      keyword="Given ",
      message="later",
    )
  })
  setup.given("a byte of {byte}", fn(_ctx) {  })
}

///|
test "sync ordinary test executes a passing scenario without an event loop" {
  let result = run_sync(
    SyncTestWorld::default,
    RunOptions([
      FeatureSource::Text(
        "sync.feature", "Feature: Sync\n  Scenario: Pass\n    Given a step\n",
      ),
    ]),
  )
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}

///|
test "sync rejects parallel before factory and message effects" {
  let factories = Ref(0)
  let sink = CollectorSink::new()
  let options = RunOptions([])
  options.parallel(true)
  options.add_sink(sink)
  let rejected = try {
    let _ = run_sync(
      fn() {
        factories.val += 1
        SyncTestWorld::default()
      },
      options,
    )
    false
  } catch {
    SyncExecutionError::ParallelNotSupported => true
    _ => false
  }
  assert_true(rejected)
  assert_eq(factories.val, 0)
  assert_eq(sink.envelopes.length(), 0)
}

///|
test "sync run_or_fail reports undefined steps with scenario location" {
  let options = RunOptions([
    FeatureSource::Text(
      "undefined.feature", "Feature: Sync\n  Scenario: Missing\n    Given absent\n",
    ),
  ])
  options.no_color(true)
  let report = try {
    run_or_fail_sync(SyncTestWorld::default, options)
    ""
  } catch {
    @core.RunFailed(..) as error => error.to_string()
    error => fail("unexpected error: " + error.to_string())
  }
  assert_true(report.contains("Missing"))
  assert_true(report.contains("undefined.feature:2"))
  assert_true(report.contains("absent"))
  assert_true(report.contains("1 undefined"))
}

///|
test "sync formatter file write failure raises a typed host diagnostic" {
  let options = RunOptions([
    FeatureSource::Text(
      "output.feature", "Feature: Output\n  Scenario: Pass\n    Given a step\n",
    ),
  ])
  let path = "/moonspec-missing-directory/output.ndjson"
  options.add_formatter(@format.MessagesFormatter::new(), File(path))
  let rejected = try {
    let _ = run_sync(SyncTestWorld::default, options)
    false
  } catch {
    SyncExecutionError::HostIoFailed(operation~, path=actual, message~) => {
      assert_eq(operation, "write")
      assert_eq(actual, path)
      assert_true(message.length() > 0)
      true
    }
    _ => false
  }
  assert_true(rejected)
}

///|
test "sync dry-run decoder failure never advertises a retry" {
  let sink = CollectorSink::new()
  let options = RunOptions([
    FeatureSource::Text(
      "dry.feature", "Feature: Dry\n  Scenario: Bad byte\n    Given a byte of 256\n",
    ),
  ])
  options.dry_run(true)
  options.retries(3)
  options.add_sink(sink)
  let result = run_sync(SyncTestWorld::default, options)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.summary.retried, 0)
  let finished = sink.envelopes.filter(fn(env) {
    env is @cucumber_messages.Envelope::TestCaseFinished(_)
  })
  assert_eq(finished.length(), 1)
  for envelope in finished {
    if envelope is @cucumber_messages.Envelope::TestCaseFinished(event) {
      assert_eq(event.willBeRetried, false)
    }
  }
}

///|
struct SyncObservedWorld {
  attempts : Ref[Int32]
  log : Array[String]
  fail_until : Int32
  mut touched : Bool
}

///|
impl @core.World for SyncObservedWorld with fn configure(self, setup) {
  setup.before_test_run(ctx => {
    self.log.push("before run")
    ctx.attach("run attachment", "text/plain")
  })
  setup.after_test_run(fn(_ctx, result) {
    self.log.push(
      match result {
        @core.HookResult::Passed => "after run passed"
        @core.HookResult::Failed(_) => "after run failed"
      },
    )
  })
  setup.before_test_case(ctx => {
    self.log.push("before case")
    ctx.attach("case attachment", "text/plain")
  })
  setup.after_test_case(fn(_ctx, result) {
    self.log.push(
      match result {
        @core.HookResult::Passed => "after case passed"
        @core.HookResult::Failed(_) => "after case failed"
      },
    )
  })
  setup.before_test_step(fn(_ctx) { self.log.push("before step") })
  setup.after_test_step(fn(ctx, _result) {
    self.log.push("after step")
    ctx.attach("step hook attachment", "text/plain")
  })
  setup.given("a fresh attempt", fn(ctx) raise {
    assert_false(self.touched)
    self.touched = true
    self.attempts.val += 1
    self.log.push("step")
    if self.attempts.val <= self.fail_until {
      raise Failure("retry me")
    }
    ctx.attach("step attachment", "text/plain")
  })
}

///|
test "sync retry uses fresh worlds and registries with ordered attempt events" {
  let attempts = Ref(0)
  let factories = Ref(0)
  let log : Array[String] = []
  let sink = CollectorSink::new()
  let options = RunOptions([
    FeatureSource::Text(
      "retry.feature", "Feature: Retry\n  @retry(1)\n  Scenario: Flaky\n    Given a fresh attempt\n",
    ),
  ])
  options.retries(0)
  options.max_concurrent(-1)
  options.add_sink(sink)
  let result = run_sync(
    fn() {
      factories.val += 1
      SyncObservedWorld::{ attempts, log, fail_until: 1, touched: false, }
    },
    options,
  )
  assert_eq(result.summary.passed, 1)
  assert_eq(result.summary.failed, 0)
  assert_eq(result.summary.retried, 1)
  assert_eq(attempts.val, 2)
  assert_eq(factories.val, 3)
  assert_eq(log, [
    "before run", "before case", "before step", "step", "after step", "after case failed",
    "before case", "before step", "step", "after step", "after case passed", "after run passed",
  ])
  let started : Array[Int32] = []
  let finished : Array[Bool] = []
  let attachments : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::TestCaseStarted(event) =>
        started.push(event.attempt)
      @cucumber_messages.Envelope::TestCaseFinished(event) =>
        finished.push(event.willBeRetried)
      @cucumber_messages.Envelope::Attachment(event) =>
        attachments.push(event.body)
      _ => ()
    }
  }
  assert_eq(started, [0, 1])
  assert_eq(finished, [true, false])
  assert_eq(attachments, [
    "run attachment", "case attachment", "step hook attachment", "case attachment",
    "step attachment", "step hook attachment",
  ])
}

///|
test "sync retries failed scenarios only and counts final results" {
  let cases : Array[(String, String, ScenarioStatus, Int32, Int32)] = [
    ("", "fail", Failed, 4, 1),
    ("", "absent", Undefined, 1, 0),
    ("", "pending", Pending, 1, 0),
    ("@skip", "fail", Skipped(Some("skip")), 1, 0),
  ]
  for (tag, step, expected, attempts, retried) in cases {
    let sink = CollectorSink::new()
    let options = RunOptions([
      FeatureSource::Text(
        "status.feature",
        "Feature: Status\n  " +
        tag +
        "\n  Scenario: One\n    Given " +
        step +
        "\n",
      ),
    ])
    options.retries(3)
    options.add_sink(sink)
    let result = run_sync(SyncTestWorld::default, options)
    let actual = result.features[0].scenarios[0].status
    assert_eq(actual, expected)
    assert_eq(result.summary.total_scenarios, 1)
    assert_eq(result.summary.retried, retried)
    assert_eq(
      sink.envelopes
      .filter(fn(env) { env is @cucumber_messages.Envelope::TestCaseStarted(_) })
      .length(),
      attempts,
    )
  }
}

///|
test "sync zero retry tag overrides global retries" {
  let attempts = Ref(0)
  let log : Array[String] = []
  let options = RunOptions([
    FeatureSource::Text(
      "zero.feature", "Feature: Zero\n  @retry(0)\n  Scenario: Fail\n    Given a fresh attempt\n",
    ),
  ])
  options.retries(5)
  let result = run_sync(
    fn() {
      SyncObservedWorld::{ attempts, log, fail_until: 9, touched: false, }
    },
    options,
  )
  assert_eq(attempts.val, 1)
  assert_eq(result.summary.failed, 1)
  assert_eq(result.summary.retried, 0)
  assert_eq(log.last(), Some("after run failed"))
}

///|
test "sync dry-run keeps run hooks while skip tags take precedence" {
  for tag in ["", "@skip"] {
    let attempts = Ref(0)
    let log : Array[String] = []
    let options = RunOptions([
      FeatureSource::Text(
        "dry-hooks.feature",
        "Feature: Dry hooks\n  " +
        tag +
        "\n  Scenario: One\n    Given a fresh attempt\n",
      ),
    ])
    options.dry_run(true)
    options.retries(3)
    let result = run_sync(
      fn() {
        SyncObservedWorld::{ attempts, log, fail_until: 9, touched: false, }
      },
      options,
    )
    assert_eq(attempts.val, 0)
    assert_eq(result.summary.skipped, 1)
    assert_eq(result.summary.retried, 0)
    assert_eq(log, ["before run", "after run failed"])
    let status = result.features[0].scenarios[0].steps[0].status
    match status {
      Skipped(Some(reason)) =>
        if tag == "" {
          assert_eq(reason, "dry run")
        } else {
          assert_eq(reason, "skip")
        }
      _ => fail("expected skip reason")
    }
  }
}

///|
priv suberror SyncConfigureFailure {
  SyncConfigureFailure
}

///|
struct SyncConfigureWorld {
  ordinal : Int32
  fail_at : Int32
}

///|
impl @core.World for SyncConfigureWorld with fn configure(self, setup) {
  if self.ordinal == self.fail_at {
    raise SyncConfigureFailure
  }
  setup.given("fail", fn(_ctx) raise { raise Failure("retry") })
}

///|
test "sync preserves configure errors during preparation and retries" {
  for fail_at in [0, 1, 2] {
    let factories = Ref(0)
    let options = RunOptions([
      FeatureSource::Text(
        "configure.feature", "Feature: Configure\n  Scenario: Retry\n    Given fail\n",
      ),
    ])
    options.retries(3)
    let rejected = try {
      let _ = run_sync(
        fn() {
          let ordinal = factories.val
          factories.val += 1
          SyncConfigureWorld::{ ordinal, fail_at, }
        },
        options,
      )
      false
    } catch {
      SyncConfigureFailure => true
      _ => false
    }
    assert_true(rejected)
    assert_eq(factories.val, fail_at + 1)
  }
}

///|
test "sync continues valid sources and reports parse and file read failures" {
  let sink = CollectorSink::new()
  let options = RunOptions([
    FeatureSource::Text("bad.feature", "Not valid Gherkin"),
    FeatureSource::File("/moonspec-missing-directory/input.feature"),
    FeatureSource::Text(
      "valid.feature", "Feature: Valid\n  Scenario: Pass\n    Given a step\n",
    ),
  ])
  options.add_sink(sink)
  options.no_color(true)
  let result = run_sync(SyncTestWorld::default, options)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.parse_errors.length(), 2)
  assert_eq(result.parse_errors[0].uri, "bad.feature")
  assert_eq(result.parse_errors[0].line, Some(1))
  assert_eq(
    sink.envelopes
    .filter(fn(env) { env is @cucumber_messages.Envelope::ParseError(_) })
    .length(),
    2,
  )
  let report = try {
    run_or_fail_sync(SyncTestWorld::default, options)
    ""
  } catch {
    @core.RunFailed(..) as error => error.to_string()
    error => fail("unexpected error: " + error.to_string())
  }
  assert_true(report.contains("2 parse errors"))
  assert_true(report.contains("bad.feature:1"))
  assert_true(report.contains("/moonspec-missing-directory/input.feature"))
}

///|
struct SyncParameterWorld {
  mut background_ran : Bool
}

///|
impl @core.World for SyncParameterWorld with fn configure(self, setup) {
  let answer = setup.define_param_type1("answer", ["forty-two"], fn(_s) { 42 })
  setup.given("a step", fn(_ctx) { self.background_ran = true })
  setup.then("the answer is {answer}", fn(ctx) raise {
    assert_true(self.background_ran)
    assert_eq(ctx[0].get(answer), 42)
  })
}

///|
test "sync filters outlines and preserves backgrounds and custom parameter types" {
  let content =
    #|Feature: Answers
    #|  Background:
    #|    Given a step
    #|  @keep
    #|  Scenario Outline: Chosen
    #|    Then the answer is <answer>
    #|    Examples:
    #|      | answer    |
    #|      | forty-two |
    #|      | forty-two |
    #|  @drop
    #|  Scenario: Chosen but excluded
    #|    Given fail
    #|  @keep
    #|  Scenario: Other
    #|    Given fail
  let options = RunOptions([FeatureSource::Text("answers.feature", content)])
  options.tag_expr("@keep")
  options.scenario_name("Chosen (answer=forty-two)")
  let result = run_sync(
    fn() { SyncParameterWorld::{ background_ran: false, } },
    options,
  )
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.features[0].scenarios[0].steps.length(), 2)
  assert_eq(result.features[0].scenarios[1].steps.length(), 2)
}

///|
test "sync accepts Markdown and parsed sources in feature order" {
  let document = @gherkin.parse(
    @gherkin.Source::from_string(
      "Feature: Parsed\n  Scenario: Second\n    Given a step\n",
      uri="parsed.feature",
    ),
  )
  guard document.feature is Some(feature) else { fail("expected feature") }
  let options = RunOptions([
    FeatureSource::Text(
      "first.feature.md", "# Feature: Markdown\n\n## Scenario: First\n\n- Given a step\n",
    ),
    FeatureSource::Parsed("parsed.feature", feature),
  ])
  let result = run_sync(SyncTestWorld::default, options)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.features[0].name, "Markdown")
  assert_eq(result.features[0].scenarios[0].scenario_name, "First")
  assert_eq(result.features[1].name, "Parsed")
  assert_eq(result.features[1].scenarios[0].scenario_name, "Second")
  run_or_fail_sync(SyncTestWorld::default, options)
}

///|
test "sync run_or_fail includes failed and pending diagnostics" {
  for
    (step, summary, detail) in [
      ("fail", "1 failed", "sync failure"),
      ("pending", "1 pending", "later"),
    ] {
    let options = RunOptions([
      FeatureSource::Text(
        "problem.feature",
        "Feature: Problem\n  Scenario: Context\n    Given a step\n    And " +
        step +
        "\n    Then a step\n",
      ),
    ])
    options.no_color(true)
    let report = try {
      run_or_fail_sync(SyncTestWorld::default, options)
      ""
    } catch {
      @core.RunFailed(..) as error => error.to_string()
      error => fail("unexpected error: " + error.to_string())
    }
    assert_true(report.contains(summary))
    assert_true(report.contains(detail))
    assert_true(report.contains("Context"))
    assert_true(report.contains("problem.feature:2"))
    assert_true(report.contains("a step"))
  }
}

///|
struct SyncFailingRunHooksWorld {}

///|
impl @core.World for SyncFailingRunHooksWorld with fn configure(_self, setup) {
  setup.before_test_run(fn(ctx) raise {
    ctx.attach("before failure", "text/plain")
    raise Failure("before hook")
  })
  setup.after_test_run(fn(ctx, _result) raise {
    ctx.attach("after failure", "text/plain")
    raise Failure("after hook")
  })
  setup.given("a step", fn(_ctx) {  })
}

///|
test "sync run hook failures keep scenario outcomes and emit failed hook events" {
  let sink = CollectorSink::new()
  let options = RunOptions([
    FeatureSource::Text(
      "hook-failures.feature", "Feature: Hooks\n  Scenario: Pass\n    Given a step\n",
    ),
  ])
  options.add_sink(sink)
  run_or_fail_sync(fn() { SyncFailingRunHooksWorld::{ } }, options)
  let mut hook_failures = 0
  let attachments : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::TestRunHookFinished(event) => {
        assert_true(
          event.result.status is @cucumber_messages.TestStepResultStatus::Failed,
        )
        hook_failures += 1
      }
      @cucumber_messages.Envelope::Attachment(event) =>
        attachments.push(event.body)
      _ => ()
    }
  }
  assert_eq(hook_failures, 2)
  assert_eq(attachments, ["before failure", "after failure"])
}

///|
test "sync dry-run regular step events reference planned step IDs after case hooks" {
  let sink = CollectorSink::new()
  let options = RunOptions([
    FeatureSource::Text(
      "dry-step-ids.feature", "Feature: IDs\n  Scenario: Dry\n    Given a fresh attempt\n",
    ),
  ])
  options.dry_run(true)
  options.add_sink(sink)
  let _ = run_sync(
    fn() {
      SyncObservedWorld::{
        attempts: Ref(0),
        log: [],
        fail_until: 0,
        touched: false,
      }
    },
    options,
  )
  let planned : Array[String] = []
  let started : Array[String] = []
  let finished : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::TestCase(event) =>
        for step in event.testSteps {
          if step.pickleStepId is Some(_) {
            planned.push(step.id)
          }
        }
      @cucumber_messages.Envelope::TestStepStarted(event) =>
        started.push(event.testStepId)
      @cucumber_messages.Envelope::TestStepFinished(event) =>
        finished.push(event.testStepId)
      _ => ()
    }
  }
  assert_eq(planned.length(), 1)
  assert_eq(started, planned)
  assert_eq(finished, planned)
}

///|
test "sync skipped tags emit regular planned IDs without scenario effects" {
  let sink = CollectorSink::new()
  let attempts = Ref(0)
  let factories = Ref(0)
  let log : Array[String] = []
  let options = RunOptions([
    FeatureSource::Text(
      "skip-step-ids.feature", "Feature: IDs\n  @skip\n  Scenario: Skipped\n    Given a fresh attempt\n",
    ),
  ])
  options.add_sink(sink)
  let result = run_sync(
    fn() {
      factories.val += 1
      SyncObservedWorld::{ attempts, log, fail_until: 0, touched: false, }
    },
    options,
  )
  assert_eq(result.summary.skipped, 1)
  assert_eq(factories.val, 1)
  assert_eq(attempts.val, 0)
  assert_eq(log, ["before run", "after run failed"])
  let planned : Array[String] = []
  let started : Array[String] = []
  let finished : Array[String] = []
  for envelope in sink.envelopes {
    match envelope {
      @cucumber_messages.Envelope::TestCase(event) =>
        for step in event.testSteps {
          if step.pickleStepId is Some(_) {
            planned.push(step.id)
          }
        }
      @cucumber_messages.Envelope::TestStepStarted(event) =>
        started.push(event.testStepId)
      @cucumber_messages.Envelope::TestStepFinished(event) =>
        finished.push(event.testStepId)
      _ => ()
    }
  }
  assert_eq(planned.length(), 1)
  assert_eq(started, planned)
  assert_eq(finished, planned)
}
