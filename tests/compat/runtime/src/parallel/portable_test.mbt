///|
async test "Text and Parsed execute without feature filesystem access" {
  let options = @shared.portable_options()
  options.parallel(true)
  options.max_concurrent(2)
  let result = @moonspec.run(() => @shared.portable_world(), options)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.features[0].scenarios[0].scenario_name, "Text")
  assert_eq(result.features[1].scenarios[0].scenario_name, "Parsed")
  @moonspec.run_or_fail(() => @shared.portable_world(), options)
}
