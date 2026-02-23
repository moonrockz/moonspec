///|
/// A cart item with name, quantity, and unit price.
priv struct CartItem {
  name : String
  mut quantity : Int
  price : Int
} derive(Show)

///|
/// World struct holding per-scenario state for ecommerce tests.
/// Combines cart, checkout, and inventory domains.
struct EcomWorld {
  cart : Array[CartItem]
  mut order_total : Int
  mut checkout_rejected : Bool
  inventory : Map[String, Int]
  mut last_checked_item : String
} derive(Default)

///|
/// Compose all step libraries into the world.
impl @moonspec.World for EcomWorld with configure(self, setup) {
  setup.use_library(CartSteps::new(self))
  setup.use_library(CheckoutSteps::new(self))
  setup.use_library(InventorySteps::new(self))
}
