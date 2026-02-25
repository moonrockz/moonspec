///|
/// Step library for checkout operations.
priv struct CheckoutSteps {
  world : EcomWorld
}

///|
fn CheckoutSteps::new(world : EcomWorld) -> CheckoutSteps {
  { world, }
}

///|
impl @moonspec.StepLibrary for CheckoutSteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::when0("I proceed to checkout", fn() {
      if self.world.cart.length() == 0 {
        self.world.checkout_rejected = true
      } else {
        let mut total = 0
        for item in self.world.cart {
          total = total + item.quantity * item.price
        }
        self.world.order_total = total
        // Decrease inventory for purchased items
        for item in self.world.cart {
          match self.world.inventory.get(item.name) {
            Some(stock) =>
              self.world.inventory[item.name] = stock - item.quantity
            None => ()
          }
        }
        self.world.cart.clear()
      }
    }),
    @moonspec.StepDef::then1("the order total should be {int}", fn(
      expected : Int,
    ) { assert_eq!(self.world.order_total, expected) }),
    @moonspec.StepDef::then0("the checkout should be rejected", fn() {
      assert_true!(self.world.checkout_rejected)
    }),
  ]
  defs[:]
}
