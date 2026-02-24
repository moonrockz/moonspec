///|
/// Structured error hierarchy for moonspec.
///
/// Step-level errors aggregate into ScenarioFailed, which aggregates
/// into RunFailed. This enables rich diagnostics and the `run_or_fail!` API.
pub suberror MoonspecError {
  UndefinedStep(
    step~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
  PendingStep(step~ : String, keyword~ : String, message~ : String)
  StepFailed(step~ : String, keyword~ : String, message~ : String)
  ScenarioFailed(
    scenario~ : String,
    feature~ : String,
    errors~ : Array[MoonspecError]
  )
  RunFailed(summary~ : String, errors~ : Array[MoonspecError])
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
/// Create a ScenarioFailed error.
pub fn scenario_failed_error(
  scenario~ : String,
  feature~ : String,
  errors~ : Array[MoonspecError],
) -> MoonspecError {
  MoonspecError::ScenarioFailed(scenario~, feature~, errors~)
}

///|
/// Create a RunFailed error.
pub fn run_failed_error(
  summary~ : String,
  errors~ : Array[MoonspecError],
) -> Error {
  RunFailed(summary~, errors~)
}
