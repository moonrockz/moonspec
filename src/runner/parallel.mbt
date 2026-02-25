///|
async fn[W : @core.World] run_pickles_parallel(
  factory : () -> W,
  pickles : Array[@cucumber_messages.Pickle],
  max_concurrent~ : Int,
  sinks? : Array[&@core.MessageSink] = [],
  tc_mappings? : Map[String, TestCaseMapping] = {},
  id_gen? : IdGenerator = IdGenerator::new(),
  retries? : Int = 0,
  dry_run? : Bool = false,
  skip_tags? : Array[String] = [],
) -> Array[PickleResult] {
  let tasks : Array[async () -> PickleResult] = pickles.map(fn(pickle) {
    async fn() -> PickleResult {
      execute_pickle(
        factory,
        pickle,
        sinks~,
        tc_mappings~,
        id_gen~,
        retries~,
        dry_run~,
        skip_tags~,
      )
    }
  })
  @async.all(tasks[:], max_concurrent~)
}
