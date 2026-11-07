///|
priv struct TodoItem {
  title : String
  mut completed : Bool
}

///|
#derive(Default)
#moonspec.world
struct TodoWorld {
  todos : Array[TodoItem]
}

///|
/// Make `TodoWorld::default` an explicit method, so tests can pass it as the
/// World factory without the implicit-promotion deprecation warning.
pub extend TodoWorld with Default::{default}
