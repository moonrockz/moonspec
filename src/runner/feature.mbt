///|
/// Execute all scenarios in a feature, given its content as a string.
/// A fresh world is created per scenario via `factory()`.
pub fn[W : @core.World] execute_feature(
  factory : () -> W,
  content : String,
) -> FeatureResult raise Error {
  execute_feature_filtered(factory, content, tag_expr="")
}

///|
/// Execute a feature with optional tag filtering.
/// A fresh world is created per scenario via `factory()`.
pub fn[W : @core.World] execute_feature_filtered(
  factory : () -> W,
  content : String,
  tag_expr~ : String,
) -> FeatureResult raise Error {
  let tag_filter = TagExpression::parse(tag_expr)
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  let feature = match doc.feature {
    Some(f) => f
    None => return { name: "(empty)", scenarios: [], duration_ms: 0L }
  }
  // First pass: collect background steps
  let background_steps : Array[(String, String)] = []
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Background(bg) =>
        for s in bg.steps {
          background_steps.push((s.keyword, s.text))
        }
      _ => ()
    }
  }
  // Second pass: execute scenarios with fresh world per scenario
  let scenario_results : Array[ScenarioResult] = []
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Scenario(scenario) => {
        let tags = scenario.tags.map(fn(t) { t.name })
        if not(tag_filter.matches(tags)) {
          continue
        }
        if scenario.examples.is_empty() {
          // Regular scenario
          let all_steps = background_steps.copy()
          for s in scenario.steps {
            all_steps.push((s.keyword, s.text))
          }
          let world = factory()
          let registry = @core.StepRegistry::new()
          @core.World::register_steps(world, registry)
          let result = execute_scenario(
            registry,
            feature_name=feature.name,
            scenario_name=scenario.name,
            tags~,
            steps=all_steps,
          )
          scenario_results.push(result)
        } else {
          // Scenario Outline: expand each Examples table
          let template_steps = scenario.steps.map(fn(s) { (s.keyword, s.text) })
          for examples in scenario.examples {
            let headers = match examples.table_header {
              Some(header_row) => header_row.cells.map(fn(c) { c.value })
              None => continue
            }
            let rows = examples.table_body.map(fn(r) {
              r.cells.map(fn(c) { c.value })
            })
            let expanded = expand_outline(
              scenario.name,
              template_steps,
              headers,
              rows,
            )
            for pair in expanded {
              let (expanded_name, expanded_steps) = pair
              let all_steps = background_steps.copy()
              for step in expanded_steps {
                all_steps.push(step)
              }
              let world = factory()
              let registry = @core.StepRegistry::new()
              @core.World::register_steps(world, registry)
              let result = execute_scenario(
                registry,
                feature_name=feature.name,
                scenario_name=expanded_name,
                tags~,
                steps=all_steps,
              )
              scenario_results.push(result)
            }
          }
        }
      }
      _ => () // Rule handled later
    }
  }
  { name: feature.name, scenarios: scenario_results, duration_ms: 0L }
}

///|
/// Execute a feature with lifecycle hooks and optional tag filtering.
/// A fresh world is created per scenario via `factory()`.
pub fn[W : @core.World + @core.Hooks] execute_feature_filtered_with_hooks(
  factory : () -> W,
  content : String,
  tag_expr~ : String,
) -> FeatureResult raise Error {
  let tag_filter = TagExpression::parse(tag_expr)
  let source = @gherkin.Source::from_string(content)
  let doc = @gherkin.parse(source)
  let feature = match doc.feature {
    Some(f) => f
    None => return { name: "(empty)", scenarios: [], duration_ms: 0L }
  }
  let background_steps : Array[(String, String)] = []
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Background(bg) =>
        for s in bg.steps {
          background_steps.push((s.keyword, s.text))
        }
      _ => ()
    }
  }
  let scenario_results : Array[ScenarioResult] = []
  for child in feature.children {
    match child {
      @gherkin.FeatureChild::Scenario(scenario) => {
        let tags = scenario.tags.map(fn(t) { t.name })
        if not(tag_filter.matches(tags)) {
          continue
        }
        if scenario.examples.is_empty() {
          let all_steps = background_steps.copy()
          for s in scenario.steps {
            all_steps.push((s.keyword, s.text))
          }
          let world = factory()
          let registry = @core.StepRegistry::new()
          @core.World::register_steps(world, registry)
          let result = execute_scenario_with_hooks(
            world,
            registry,
            feature_name=feature.name,
            scenario_name=scenario.name,
            tags~,
            steps=all_steps,
          )
          scenario_results.push(result)
        } else {
          let template_steps = scenario.steps.map(fn(s) { (s.keyword, s.text) })
          for examples in scenario.examples {
            let headers = match examples.table_header {
              Some(header_row) => header_row.cells.map(fn(c) { c.value })
              None => continue
            }
            let rows = examples.table_body.map(fn(r) {
              r.cells.map(fn(c) { c.value })
            })
            let expanded = expand_outline(
              scenario.name,
              template_steps,
              headers,
              rows,
            )
            for pair in expanded {
              let (expanded_name, expanded_steps) = pair
              let all_steps = background_steps.copy()
              for step in expanded_steps {
                all_steps.push(step)
              }
              let world = factory()
              let registry = @core.StepRegistry::new()
              @core.World::register_steps(world, registry)
              let result = execute_scenario_with_hooks(
                world,
                registry,
                feature_name=feature.name,
                scenario_name=expanded_name,
                tags~,
                steps=all_steps,
              )
              scenario_results.push(result)
            }
          }
        }
      }
      _ => ()
    }
  }
  { name: feature.name, scenarios: scenario_results, duration_ms: 0L }
}
