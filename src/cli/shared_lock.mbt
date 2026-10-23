///|
let shared_generation_lock = ".moonspec-generation.lock"

///|
// Native fs.create_dir uses an exclusive mkdir. The Wasm host and JS adapter
// use recursive mkdir, so they cannot provide this cross-process guard.
#cfg(target="native")
fn acquire_shared_generation_lock(
  _refresh : Bool,
) -> Bool raise @codegen.PlanError {
  let started = @env.now()
  while @env.now() - started < 10000UL {
    let acquired = try {
      @fs.create_dir(shared_generation_lock)
      true
    } catch {
      @fs.IOError(_) => false
    }
    if acquired {
      return true
    }
    shared_generation_pause()
  }
  raise @codegen.InvalidPlan(
    "generation is busy; if no generator is running, remove the stale " +
    shared_generation_lock +
    " directory",
  )
}

///|
#cfg(not(target="native"))
fn acquire_shared_generation_lock(
  refresh : Bool,
) -> Bool raise @codegen.PlanError {
  if refresh {
    raise @codegen.InvalidPlan(
      "automatic shared regeneration requires the local native moonspec CLI",
    )
  }
  false
}

///|
#cfg(target="native")
extern "C" fn shared_generation_pause() -> Unit = "moonspec_cli_generation_pause"
