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
/// Build TestCase envelopes by matching pickle steps against the registry.
pub fn[W : @core.World] build_test_cases(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  id_gen : IdGenerator,
) -> Array[@cucumber_messages.Envelope] {
  // Create a throwaway world to build the registry for step matching
  let world = factory()
  let registry = @core.StepRegistry::new()
  @core.World::register_steps(world, registry)
  let envelopes : Array[@cucumber_messages.Envelope] = []
  for pickle in pickles {
    let test_steps : Array[Json] = []
    for step in pickle.steps {
      let keyword = match step.type_ {
        Some(@cucumber_messages.PickleStepType::Context) => "Given "
        Some(@cucumber_messages.PickleStepType::Action) => "When "
        Some(@cucumber_messages.PickleStepType::Outcome) => "Then "
        _ => "* "
      }
      let step_def_ids : Array[Json] = match registry.find_match(step.text, keyword~) {
        Matched(_, _) => []  // We don't have stable IDs for step defs yet
        Undefined(..) => []
      }
      let step_id = id_gen.next("ts")
      test_steps.push(
        {
          "id": step_id.to_json(),
          "pickleStepId": step.id.to_json(),
          "stepDefinitionIds": step_def_ids.to_json(),
        },
      )
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
