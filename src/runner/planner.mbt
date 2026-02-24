///|
/// ID generator for test planning.
pub(all) struct IdGenerator {
  priv mut counter : Int
}

///|
pub fn IdGenerator::new() -> IdGenerator {
  { counter: 0 }
}

///|
pub fn IdGenerator::next(self : IdGenerator, prefix : String) -> String {
  self.counter += 1
  prefix + "-" + self.counter.to_string()
}

///|
pub fn IdGenerator::next_param_type_id(self : IdGenerator) -> String {
  self.next("pt")
}

///|
pub fn IdGenerator::next_hook_id(self : IdGenerator) -> String {
  self.next("hook")
}

///|
/// Build TestCase envelopes by matching pickle steps against a shared registry.
pub fn build_test_cases(
  registry : @core.StepRegistry,
  hook_registry : @core.HookRegistry,
  pickles : Array[@cucumber_messages.Pickle],
  id_gen : IdGenerator,
) -> Array[@cucumber_messages.Envelope] {
  let before_case_hooks = hook_registry.by_type(@core.HookType::BeforeTestCase)
  let after_case_hooks = hook_registry.by_type(@core.HookType::AfterTestCase)
  let envelopes : Array[@cucumber_messages.Envelope] = []
  for pickle in pickles {
    let test_steps : Array[Json] = []
    // Prepend before_test_case hook steps
    for hook in before_case_hooks {
      let step_id = id_gen.next("ts")
      test_steps.push({ "id": step_id.to_json(), "hookId": hook.id.to_json() })
    }
    for step in pickle.steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let step_def_ids : Array[Json] = match
        registry.find_match(step.text, keyword~) {
        Matched(def, _) =>
          match def.id {
            Some(id) => [id.to_string().to_json()]
            None => []
          }
        Undefined(..) => []
      }
      let step_id = id_gen.next("ts")
      test_steps.push({
        "id": step_id.to_json(),
        "pickleStepId": step.id.to_json(),
        "stepDefinitionIds": step_def_ids.to_json(),
      })
    }
    // Append after_test_case hook steps
    for hook in after_case_hooks {
      let step_id = id_gen.next("ts")
      test_steps.push({ "id": step_id.to_json(), "hookId": hook.id.to_json() })
    }
    let tc_id = id_gen.next("tc")
    let json : Json = {
      "testCase": {
        "id": tc_id.to_json(),
        "pickleId": pickle.id.to_json(),
        "testSteps": test_steps.to_json(),
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
      _ => continue
    }
    envelopes.push(envelope)
  }
  envelopes
}

///|
/// Build StepDefinition envelopes from the shared registry.
pub fn build_step_definition_envelopes(
  registry : @core.StepRegistry,
) -> Array[@cucumber_messages.Envelope] {
  let envelopes : Array[@cucumber_messages.Envelope] = []
  for step_def in registry.step_defs() {
    let id = match step_def.id {
      Some(id) => id.to_string()
      None => continue
    }
    let source_ref : Map[String, Json] = {}
    match step_def.source {
      Some(src) => {
        match src.uri {
          Some(uri) => source_ref["uri"] = uri.to_json()
          None => ()
        }
        match src.line {
          Some(line) => source_ref["location"] = { "line": line.to_json() }
          None => ()
        }
      }
      None => ()
    }
    let json : Json = {
      "stepDefinition": {
        "id": id.to_json(),
        "pattern": {
          "source": step_def.pattern.to_json(),
          "type": "CUCUMBER_EXPRESSION".to_json(),
        },
        "sourceReference": source_ref.to_json(),
      },
    }
    let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
      _ => continue
    }
    envelopes.push(envelope)
  }
  envelopes
}
