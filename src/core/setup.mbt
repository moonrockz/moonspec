///|
/// User-facing configuration facade for registering steps and parameter types.
/// Wraps StepRegistry and ParamTypeRegistry as siblings.
pub(all) struct Setup {
  priv step_reg : StepRegistry
  priv param_reg : @cucumber_expressions.ParamTypeRegistry
  priv hook_reg : HookRegistry
}

///|
pub fn Setup::new() -> Setup {
  {
    step_reg: StepRegistry::new(),
    param_reg: @cucumber_expressions.ParamTypeRegistry::default(),
    hook_reg: HookRegistry::new(),
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
/// Access the underlying hook registry (for runner internals).
pub fn Setup::hook_registry(self : Setup) -> HookRegistry {
  self.hook_reg
}

///|
/// Register a custom parameter type with name and regex patterns.
/// An optional transformer converts matched text into a typed ParamValue.
pub fn Setup::add_param_type(
  self : Setup,
  name : String,
  patterns : Array[@cucumber_expressions.RegexPattern],
  transformer? : @cucumber_expressions.Transformer,
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns,
    transformer?,
  )
}

///|
/// Register a custom parameter type with name and string regex patterns.
/// Convenience method that avoids requiring callers to import cucumber-expressions.
/// An optional transformer converts matched text into a typed ParamValue.
pub fn Setup::add_param_type_strings(
  self : Setup,
  name : String,
  patterns : Array[String],
  transformer? : @cucumber_expressions.Transformer,
) -> Unit {
  self.param_reg.register(
    name,
    @cucumber_expressions.ParamType::Custom(name),
    patterns.map(fn(p) { @cucumber_expressions.RegexPattern(p) }),
    transformer?,
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
  let builtin = [
    "int", "float", "string", "word", "", "double", "long", "byte", "short", "bigdecimal",
    "biginteger",
  ]
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

///|
/// Register a hook to run before the entire test run.
#callsite(autofill(loc))
pub fn Setup::before_test_run(
  self : Setup,
  handler : () -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::BeforeTestRun, RunHandler(handler), source~)
}

///|
/// Register a hook to run after the entire test run.
#callsite(autofill(loc))
pub fn Setup::after_test_run(
  self : Setup,
  handler : () -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestRun, RunHandler(handler), source~)
}

///|
/// Register a hook to run before each test case (scenario).
#callsite(autofill(loc))
pub fn Setup::before_test_case(
  self : Setup,
  handler : (ScenarioInfo) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(
    HookType::BeforeTestCase,
    CaseHandler((info, _result) => handler(info)),
    source~,
  )
}

///|
/// Register a hook to run after each test case (scenario).
#callsite(autofill(loc))
pub fn Setup::after_test_case(
  self : Setup,
  handler : (ScenarioInfo, String?) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestCase, CaseHandler(handler), source~)
}

///|
/// Register a hook to run before each test step.
#callsite(autofill(loc))
pub fn Setup::before_test_step(
  self : Setup,
  handler : (StepInfo) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(
    HookType::BeforeTestStep,
    StepHandler((info, _result) => handler(info)),
    source~,
  )
}

///|
/// Register a hook to run after each test step.
#callsite(autofill(loc))
pub fn Setup::after_test_step(
  self : Setup,
  handler : (StepInfo, String?) -> Unit raise Error,
  loc~ : SourceLoc,
) -> Unit {
  let source : StepSource? = Some(StepSource::new(uri=loc.to_string()))
  self.hook_reg.add(HookType::AfterTestStep, StepHandler(handler), source~)
}
