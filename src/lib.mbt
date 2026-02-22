///|
/// moonspec — BDD test framework for MoonBit.
///
/// Re-exports core types and runner functions so users import just
/// `moonrockz/moonspec` and use `@moonspec.World`, `@moonspec.run`, etc.
pub using @core {
  trait World,
  trait Hooks,
  trait StepLibrary,
  type StepRegistry,
  type StepDef,
  type StepArg,
  type StepKeyword,
  type StepSource,
  type StepMatchResult,
  type MoonspecError,
  type ScenarioInfo,
  type StepInfo,
}

///|
pub using @runner {type FeatureSource, run, run_with_hooks, run_or_fail}
