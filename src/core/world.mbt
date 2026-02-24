///|
/// Step registration trait. Users implement this on their world struct.
///
/// Called once per scenario with a fresh `Default`-constructed instance.
/// Closures registered via `Setup` capture `self`, sharing world
/// state between steps within the same scenario. Since MoonBit structs
/// are reference types, mutations through closures are visible to all
/// step handlers.
///
/// Example:
/// ```
/// struct MyWorld { mut count : Int } derive(Default)
///
/// impl @moonspec.World for MyWorld with configure(self, s) {
///   s.given("a count of {int}", fn(ctx) {
///     match ctx[0] { { value: IntVal(n), .. } => self.count = n; _ => () }
///   })
/// }
/// ```
pub(open) trait World {
  configure(Self, Setup) -> Unit
}
