///|
/// A composable group of step definitions.
///
/// Implement this on structs that provide reusable step definitions.
/// Libraries return an immutable view of their steps via `ArrayView`.
pub(open) trait StepLibrary {
  fn steps(Self) -> ArrayView[StepDef]
}
