///|
/// User-facing configuration facade for registering steps and parameter types.
/// Wraps StepRegistry and ParamTypeRegistry as siblings.
pub(all) struct Setup {
  priv step_reg : StepRegistry
  priv param_reg : @cucumber_expressions.ParamTypeRegistry
}

///|
pub fn Setup::new() -> Setup {
  {
    step_reg: StepRegistry::new(),
    param_reg: @cucumber_expressions.ParamTypeRegistry::default(),
  }
}

///|
/// Access the underlying step registry (for runner internals).
pub fn Setup::step_registry(self : Setup) -> StepRegistry {
  self.step_reg
}

///|
/// Access the underlying param type registry (for runner internals).
pub fn Setup::param_registry(
  self : Setup,
) -> @cucumber_expressions.ParamTypeRegistry {
  self.param_reg
}

///|
/// Register a custom parameter type with name and regex patterns.
pub fn Setup::add_param_type(
  self : Setup,
  name : String,
  patterns : Array[@cucumber_expressions.RegexPattern],
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns,
  )
}

///|
/// Register a custom parameter type with name and string regex patterns.
/// Convenience method that avoids requiring callers to import cucumber-expressions.
pub fn Setup::add_param_type_strings(
  self : Setup,
  name : String,
  patterns : Array[String],
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns.map(fn(p) { @cucumber_expressions.RegexPattern(p) }),
  )
}

///|
/// Register a Given step.
pub fn Setup::given(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Given,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a When step.
pub fn Setup::when(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::When,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a Then step.
pub fn Setup::then(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Then,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Register a step that matches any keyword.
pub fn Setup::step(
  self : Setup,
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
) -> Unit {
  self.step_reg.register_def(
    {
      keyword: StepKeyword::Step,
      pattern,
      handler: StepHandler(handler),
      source: None,
      id: None,
    },
    self.param_reg,
  )
}

///|
/// Info about a custom parameter type, for envelope emission.
pub(all) struct CustomParamTypeInfo {
  name : String
  patterns : Array[String]
}

///|
/// Return custom (non-built-in) parameter types for envelope emission.
/// Built-in types (int, float, string, word, anonymous "") are excluded.
pub fn Setup::custom_param_types(self : Setup) -> Array[CustomParamTypeInfo] {
  let builtin = ["int", "float", "string", "word", ""]
  let result : Array[CustomParamTypeInfo] = []
  for entry in self.param_reg.entries_view() {
    if builtin.contains(entry.name) {
      continue
    }
    result.push({
      name: entry.name,
      patterns: entry.patterns.map(fn(p) { p.to_string() }),
    })
  }
  result
}

///|
/// Compose a StepLibrary into this setup's registry.
pub fn[L : StepLibrary] Setup::use_library(self : Setup, library : L) -> Unit {
  self.step_reg.use_library(library, self.param_reg)
}
