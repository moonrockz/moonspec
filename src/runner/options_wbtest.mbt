///|
test "RunOptions constructor sets features" {
  let features = [FeatureSource::Text("test://a", "Feature: A\n")]
  let opts = RunOptions(features)
  assert_eq(opts.features().length(), 1)
}

///|
test "RunOptions defaults" {
  let opts = RunOptions([])
  assert_eq(opts.is_parallel(), false)
  assert_eq(opts.get_max_concurrent(), 4)
  assert_eq(opts.get_sinks().length(), 0)
  assert_eq(opts.get_tag_expr(), "")
  assert_eq(opts.get_scenario_name(), "")
}

///|
test "RunOptions builder methods" {
  let collector = CollectorSink::new()
  let opts = RunOptions([])
  opts.parallel(true)
  opts.max_concurrent(8)
  opts.add_sink(collector)
  opts.tag_expr("@smoke")
  opts.scenario_name("My Scenario")
  assert_eq(opts.is_parallel(), true)
  assert_eq(opts.get_max_concurrent(), 8)
  assert_eq(opts.get_sinks().length(), 1)
  assert_eq(opts.get_tag_expr(), "@smoke")
  assert_eq(opts.get_scenario_name(), "My Scenario")
}

///|
test "retries defaults to zero" {
  let opts = RunOptions::new([])
  assert_eq(opts.get_retries(), 0)
}

///|
test "retries can be set" {
  let opts = RunOptions::new([])
  opts.retries(3)
  assert_eq(opts.get_retries(), 3)
}

///|
test "dry_run defaults to false" {
  let opts = RunOptions::new([])
  assert_false(opts.is_dry_run())
}

///|
test "dry_run can be enabled" {
  let opts = RunOptions::new([])
  opts.dry_run(true)
  assert_true(opts.is_dry_run())
}

///|
test "skip_tags defaults to @skip and @ignore" {
  let opts = RunOptions::new([])
  assert_eq(opts.get_skip_tags(), ["@skip", "@ignore"])
}

///|
test "skip_tags can be customized" {
  let opts = RunOptions::new([])
  opts.skip_tags(["@skip", "@wip"])
  assert_eq(opts.get_skip_tags(), ["@skip", "@wip"])
}
