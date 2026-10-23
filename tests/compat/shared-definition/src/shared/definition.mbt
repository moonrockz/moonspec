///|
pub struct SharedWorld {
  priv mut ready : Bool
}

///|
pub impl @moonspec.World for SharedWorld with fn configure(self, setup) {
  setup.given("a fresh World", fn(_) raise {
    assert_false(self.ready)
    self.ready = true
  })
  setup.after_test_case(fn(_, result) raise {
    assert_true(self.ready)
    assert_true(result is Passed)
  })
}

///|
pub fn world() -> SharedWorld {
  { ready: false, }
}

///|
pub fn options() -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions([
    @moonspec.FeatureSource::Text(
      "original/shared.feature", "Feature: Shared\n  @keep\n  Scenario: Portable\n    Given a fresh World\n",
    ),
  ])
  options.tag_expr("@keep")
  options.retries(1)
  options.no_color(true)
  options
}

///|
pub extend SharedWorld with @moonspec.World::{configure}
