///|
/// Structured error hierarchy for moonspec.
///
/// Step-level errors aggregate into ScenarioFailed, which aggregates
/// into RunFailed together with ParseFailed. This enables rich diagnostics
/// and the `run_or_fail` API. See `report.mbt` for the printed form.
pub suberror MoonspecError {
  UndefinedStep(
    step~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
  PendingStep(step~ : String, keyword~ : String, message~ : String)
  StepFailed(step~ : String, keyword~ : String, message~ : String)
  ParseFailed(uri~ : String, line~ : Int?, message~ : String)
  ScenarioFailed(
    scenario~ : String,
    feature~ : String,
    location~ : String?,
    steps~ : Array[StepReport],
    errors~ : Array[MoonspecError]
  )
  RunFailed(summary~ : String, errors~ : Array[MoonspecError], color~ : Bool)
}

///|
/// One step of a failed scenario, in execution order.
///
/// `Problem` holds the StepFailed, UndefinedStep or PendingStep error of the
/// step. The failure report prints all steps, so readers see the context of
/// the failing step.
pub(all) enum StepReport {
  Passed(keyword~ : String, step~ : String)
  Skipped(keyword~ : String, step~ : String)
  Problem(MoonspecError)
}

///|
/// Create an UndefinedStep error.
pub fn undefined_step_error(
  step~ : String,
  keyword~ : String,
  snippet~ : String,
  suggestions~ : Array[String],
) -> Error {
  UndefinedStep(step~, keyword~, snippet~, suggestions~)
}

///|
/// Create a PendingStep error.
pub fn pending_step_error(
  step~ : String,
  keyword~ : String,
  message~ : String,
) -> Error {
  PendingStep(step~, keyword~, message~)
}

///|
/// Create a StepFailed error.
pub fn step_failed_error(
  step~ : String,
  keyword~ : String,
  message~ : String,
) -> Error {
  MoonspecError::StepFailed(step~, keyword~, message~)
}

///|
/// Create a ParseFailed error.
pub fn parse_failed_error(
  uri~ : String,
  line~ : Int?,
  message~ : String,
) -> MoonspecError {
  ParseFailed(uri~, line~, message~)
}

///|
/// Create a ScenarioFailed error.
///
/// `location` is `path:line` of the scenario. `steps` lists every step of the
/// scenario; when it is empty, the report prints `errors` instead.
pub fn scenario_failed_error(
  scenario~ : String,
  feature~ : String,
  location? : String? = None,
  steps? : Array[StepReport] = [],
  errors~ : Array[MoonspecError],
) -> MoonspecError {
  MoonspecError::ScenarioFailed(scenario~, feature~, location~, steps~, errors~)
}

///|
/// Create a RunFailed error. When `color` is true, the report uses ANSI colors.
pub fn run_failed_error(
  summary~ : String,
  errors~ : Array[MoonspecError],
  color? : Bool = false,
) -> Error {
  RunFailed(summary~, errors~, color~)
}
