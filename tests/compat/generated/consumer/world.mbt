///|
pub(all) struct FixtureWorld {
  mut ready : Bool
  mut value : Int
} derive(Default)

///|
pub extend FixtureWorld with Default::{default}

///|
pub impl @moonspec.World for FixtureWorld with configure(self, setup) {
  setup.given("a working fixture", fn(_) raise {
    assert_false(self.ready)
    self.ready = true
  })
  setup.when("the value is {int}", fn(ctx) raise {
    assert_true(self.ready)
    match ctx.value(0) {
      IntVal(value) => self.value = value
      _ => fail("expected integer")
    }
  })
  setup.then("the value is positive", fn(_) raise {
    assert_true(self.ready)
    assert_true(self.value > 0)
  })
}

///|
pub extend FixtureWorld with @moonspec.World::{configure}
