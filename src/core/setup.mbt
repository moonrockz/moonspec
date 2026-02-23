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
/// Compose a StepLibrary into this setup's registry.
pub fn[L : StepLibrary] Setup::use_library(self : Setup, library : L) -> Unit {
  self.step_reg.use_library(library, self.param_reg)
}
