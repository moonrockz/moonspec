///|
enum LightColor {
  Red
} derive(Eq, Debug)

///|
struct TypedColorWorld {} derive(Default)

///|
pub extend TypedColorWorld with Default::{default}

///|
impl @core.World for TypedColorWorld with fn configure(_self, setup) {
  let color = setup.define_param_type1("color", ["red|blue"], fn(s) raise {
    match s {
      "red" => LightColor::Red
      _ => raise Failure("unsupported color: \{s}")
    }
  })
  setup.given("a {color} light", fn(ctx) raise {
    assert_eq(ctx[0].get(color), Red)
    assert_eq(ctx[0].raw, "red")
  })
  setup.then("it works", fn(_ctx) {  })
}

///|
async test "runner executes custom domain values with typed handles" {
  let feature =
    #|Feature: Typed colors
    #|  Scenario: Red light
    #|    Given a red light
    #|    Then it works
  let result = run(
    TypedColorWorld::default,
    RunOptions([FeatureSource::Text("test://typed-colors", feature)]),
  )
  assert_eq(result.summary.passed, 1)
}

///|
async test "typed decoder failures report diagnostics in normal and dry-run execution" {
  let feature =
    #|Feature: Typed colors
    #|  Scenario: Unsupported light
    #|    Given a blue light
    #|    Then it works
  for dry_run in [false, true] {
    let options = RunOptions([
      FeatureSource::Text("test://typed-colors", feature),
    ])
    options.dry_run(dry_run)
    let result = run(TypedColorWorld::default, options)
    assert_eq(result.summary.failed, 1)
    let steps = result.features[0].scenarios[0].steps
    match steps[0].status {
      Failed(message) =>
        assert_true(message.contains("unsupported color: blue"))
      _ => fail("expected failed decoding")
    }
    assert_true(steps[0].diagnostic is Some(_))
    assert_true(steps[1].status is Skipped)
  }
}

///|
struct InvalidParameterWorld {} derive(Default)

///|
pub extend InvalidParameterWorld with Default::{default}

///|
impl @core.World for InvalidParameterWorld with fn configure(_self, setup) {
  setup.add_param_type_strings("color", ["red"])
  setup.add_param_type_strings("color", ["blue"])
}

///|
async test "runner propagates parameter registration errors from configure" {
  let feature =
    #|Feature: Invalid configuration
    #|  Scenario: Duplicate parameters
    #|    Given a red light
  let rejected = try {
    ignore(
      run(
        InvalidParameterWorld::default,
        RunOptions([FeatureSource::Text("test://invalid-params", feature)]),
      ),
    )
    false
  } catch {
    @cucumber_expressions.ParameterTypeError::DuplicateParameterType(name~) =>
      name == "color"
    _ => false
  }
  assert_true(rejected)
}
