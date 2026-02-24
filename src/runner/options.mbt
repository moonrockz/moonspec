///|
/// Options for configuring a test run.
pub(all) struct RunOptions {
  priv features_ : Array[FeatureSource]
  priv mut parallel_ : Bool
  priv mut max_concurrent_ : Int
  priv sinks_ : Array[&@core.MessageSink]
  priv mut tag_expr_ : String
  priv mut scenario_name_ : String
  priv mut retries_ : Int

  fn new(features : Array[FeatureSource]) -> RunOptions
}

///|
pub fn RunOptions::new(features : Array[FeatureSource]) -> RunOptions {
  {
    features_: features,
    parallel_: false,
    max_concurrent_: 4,
    sinks_: [],
    tag_expr_: "",
    scenario_name_: "",
    retries_: 0,
  }
}

///|
/// Enable or disable parallel execution.
pub fn RunOptions::parallel(self : RunOptions, value : Bool) -> Unit {
  self.parallel_ = value
}

///|
/// Set maximum concurrent scenarios for parallel execution.
pub fn RunOptions::max_concurrent(self : RunOptions, value : Int) -> Unit {
  self.max_concurrent_ = value
}

///|
/// Add a message sink for envelope output.
pub fn RunOptions::add_sink(
  self : RunOptions,
  sink : &@core.MessageSink,
) -> Unit {
  self.sinks_.push(sink)
}

///|
/// Set a tag expression filter.
pub fn RunOptions::tag_expr(self : RunOptions, value : String) -> Unit {
  self.tag_expr_ = value
}

///|
/// Set a scenario name filter.
pub fn RunOptions::scenario_name(self : RunOptions, value : String) -> Unit {
  self.scenario_name_ = value
}

///|
/// Get the feature sources.
pub fn RunOptions::features(self : RunOptions) -> Array[FeatureSource] {
  self.features_
}

///|
/// Check if parallel execution is enabled.
pub fn RunOptions::is_parallel(self : RunOptions) -> Bool {
  self.parallel_
}

///|
/// Get the max concurrent limit.
pub fn RunOptions::get_max_concurrent(self : RunOptions) -> Int {
  self.max_concurrent_
}

///|
/// Get the configured sinks.
pub fn RunOptions::get_sinks(self : RunOptions) -> Array[&@core.MessageSink] {
  self.sinks_
}

///|
/// Get the tag expression filter.
pub fn RunOptions::get_tag_expr(self : RunOptions) -> String {
  self.tag_expr_
}

///|
/// Get the scenario name filter.
pub fn RunOptions::get_scenario_name(self : RunOptions) -> String {
  self.scenario_name_
}

///|
/// Set the global retry count for failed scenarios.
///
/// When a scenario fails, it will be re-executed up to `value` additional times.
/// A fresh World instance is created for each attempt. Only the final attempt's
/// result counts toward the run summary.
///
/// Per-scenario `@retry(N)` tags override this global setting. Negative values
/// are clamped to 0.
///
/// ```moonbit nocheck
/// let opts = RunOptions::new(features)
/// opts.retries(2) // retry failed scenarios up to 2 times
/// ```
pub fn RunOptions::retries(self : RunOptions, value : Int) -> Unit {
  self.retries_ = if value < 0 { 0 } else { value }
}

///|
/// Get the global retry count for failed scenarios.
pub fn RunOptions::get_retries(self : RunOptions) -> Int {
  self.retries_
}
