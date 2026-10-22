///|
test "Text and Parsed execute without feature filesystem access" {
  let options = @shared.portable_options()
  let result = @moonspec.run_sync(() => @shared.portable_world(), options)
  assert_eq(result.summary.total_scenarios, 2)
  assert_eq(result.summary.passed, 2)
  assert_eq(result.features[0].scenarios[0].scenario_name, "Text")
  assert_eq(result.features[1].scenarios[0].scenario_name, "Parsed")
  @moonspec.run_or_fail_sync(() => @shared.portable_world(), options)
}
