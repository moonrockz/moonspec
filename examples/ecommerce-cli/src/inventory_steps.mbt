///|
/// Step library for inventory management.
priv struct InventorySteps {
  world : EcomWorld
}

///|
fn InventorySteps::new(world : EcomWorld) -> InventorySteps {
  { world, }
}

///|
impl @moonspec.StepLibrary for InventorySteps with steps(self) {
  let defs : Array[@moonspec.StepDef] = [
    @moonspec.StepDef::given(
      "the inventory has {string} with stock {int}",
      fn(args) {
        match (args[0], args[1]) {
          (
            @moonspec.StepArg::StringArg(name),
            @moonspec.StepArg::IntArg(stock),
          ) => self.world.inventory[name] = stock
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::when(
      "I check stock for {string}",
      fn(args) {
        match args[0] {
          @moonspec.StepArg::StringArg(name) =>
            self.world.last_checked_item = name
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the item should be in stock",
      fn(_args) raise {
        match self.world.inventory.get(self.world.last_checked_item) {
          Some(stock) => assert_true(stock > 0)
          None => fail("Item not found in inventory")
        }
      },
    ),
    @moonspec.StepDef::then(
      "the stock level should be {int}",
      fn(args) raise {
        match args[0] {
          @moonspec.StepArg::IntArg(expected) =>
            match self.world.inventory.get(self.world.last_checked_item) {
              Some(stock) => assert_eq(stock, expected)
              None => fail("Item not found in inventory")
            }
          _ => ()
        }
      },
    ),
    @moonspec.StepDef::then(
      "the stock level for {string} should be {int}",
      fn(args) raise {
        match (args[0], args[1]) {
          (
            @moonspec.StepArg::StringArg(name),
            @moonspec.StepArg::IntArg(expected),
          ) =>
            match self.world.inventory.get(name) {
              Some(stock) => assert_eq(stock, expected)
              None => fail("Item not found in inventory")
            }
          _ => ()
        }
      },
    ),
  ]
  defs[:]
}
