///|
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
) -> Array[ScenarioResult] {
  let tasks : Array[async () -> ScenarioResult] = pickles.map(fn(pickle) {
    fn() -> ScenarioResult {
      execute_pickle(factory, pickle, sinks~, tc_mappings~, id_gen~, retries~)
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
