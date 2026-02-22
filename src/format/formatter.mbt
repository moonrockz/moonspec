///|
/// Information about a test run starting.
pub(all) struct RunInfo {
  feature_count : Int
  scenario_count : Int
} derive(Show, Eq)

///|
/// Event-driven formatter trait. The runner notifies formatters as events happen.
/// All methods have default no-op implementations.
pub(open) trait Formatter {
  on_run_start(Self, RunInfo) -> Unit = _
  on_feature_start(Self, String) -> Unit = _
  on_scenario_start(Self, @runner.ScenarioResult) -> Unit = _
  on_step_finish(Self, @runner.StepResult) -> Unit = _
  on_scenario_finish(Self, @runner.ScenarioResult) -> Unit = _
  on_feature_finish(Self, @runner.FeatureResult) -> Unit = _
  on_run_finish(Self, @runner.RunResult) -> Unit = _
}

///|
impl Formatter with on_run_start(_self, _info) { () }

///|
impl Formatter with on_feature_start(_self, _name) { () }

///|
impl Formatter with on_scenario_start(_self, _result) { () }

///|
impl Formatter with on_step_finish(_self, _result) { () }

///|
impl Formatter with on_scenario_finish(_self, _result) { () }

///|
impl Formatter with on_feature_finish(_self, _result) { () }

///|
impl Formatter with on_run_finish(_self, _result) { () }
