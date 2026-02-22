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
    suggestions~ : Array[String],
  )
  PendingStep(
    step~ : String,
    keyword~ : String,
    message~ : String,
  )
  StepFailed(
    step~ : String,
    keyword~ : String,
    message~ : String,
  )
  ScenarioFailed(
    scenario~ : String,
    feature~ : String,
    errors~ : Array[MoonspecError],
  )
  RunFailed(
    summary~ : String,
    errors~ : Array[MoonspecError],
  )
}
