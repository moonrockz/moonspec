///|
/// Run features with bounded concurrency using `@async.all()`.
/// Each scenario gets a fresh world via `factory()` for isolation.
async fn[W : @core.World] run_parallel(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr~ : String,
  max_concurrent~ : Int,
) -> Array[FeatureResult] {
  let tasks : Array[async () -> FeatureResult] = features.map(fn(input) {
    async fn() -> FeatureResult {
      execute_feature_filtered(factory, input, tag_expr~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}

///|
/// Run features with hooks and bounded concurrency using `@async.all()`.
async fn[W : @core.World + @core.Hooks] run_parallel_with_hooks(
  factory : () -> W,
  features : Array[FeatureSource],
  tag_expr~ : String,
  max_concurrent~ : Int,
) -> Array[FeatureResult] {
  let tasks : Array[async () -> FeatureResult] = features.map(fn(input) {
    async fn() -> FeatureResult {
      execute_feature_filtered_with_hooks(factory, input, tag_expr~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
