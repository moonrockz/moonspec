///|
/// A cart item with name, quantity, and unit price.
priv struct CartItem {
  name : String
  mut quantity : Int32
  price : Int32
}

///|
/// World struct holding per-scenario state for ecommerce tests.
/// Combines cart, checkout, and inventory domains.
struct EcomWorld {
  cart : Array[CartItem]
  mut order_total : Int32
  mut checkout_rejected : Bool
  inventory : Map[String, Int32]
  mut last_checked_item : String
} derive(Default)

///|
/// Make `EcomWorld::default` an explicit method, so tests can pass it as the
/// World factory without the implicit-promotion deprecation warning.
pub extend EcomWorld with Default::{default}

///|
/// Compose all step libraries into the world.
/// Only the generated tests use this impl, so it is unused in non-test code.
#warnings("-unused_value")
impl @moonspec.World for EcomWorld with fn configure(self, setup) {
  setup.use_library(CartSteps::new(self))
  setup.use_library(CheckoutSteps::new(self))
  setup.use_library(InventorySteps::new(self))
}
