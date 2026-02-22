///|
/// Execute all scenarios in a feature, given its content as a string.
pub fn execute_feature(
  registry : @core.StepRegistry,
  content : String,
) -> FeatureResult raise Error {
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  let feature = match doc.feature {
    Some(f) => f
    None => return { name: "(empty)", scenarios: [], duration_ms: 0L }
  }
  let scenario_results : Array[ScenarioResult] = []
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Scenario(scenario) => {
        let steps = scenario.steps.map(fn(s) { (s.keyword, s.text) })
        let tags = scenario.tags.map(fn(t) { t.name })
        let result = execute_scenario(
          registry,
          feature_name=feature.name,
          scenario_name=scenario.name,
          tags~,
          steps~,
        )
        scenario_results.push(result)
      }
      _ => () // Background, Rule handled later
    }
  }
  { name: feature.name, scenarios: scenario_results, duration_ms: 0L }
}
