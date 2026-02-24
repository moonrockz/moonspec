///|
/// moonspec — BDD test framework for MoonBit.
///
/// Re-exports core types and runner functions so users import just
/// `moonrockz/moonspec` and use `@moonspec.World`, `@moonspec.run`, etc.
pub using @core {
  trait World,
  trait StepLibrary,
  type StepRegistry,
  type StepDef,
  type StepArg,
  type StepValue,
  type StepKeyword,
  type StepSource,
  type StepMatchResult,
  type MoonspecError,
  type ScenarioInfo,
  type StepInfo,
  type Cells,
  type Row,
  type Rows,
  type Column,
  type Columns,
  type DataTable,
  type DocString,
  type Setup,
  type HookRegistry,
  type HookType,
  type HookHandler,
  type PendingAttachment,
  type RegisteredHook,
}

///|
pub using @runner {
  type FeatureSource,
  type RunResult,
  type RunSummary,
  type FeatureResult,
  type ScenarioResult,
  type StepResult,
  type ScenarioStatus,
  type StepStatus,
  type RunOptions,
  run,
  run_or_fail,
}
