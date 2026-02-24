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
