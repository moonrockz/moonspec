///|
pub struct CounterWorld {
  priv mut count : Int
}

///|
pub impl @moonspec.World for CounterWorld with fn configure(self, setup) {
  setup.before_test_case(fn(_) raise { assert_eq(self.count, 0) })
  setup.given("a fresh counter", fn(_) raise { assert_eq(self.count, 0) })
  setup.when("I increment the counter", fn(_) { self.count += 1 })
  setup.then("the counter is one", fn(_) raise { assert_eq(self.count, 1) })
  setup.after_test_case(fn(_, status) raise {
    assert_eq(self.count, 1)
    assert_true(status is Passed)
  })
}

///|
pub extend CounterWorld with @moonspec.World::{configure}

///|
pub fn world() -> CounterWorld {
  { count: 0 }
}

///|
pub fn options(sources : Array[@moonspec.FeatureSource]) -> @moonspec.RunOptions {
  let options = @moonspec.RunOptions(sources)
  options.tag_expr("@shared")
  options.retries(1)
  options.no_color(true)
  options.add_formatter(
    @format.MessagesFormatter::new(),
    @moonspec.OutputDest::Stdout,
  )
  options
}
