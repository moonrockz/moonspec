///|
priv struct TodoItem {
  title : String
  mut completed : Bool
}

///|
#moonspec.world
struct TodoWorld {
  todos : Array[TodoItem]
} derive(Default)
