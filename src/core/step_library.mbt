///|
/// A composable group of step definitions.
///
/// Implement this on structs that provide reusable step definitions.
/// Libraries return an immutable view of their steps via `ArrayView`.
pub(open) trait StepLibrary {
  steps(Self) -> ArrayView[StepDef]
}
