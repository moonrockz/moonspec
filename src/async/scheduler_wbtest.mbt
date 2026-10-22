///|
async test "bounded async scheduling overlaps tasks while enforcing the limit and result order" {
  let active = Ref(0)
  let peak = Ref(0)
  let options = RunOptions([])
  options.parallel(true)
  options.max_concurrent(2)
  let tasks : Array[async () -> Int32] = [0, 1, 2, 3].map(fn(index) {
    async fn() {
      active.val += 1
      if active.val > peak.val {
        peak.val = active.val
      }
      @runtime.sleep(if index == 0 { 10 } else { 1 })
      active.val -= 1
      index
    }
  })
  let results = schedule_tasks(tasks, options)
  assert_eq(results, [0, 1, 2, 3])
  assert_eq(peak.val, 2)
  assert_eq(active.val, 0)
}

///|
async test "sequential async scheduling ignores max concurrency and completes tasks in order" {
  let options = RunOptions([])
  options.max_concurrent(0)
  let calls : Array[Int32] = []
  let tasks : Array[async () -> Int32] = [0, 1, 2].map(fn(index) {
    async fn() {
      calls.push(index)
      @runtime.sleep(1)
      calls.push(index)
      index
    }
  })
  let results = schedule_tasks(tasks, options)
  assert_eq(results, [0, 1, 2])
  assert_eq(calls, [0, 0, 1, 1, 2, 2])
}
