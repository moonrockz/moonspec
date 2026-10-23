///|
async test "one opaque shared World and fresh options execute" {
  let result = @moonspec.run(@shared.world, @shared.options())
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
