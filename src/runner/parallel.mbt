///|
/// Run features with bounded concurrency using `@async.all()`.
async fn run_parallel(
  registry : @core.StepRegistry,
  features : Array[String],
  tag_expr~ : String,
  max_concurrent~ : Int,
) -> Array[FeatureResult] {
  let tasks : Array[async () -> FeatureResult] = features.map(fn(content) {
    async fn() -> FeatureResult {
      execute_feature_filtered(registry, content, tag_expr~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
