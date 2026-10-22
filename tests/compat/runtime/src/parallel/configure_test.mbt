///|
async test "configure errors propagate during preparation and retry with fresh Worlds" {
  for fail_at in [0, 1, 2] {
    let factories = Ref(0)
    let options = @shared.configure_options()
    options.parallel(true)
    options.max_concurrent(2)
    let rejected = try {
      let _ = @moonspec.run(
        fn() {
          let ordinal = factories.val
          factories.val += 1
          @shared.configure_world(ordinal, fail_at)
        },
        options,
      )
      false
    } catch {
      @shared.ConfigureFailure => true
      error => fail(error.to_string())
    }
    assert_true(rejected)
    assert_eq(factories.val, fail_at + 1)
  }
}
