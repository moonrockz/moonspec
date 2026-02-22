///|
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    async fn() -> ScenarioResult { execute_pickle(factory, pickle) }
  })
  @async.all(tasks[:], max_concurrent~)
}

///|
async fn[W : @core.World + @core.Hooks] run_pickles_parallel_with_hooks(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    async fn() -> ScenarioResult { execute_pickle_with_hooks(factory, pickle) }
  })
  @async.all(tasks[:], max_concurrent~)
}
