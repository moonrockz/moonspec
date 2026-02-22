///|
/// Simple counter for generating unique IDs.
priv struct IdCounter {
  mut pickle_count : Int
  mut step_count : Int
}

///|
fn IdCounter::new() -> IdCounter {
  { pickle_count: 0, step_count: 0 }
}

///|
fn IdCounter::next_pickle_id(self : IdCounter) -> String {
  let id = "pickle-" + self.pickle_count.to_string()
  self.pickle_count += 1
  id
}

///|
fn IdCounter::next_step_id(self : IdCounter) -> String {
  let id = "step-" + self.step_count.to_string()
  self.step_count += 1
  id
}

///|
/// Replace all occurrences of `old` with `new_val` in `s`.
/// Named differently from the one in outline.mbt to avoid collision.
fn string_replace_compiler(
  s : String,
  old : String,
  new_val : String,
) -> String {
  let buf = StringBuilder::new()
  let s_len = s.length()
  let old_len = old.length()
  if old_len == 0 {
    return s
  }
  let mut i = 0
  while i < s_len {
    if i + old_len <= s_len {
      let mut matches = true
      for j = 0; j < old_len; j = j + 1 {
        if s[i + j] != old[j] {
          matches = false
          break
        }
      }
      if matches {
        buf.write_string(new_val)
        i = i + old_len
        continue
      }
    }
    buf.write_char(s[i].to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}

///|
/// Map a gherkin KeywordType to a PickleStepType option.
fn map_keyword_type(
  kt : @gherkin.KeywordType,
) -> @cucumber_messages.PickleStepType? {
  match kt {
    Context => Some(@cucumber_messages.PickleStepType::Context)
    Action => Some(@cucumber_messages.PickleStepType::Action)
    Outcome => Some(@cucumber_messages.PickleStepType::Outcome)
    Conjunction => None
    Unknown => Some(@cucumber_messages.PickleStepType::Unknown)
  }
}

///|
/// Convert gherkin tags to pickle tags.
fn compile_tags(
  tags : Array[@gherkin.Tag],
) -> Array[@cucumber_messages.PickleTag] {
  let result : Array[@cucumber_messages.PickleTag] = []
  for tag in tags {
    result.push({ name: tag.name, astNodeId: tag.id })
  }
  result
}

///|
/// Compile a single gherkin step into a pickle step, applying placeholder
/// substitution if headers/values are provided (for scenario outlines).
fn compile_step(
  step : @gherkin.Step,
  ids : IdCounter,
  last_type : @cucumber_messages.PickleStepType?,
  headers : Array[String],
  values : Array[String],
) -> (@cucumber_messages.PickleStep, @cucumber_messages.PickleStepType?) {
  let mapped = map_keyword_type(step.keyword_type)
  let effective_type = match mapped {
    Some(t) => Some(t)
    None => last_type
  }
  let mut text = step.text
  for i = 0; i < headers.length(); i = i + 1 {
    text = string_replace_compiler(text, "<" + headers[i] + ">", values[i])
  }
  let pickle_step : @cucumber_messages.PickleStep = {
    id: ids.next_step_id(),
    text,
    astNodeIds: [step.id],
    type_: effective_type,
    argument: None,
  }
  (pickle_step, effective_type)
}

///|
/// Compile steps from an array of gherkin steps, tracking the last keyword type
/// for Conjunction resolution.
fn compile_steps(
  steps : Array[@gherkin.Step],
  ids : IdCounter,
  last_type : @cucumber_messages.PickleStepType?,
  headers : Array[String],
  values : Array[String],
) -> (Array[@cucumber_messages.PickleStep], @cucumber_messages.PickleStepType?) {
  let result : Array[@cucumber_messages.PickleStep] = []
  let mut current_type = last_type
  for step in steps {
    let (ps, new_type) = compile_step(step, ids, current_type, headers, values)
    result.push(ps)
    current_type = new_type
  }
  (result, current_type)
}

///|
/// Compile a regular scenario (not an outline) into a single pickle.
fn compile_scenario(
  scenario : @gherkin.Scenario,
  uri : String,
  language : String,
  feature_tags : Array[@gherkin.Tag],
  background_steps : Array[@gherkin.Step],
  ids : IdCounter,
) -> @cucumber_messages.Pickle? {
  // Empty scenario with no background steps produces no pickle
  if scenario.steps.is_empty() && background_steps.is_empty() {
    return None
  }
  let all_tags : Array[@gherkin.Tag] = []
  all_tags.append(feature_tags)
  all_tags.append(scenario.tags)
  let empty_headers : Array[String] = []
  let empty_values : Array[String] = []
  let (bg_steps, last_type) = compile_steps(
    background_steps,
    ids,
    None,
    empty_headers,
    empty_values,
  )
  let (sc_steps, _) = compile_steps(
    scenario.steps,
    ids,
    last_type,
    empty_headers,
    empty_values,
  )
  let all_steps : Array[@cucumber_messages.PickleStep] = []
  all_steps.append(bg_steps)
  all_steps.append(sc_steps)
  let pickle : @cucumber_messages.Pickle = {
    id: ids.next_pickle_id(),
    uri,
    name: scenario.name,
    language,
    steps: all_steps,
    tags: compile_tags(all_tags),
    astNodeIds: [scenario.id],
    location: None,
  }
  Some(pickle)
}

///|
/// Compile a scenario outline with examples into multiple pickles.
fn compile_outline(
  scenario : @gherkin.Scenario,
  uri : String,
  language : String,
  feature_tags : Array[@gherkin.Tag],
  background_steps : Array[@gherkin.Step],
  ids : IdCounter,
) -> Array[@cucumber_messages.Pickle] {
  let pickles : Array[@cucumber_messages.Pickle] = []
  for examples in scenario.examples {
    let all_tags : Array[@gherkin.Tag] = []
    all_tags.append(feature_tags)
    all_tags.append(scenario.tags)
    all_tags.append(examples.tags)
    let headers : Array[String] = match examples.table_header {
      Some(header) => header.cells.map(fn(c) { c.value })
      None => []
    }
    for row in examples.table_body {
      let values = row.cells.map(fn(c) { c.value })
      // Build scenario name with parameter suffix
      let params : Array[String] = []
      for i = 0; i < headers.length(); i = i + 1 {
        params.push(headers[i] + "=" + values[i])
      }
      let name = scenario.name + " (" + params.join(", ") + ")"
      let (bg_steps, last_type) = compile_steps(
        background_steps,
        ids,
        None,
        headers,
        values,
      )
      let (sc_steps, _) = compile_steps(
        scenario.steps,
        ids,
        last_type,
        headers,
        values,
      )
      let all_steps : Array[@cucumber_messages.PickleStep] = []
      all_steps.append(bg_steps)
      all_steps.append(sc_steps)
      let pickle : @cucumber_messages.Pickle = {
        id: ids.next_pickle_id(),
        uri,
        name,
        language,
        steps: all_steps,
        tags: compile_tags(all_tags),
        astNodeIds: [scenario.id, row.id],
        location: None,
      }
      pickles.push(pickle)
    }
  }
  pickles
}

///|
/// Process a scenario — dispatch to regular or outline compilation.
fn process_scenario(
  scenario : @gherkin.Scenario,
  uri : String,
  language : String,
  feature_tags : Array[@gherkin.Tag],
  background_steps : Array[@gherkin.Step],
  ids : IdCounter,
  pickles : Array[@cucumber_messages.Pickle],
) -> Unit {
  if scenario.examples.is_empty() {
    match
      compile_scenario(
        scenario, uri, language, feature_tags, background_steps, ids,
      ) {
      Some(p) => pickles.push(p)
      None => ()
    }
  } else {
    let outline_pickles = compile_outline(
      scenario, uri, language, feature_tags, background_steps, ids,
    )
    pickles.append(outline_pickles)
  }
}

///|
/// Compile a single feature into pickles.
fn compile_feature(
  uri : String,
  feature : @gherkin.Feature,
  ids : IdCounter,
) -> Array[@cucumber_messages.Pickle] {
  let pickles : Array[@cucumber_messages.Pickle] = []
  // Collect feature-level background
  let feature_bg_steps : Array[@gherkin.Step] = []
  for child in feature.children {
    match child {
      Background(bg) => {
        feature_bg_steps.clear()
        feature_bg_steps.append(bg.steps)
      }
      Scenario(scenario) =>
        process_scenario(
          scenario,
          uri,
          feature.language,
          feature.tags,
          feature_bg_steps,
          ids,
          pickles,
        )
      Rule(rule) => {
        // Rule-scoped background = feature bg + rule bg
        let rule_bg_steps : Array[@gherkin.Step] = []
        rule_bg_steps.append(feature_bg_steps)
        // Merge tags: feature + rule
        let rule_tags : Array[@gherkin.Tag] = []
        rule_tags.append(feature.tags)
        rule_tags.append(rule.tags)
        for rule_child in rule.children {
          match rule_child {
            Background(bg) => {
              // Reset rule bg to feature bg + this rule background
              rule_bg_steps.clear()
              rule_bg_steps.append(feature_bg_steps)
              rule_bg_steps.append(bg.steps)
            }
            Scenario(scenario) =>
              process_scenario(
                scenario,
                uri,
                feature.language,
                rule_tags,
                rule_bg_steps,
                ids,
                pickles,
              )
          }
        }
      }
    }
  }
  pickles
}

///|
/// Compile all cached features into Pickle instances.
/// This is the main entry point for the pickle compiler.
pub fn compile_pickles(
  cache : FeatureCache,
) -> Array[@cucumber_messages.Pickle] {
  let ids = IdCounter::new()
  let all_pickles : Array[@cucumber_messages.Pickle] = []
  for entry in cache.features() {
    let (uri, feature) = entry
    let pickles = compile_feature(uri, feature, ids)
    all_pickles.append(pickles)
  }
  all_pickles
}
