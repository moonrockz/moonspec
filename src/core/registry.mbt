///|
/// A step handler function that receives extracted arguments.
pub struct StepHandler((Array[StepArg]) -> Unit raise Error)

///|
/// A registered step definition: compiled expression + handler.
struct StepEntry {
  expression : @cucumber_expressions.Expression
  handler : StepHandler
}

///|
/// Registry of step definitions keyed by Cucumber Expression patterns.
pub(all) struct StepRegistry {
  priv entries : Array[StepEntry]
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
/// Register a step definition with a Cucumber Expression pattern.
fn StepRegistry::register(
  self : StepRegistry,
  pattern : String,
  handler : StepHandler,
) -> Unit {
  let expr = @cucumber_expressions.Expression::parse_with_registry(
    pattern,
    self.param_registry,
  ) catch {
    _ => return // silently skip invalid patterns
  }
  self.entries.push({ expression: expr, handler })
}

///|
/// Register a Given step.
pub fn StepRegistry::given(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a When step.
pub fn StepRegistry::when(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a Then step.
pub fn StepRegistry::then(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Register a step that matches any keyword.
pub fn StepRegistry::step(
  self : StepRegistry,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.register(pattern, StepHandler(handler))
}

///|
/// Find a matching step definition for the given step text.
/// Returns (handler, extracted_args, expression_source) or None.
pub fn StepRegistry::find_match(
  self : StepRegistry,
  text : String,
) -> (StepHandler, Array[StepArg], String)? {
  for entry in self.entries {
    match entry.expression.match_(text) {
      Some(m) => {
        let args = m.params.map(StepArg::from_param)
        return Some((entry.handler, args, entry.expression.source()))
      }
      None => continue
    }
  }
  None
}
