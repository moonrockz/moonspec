///|
/// Run features with bounded concurrency.
///
/// TODO: Implement true parallel execution using `@async.all()` with
/// `max_concurrent~`. This requires adapting `execute_feature_filtered` and its
/// callees to work in an async context (the current `!Error` raising style is
/// incompatible with `async fn`). For now, features are executed sequentially
/// and the `max_concurrent` parameter is accepted but not yet enforced.
///
/// The target implementation would look like:
/// ```
/// async fn run_parallel(...) -> Array[FeatureResult] {
///   let tasks = features.map(fn(content) {
///     async fn() -> FeatureResult { execute_feature_filtered!(registry, content, tag_expr~) }
///   })
///   @async.all(tasks[:], max_concurrent~)
/// }
/// ```
fn run_parallel(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String,
  max_concurrent~ : Int,
) -> Array[FeatureResult] raise Error {
  // Accept max_concurrent to establish the API contract.
  // True async execution will be enabled in a future release.
  ignore(max_concurrent)
  run_sequential(registry, features, tag_expr~)
}
