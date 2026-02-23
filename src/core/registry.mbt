///|
/// A step handler function that receives extracted arguments.
pub struct StepHandler((Array[StepArg]) -> Unit raise Error)

///|
/// Internal: a compiled step entry pairing a StepDef with its parsed expression.
struct CompiledStep {
  def : StepDef
  expression : @cucumber_expressions.Expression
}

///|
/// Internal: generates sequential StepDefIds.
priv struct IdGenerator {
  mut counter : Int
}

///|
fn IdGenerator::new() -> IdGenerator {
  { counter: 0 }
}

///|
fn IdGenerator::next_step_def_id(self : IdGenerator) -> StepDefId {
  self.counter += 1
  StepDefId("sd-" + self.counter.to_string())
}

///|
/// Registry of step definitions keyed by Cucumber Expression patterns.
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv id_gen : IdGenerator
}

///|
/// Create an empty step registry.
pub fn StepRegistry::new() -> StepRegistry {
  { entries: [], id_gen: IdGenerator::new() }
}

///|
/// Number of registered step definitions.
pub fn StepRegistry::len(self : StepRegistry) -> Int {
  self.entries.length()
}

///|
/// Register a StepDef directly, using the given param registry for expression parsing.
pub fn StepRegistry::register_def(
  self : StepRegistry,
  step_def : StepDef,
  param_registry : @cucumber_expressions.ParamTypeRegistry,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    step_def.pattern,
    param_registry,
  ) catch {
    _ => return
  }
  step_def.id = Some(self.id_gen.next_step_def_id())
  self.entries.push({ def: step_def, expression: expr })
}

///|
/// Return all registered step definitions.
pub fn StepRegistry::step_defs(self : StepRegistry) -> Array[StepDef] {
  self.entries.map(fn(e) { e.def })
}

///|
/// Compose a StepLibrary into this registry using the given param registry.
pub fn[L : StepLibrary] StepRegistry::use_library(
  self : StepRegistry,
  library : L,
  param_registry : @cucumber_expressions.ParamTypeRegistry,
) -> Unit {
  for step_def in library.steps() {
    self.register_def(step_def, param_registry)
  }
}

///|
/// Find a matching step definition for the given step text.
/// Returns Matched with StepDef + extracted args, or Undefined with diagnostics.
pub fn StepRegistry::find_match(
  self : StepRegistry,
  text : String,
  keyword? : String = "* ",
) -> StepMatchResult {
  for entry in self.entries {
    match entry.expression.match_(text) {
      Some(m) => {
        let args = m.params.map(StepArg::from_param)
        return Matched(entry.def, args)
      }
      None => continue
    }
  }
  let snippet = generate_snippet(text, keyword)
  let suggestions = find_suggestions(self, text)
  Undefined(step_text=text, keyword~, snippet~, suggestions~)
}
