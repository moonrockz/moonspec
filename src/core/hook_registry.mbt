///|
/// The six Cucumber lifecycle hook types.
pub(all) enum HookType {
  BeforeTestRun
  AfterTestRun
  BeforeTestCase
  AfterTestCase
  BeforeTestStep
  AfterTestStep
} derive(Show, Eq)

///|
/// Typed handler for different hook scopes.
pub(all) enum HookHandler {
  RunHandler(() -> Unit raise Error)
  CaseHandler((ScenarioInfo, String?) -> Unit raise Error)
  StepHandler((StepInfo, String?) -> Unit raise Error)
}

///|
/// A registered hook entry with id, type, handler, and source location.
pub(all) struct RegisteredHook {
  id : String
  type_ : HookType
  handler : HookHandler
  source : StepSource?
}

///|
/// Registry of lifecycle hooks with auto-incrementing IDs.
pub(all) struct HookRegistry {
  priv hooks_ : Array[RegisteredHook]
  priv mut counter : Int
}

///|
/// Create an empty hook registry.
pub fn HookRegistry::new() -> HookRegistry {
  { hooks_: [], counter: 0 }
}

///|
/// Register a hook with the given type, handler, and optional source location.
pub fn HookRegistry::add(
  self : HookRegistry,
  type_ : HookType,
  handler : HookHandler,
  source~ : StepSource? = None,
) -> Unit {
  self.counter += 1
  let id = "hook-" + self.counter.to_string()
  self.hooks_.push({ id, type_, handler, source })
}

///|
/// Return all registered hooks as a read-only ArrayView.
pub fn HookRegistry::hooks(self : HookRegistry) -> ArrayView[RegisteredHook] {
  self.hooks_[:]
}

///|
/// Return all registered hooks matching the given type.
pub fn HookRegistry::by_type(
  self : HookRegistry,
  type_ : HookType,
) -> Array[RegisteredHook] {
  self.hooks_.filter(fn(h) { h.type_ == type_ })
}
