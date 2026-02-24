///|
/// Step library for shopping cart operations.
priv struct CartSteps {
  world : EcomWorld
}

///|
fn CartSteps::new(world : EcomWorld) -> CartSteps {
  { world, }
}

///|
impl @moonspec.StepLibrary for CartSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::given(
      "an empty shopping cart",
      fn(_args) { self.world.cart.clear() },
    ),
    @moonspec.StepDef::when(
      "I add {string} with quantity {int} at price {int}",
      fn(args) {
        match (args[0], args[1], args[2]) {
          (
            { value: @moonspec.StepValue::StringVal(name), .. },
            { value: @moonspec.StepValue::IntVal(qty), .. },
            { value: @moonspec.StepValue::IntVal(price), .. },
          ) => {
            // Check if item already in cart; if so, increase quantity
            let mut found = false
            for item in self.world.cart {
              if item.name == name {
                item.quantity = item.quantity + qty
                found = true
                break
              }
            }
            if not(found) {
              self.world.cart.push({ name, quantity: qty, price })
            }
          }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::when(
      "I remove {string} from the cart",
      fn(args) {
        match args[0] {
          { value: @moonspec.StepValue::StringVal(name), .. } => {
            let mut idx = -1
            for i, item in self.world.cart {
              if item.name == name {
                idx = i
                break
              }
            }
            if idx >= 0 {
              self.world.cart.remove(idx) |> ignore
            }
          }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the cart should contain {int} item",
      fn(args) raise {
        match args[0] {
          { value: @moonspec.StepValue::IntVal(expected), .. } =>
            assert_eq(self.world.cart.length(), expected)
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the cart should contain {int} items",
      fn(args) raise {
        match args[0] {
          { value: @moonspec.StepValue::IntVal(expected), .. } =>
            assert_eq(self.world.cart.length(), expected)
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the cart total should be {int}",
      fn(args) raise {
        match args[0] {
          { value: @moonspec.StepValue::IntVal(expected), .. } => {
            let mut total = 0
            for item in self.world.cart {
              total = total + item.quantity * item.price
            }
            assert_eq(total, expected)
          }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the cart should be empty",
      fn(_args) raise { assert_eq(self.world.cart.length(), 0) },
    ),
  ]
  defs[:]
}
