///|
/// Input source for a feature to be loaded into the cache.
pub(all) enum FeatureSource {
  Text(String, String) // (path, content)
  File(String) // (path) — unchanged
  Parsed(String, @gherkin.Feature) // (path, feature)
} derive(Show, Eq)

///|
/// Status of a single step execution.
pub(all) enum StepStatus {
  Passed
  Failed(String)
  Skipped
  Undefined
  Pending
} derive(Show, Eq)

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
  Skipped
  Undefined
  Pending
} derive(Show, Eq)

///|
/// Derive scenario status from step statuses.
pub fn ScenarioStatus::from_steps(steps : Array[StepStatus]) -> ScenarioStatus {
  let mut has_failed = false
  let mut has_undefined = false
  let mut has_pending = false
  let mut has_skipped = false
  for step in steps {
    match step {
      StepStatus::Failed(_) => has_failed = true
      StepStatus::Undefined => has_undefined = true
      StepStatus::Pending => has_pending = true
      StepStatus::Skipped => has_skipped = true
      StepStatus::Passed => ()
    }
  }
  if has_failed {
    ScenarioStatus::Failed
  } else if has_undefined {
    ScenarioStatus::Undefined
  } else if has_pending {
    ScenarioStatus::Pending
  } else if has_skipped {
    ScenarioStatus::Skipped
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
} derive(Show)

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
} derive(Show)

///|
/// Result of executing a feature.
pub(all) struct FeatureResult {
  name : String
  scenarios : Array[ScenarioResult]
  duration_ms : Int64
} derive(Show)

///|
/// Summary of an entire run.
pub(all) struct RunSummary {
  total_scenarios : Int
  passed : Int
  failed : Int
  undefined : Int
  pending : Int
  skipped : Int
  retried : Int
  duration_ms : Int64
} derive(Show, Eq)

///|
/// Information about a parse error encountered when loading a feature.
pub(all) struct ParseErrorInfo {
  uri : String
  message : String
  line : Int?
} derive(Show, Eq)

///|
/// Complete result of a test run.
pub(all) struct RunResult {
  features : Array[FeatureResult]
  summary : RunSummary
  parse_errors : Array[ParseErrorInfo]
} derive(Show)
