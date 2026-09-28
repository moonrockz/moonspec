///|
/// Input source for a feature to be loaded into the cache.
pub(all) enum FeatureSource {
  Text(String, String) // (path, content)
  File(String) // (path) — unchanged
  Parsed(String, @gherkin.Feature) // (path, feature)
} derive(Debug, Eq)

///|
pub extend FeatureSource with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FeatureSource with Eq::{not_equal, equal}

///|
/// Status of a single step execution.
pub(all) enum StepStatus {
  Passed
  Failed(String)
  Skipped(String?)
  Undefined
  Pending
} derive(Debug, Eq)

///|
pub extend StepStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepStatus with Eq::{not_equal, equal}

///|
/// Check if a step passed.
pub fn StepStatus::is_passed(self : StepStatus) -> Bool {
  match self {
    Passed => true
    _ => false
  }
}

///|
/// Aggregate status of a scenario.
pub(all) enum ScenarioStatus {
  Passed
  Failed
  Skipped(String?)
  Undefined
  Pending
} derive(Debug, Eq)

///|
pub extend ScenarioStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ScenarioStatus with Eq::{not_equal, equal}

///|
/// Derive scenario status from step statuses.
pub fn ScenarioStatus::from_steps(steps : Array[StepStatus]) -> ScenarioStatus {
  let mut has_failed = false
  let mut has_undefined = false
  let mut has_pending = false
  let mut skip_reason : String?? = None
  for step in steps {
    match step {
      StepStatus::Failed(_) => has_failed = true
      StepStatus::Undefined => has_undefined = true
      StepStatus::Pending => has_pending = true
      StepStatus::Skipped(reason) =>
        if skip_reason is None {
          skip_reason = Some(reason)
        }
      StepStatus::Passed => ()
    }
  }
  if has_failed {
    ScenarioStatus::Failed
  } else if has_undefined {
    ScenarioStatus::Undefined
  } else if has_pending {
    ScenarioStatus::Pending
  } else if skip_reason is Some(reason) {
    ScenarioStatus::Skipped(reason)
  } else {
    ScenarioStatus::Passed
  }
}

///|
/// Result of executing a single step.
pub(all) struct StepResult {
  text : String
  keyword : String
  status : StepStatus
  duration_ms : Int64
  diagnostic : Error?
} derive(Debug)

///|
pub extend StepResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Result of executing a scenario.
pub(all) struct ScenarioResult {
  feature_name : String
  scenario_name : String
  pickle_id : String
  tags : Array[String]
  steps : Array[StepResult]
  status : ScenarioStatus
  duration_ms : Int64
} derive(Debug)

///|
pub extend ScenarioResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Result of executing a feature.
pub(all) struct FeatureResult {
  name : String
  scenarios : Array[ScenarioResult]
  duration_ms : Int64
} derive(Debug)

///|
pub extend FeatureResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Summary of an entire run.
///
/// The `retried` field counts scenarios that required more than one attempt,
/// regardless of their final outcome. A scenario that fails on the first
/// attempt but passes on retry is counted as both `passed` and `retried`.
pub(all) struct RunSummary {
  total_scenarios : Int
  passed : Int
  failed : Int
  undefined : Int
  pending : Int
  skipped : Int
  retried : Int
  duration_ms : Int64
} derive(Debug, Eq)

///|
pub extend RunSummary with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend RunSummary with Eq::{not_equal, equal}

///|
/// Information about a parse error encountered when loading a feature.
pub(all) struct ParseErrorInfo {
  uri : String
  message : String
  line : Int?
} derive(Debug, Eq)

///|
pub extend ParseErrorInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ParseErrorInfo with Eq::{not_equal, equal}

///|
/// Result of executing a pickle, including whether it was retried.
priv struct PickleResult {
  result : ScenarioResult
  was_retried : Bool
}

///|
/// Complete result of a test run.
pub(all) struct RunResult {
  features : Array[FeatureResult]
  summary : RunSummary
  parse_errors : Array[ParseErrorInfo]
} derive(Debug)

///|
pub extend RunResult with @moonbitlang/core/debug.Debug::{to_repr}
