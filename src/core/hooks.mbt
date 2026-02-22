///|
/// Lifecycle hooks for scenario execution.
///
/// All methods have default no-op implementations. Users optionally
/// implement this on their world struct for setup/teardown logic.
///
/// The `String?` result parameter is `None` for success, `Some(message)`
/// for failure.
pub(open) trait Hooks {
  before_scenario(Self, ScenarioInfo) -> Unit raise Error = _
  after_scenario(Self, ScenarioInfo, String?) -> Unit raise Error = _
  before_step(Self, StepInfo) -> Unit raise Error = _
  after_step(Self, StepInfo, String?) -> Unit raise Error = _
}

///|
impl Hooks with before_scenario(_self, _info) {
  ()
}

///|
impl Hooks with after_scenario(_self, _info, _result) {
  ()
}

///|
impl Hooks with before_step(_self, _info) {
  ()
}

///|
impl Hooks with after_step(_self, _info, _result) {
  ()
}
