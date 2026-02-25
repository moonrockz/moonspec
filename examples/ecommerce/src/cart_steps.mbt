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
    @moonspec.StepDef::given0("an empty shopping cart", fn() {
      self.world.cart.clear()
    }),
    @moonspec.StepDef::when3(
      "I add {string} with quantity {int} at price {int}",
      fn(name : String, qty : Int, price : Int) {
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
      },
    ),
    @moonspec.StepDef::when1(
      "I remove {string} from the cart",
      fn(name : String) {
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
      },
    ),
    @moonspec.StepDef::then1(
      "the cart should contain {int} item",
      fn(expected : Int) { assert_eq!(self.world.cart.length(), expected) },
    ),
    @moonspec.StepDef::then1(
      "the cart should contain {int} items",
      fn(expected : Int) { assert_eq!(self.world.cart.length(), expected) },
    ),
    @moonspec.StepDef::then1("the cart total should be {int}", fn(
      expected : Int,
    ) {
      let mut total = 0
      for item in self.world.cart {
        total = total + item.quantity * item.price
      }
      assert_eq!(total, expected)
    }),
    @moonspec.StepDef::then0("the cart should be empty", fn() {
      assert_eq!(self.world.cart.length(), 0)
    }),
  ]
  defs[:]
}
