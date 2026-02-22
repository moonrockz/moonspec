///|
/// moonspec — BDD test framework for MoonBit.
///
/// Re-exports core types and runner functions so users import just
/// `moonrockz/moonspec` and use `@moonspec.World`, `@moonspec.run`, etc.
pub using @core {
  trait World,
  trait Hooks,
  type StepRegistry,
  type StepArg,
  type ScenarioInfo,
  type StepInfo
}

pub using @runner {run, run_with_hooks}
