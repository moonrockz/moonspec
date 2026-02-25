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
    @moonspec.StepDef::given2(
      "the inventory has {string} with stock {int}",
      fn(name : String, stock : Int) { self.world.inventory[name] = stock },
    ),
    @moonspec.StepDef::when1(
      "I check stock for {string}",
      fn(name : String) { self.world.last_checked_item = name },
    ),
    @moonspec.StepDef::then0("the item should be in stock", fn() {
      match self.world.inventory.get(self.world.last_checked_item) {
        Some(stock) => assert_true!(stock > 0)
        None => fail!("Item not found in inventory")
      }
    }),
    @moonspec.StepDef::then1("the stock level should be {int}", fn(
      expected : Int,
    ) {
      match self.world.inventory.get(self.world.last_checked_item) {
        Some(stock) => assert_eq!(stock, expected)
        None => fail!("Item not found in inventory")
      }
    }),
    @moonspec.StepDef::then2(
      "the stock level for {string} should be {int}",
      fn(name : String, expected : Int) {
        match self.world.inventory.get(name) {
          Some(stock) => assert_eq!(stock, expected)
          None => fail!("Item not found in inventory")
        }
      },
    ),
  ]
  defs[:]
}
