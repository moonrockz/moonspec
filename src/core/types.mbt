///|
/// A typed step argument extracted from step text via Cucumber Expressions.
pub(all) enum StepArg {
  IntArg(Int)
  FloatArg(Double)
  StringArg(String)
  WordArg(String)
  CustomArg(String)
} derive(Show, Eq)

///|
/// Convert a cucumber-expressions Param to a typed StepArg.
pub fn StepArg::from_param(param : @cucumber_expressions.Param) -> StepArg {
  match param.type_ {
    @cucumber_expressions.ParamType::Int => {
      let n = @strconv.parse_int(param.value) catch { _ => 0 }
      IntArg(n)
    }
    @cucumber_expressions.ParamType::Float => {
      let f = @strconv.parse_double(param.value) catch { _ => 0.0 }
      FloatArg(f)
    }
    @cucumber_expressions.ParamType::String_ => StringArg(param.value)
    @cucumber_expressions.ParamType::Word => WordArg(param.value)
    @cucumber_expressions.ParamType::Anonymous => StringArg(param.value)
    @cucumber_expressions.ParamType::Custom(_) => CustomArg(param.value)
  }
}

///|
/// Result of matching step text against the registry.
pub(all) enum StepMatchResult {
  Matched(StepDef, Array[StepArg])
  Undefined(
    step_text~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String],
  )
}

///|
/// Information about a scenario being executed.
pub(all) struct ScenarioInfo {
  feature_name : String
  scenario_name : String
  tags : Array[String]
} derive(Show, Eq)

///|
/// Information about a step being executed.
pub(all) struct StepInfo {
  keyword : String
  text : String
} derive(Show, Eq)
