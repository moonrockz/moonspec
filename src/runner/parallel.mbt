///|
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    fn() -> ScenarioResult {
      execute_pickle(factory, pickle, sinks~, tc_mappings~, id_gen~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}

///|
async fn[W : @core.World + @core.Hooks] run_pickles_parallel_with_hooks(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    fn() -> ScenarioResult {
      execute_pickle_with_hooks(
        factory, pickle, sinks~, tc_mappings~, id_gen~,
      )
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
