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
/// Registry of step definitions keyed by Cucumber Expression patterns.
pub(all) struct StepRegistry {
  priv entries : Array[CompiledStep]
  priv param_registry : @cucumber_expressions.ParamTypeRegistry
}

///|
/// Create an empty step registry with default parameter types.
pub fn StepRegistry::new() -> StepRegistry {
  {
    entries: [],
    param_registry: @cucumber_expressions.ParamTypeRegistry::default(),
  }
}

///|
/// Number of registered step definitions.
pub fn StepRegistry::len(self : StepRegistry) -> Int {
  self.entries.length()
}

///|
/// Register a StepDef directly.
pub fn StepRegistry::register_def(
  self : StepRegistry,
  step_def : StepDef,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    step_def.pattern,
    self.param_registry,
  ) catch {
    _ => return
  }
  self.entries.push({ def: step_def, expression: expr })
}

///|
/// Compose a StepLibrary into this registry.
pub fn[L : StepLibrary] StepRegistry::use_library(
  self : StepRegistry,
  library : L,
) -> Unit {
  for step_def in library.steps() {
    self.register_def(step_def)
  }
}

///|
fn StepRegistry::register(
  self : StepRegistry,
  keyword : StepKeyword,
  pattern : String,
  handler : StepHandler,
) -> Unit {
  self.register_def({ keyword, pattern, handler, source: None })
}

///|
/// Register a Given step.
pub fn StepRegistry::given(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Given, pattern, StepHandler(handler))
}

///|
/// Register a When step.
pub fn StepRegistry::when(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::When, pattern, StepHandler(handler))
}

///|
/// Register a Then step.
pub fn StepRegistry::then(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Then, pattern, StepHandler(handler))
}

///|
/// Register a step that matches any keyword.
pub fn StepRegistry::step(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(StepKeyword::Step, pattern, StepHandler(handler))
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
