///|
struct TestWorld {
  mut value : Int
}

///|
struct MathSteps {
  world : TestWorld
}

///|
fn MathSteps::new(world : TestWorld) -> MathSteps {
  { world, }
}

///|
impl StepLibrary for MathSteps with steps(self) {
  [
    StepDef::given("a value of {int}", fn(args) {
      match args[0] {
        { value: StepValue::IntVal(n), .. } => self.world.value = n
        _ => ()
      }
    }),
    StepDef::then("the value is {int}", fn(args) raise {
      match args[0] {
        { value: StepValue::IntVal(n), .. } => assert_eq(self.world.value, n)
        _ => ()
      }
    }),
  ][:]
}

///|
test "StepLibrary returns ArrayView of StepDefs" {
  let world : TestWorld = { value: 0 }
  let lib = MathSteps::new(world)
  let defs = lib.steps()
  assert_eq(defs.length(), 2)
  assert_eq(defs[0].keyword, StepKeyword::Given)
  assert_eq(defs[1].keyword, StepKeyword::Then)
}
