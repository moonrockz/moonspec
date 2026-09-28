///|
/// Runs the Markdown with Gherkin version of the calculator feature.
async test "Feature: Calculator (Markdown with Gherkin)" {
  let options = @moonspec.RunOptions([
    @moonspec.FeatureSource::File("features/calculator.feature.md"),
  ])
  let result = @moonspec.run(CalcWorld::default, options)
  assert_eq(result.summary.total_scenarios, 4)
  assert_eq(result.summary.passed, 4)
}
