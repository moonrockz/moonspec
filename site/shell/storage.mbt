///|
#cfg(target="js")
extern "js" fn js_get_theme() -> String =
  #|() => { try { return localStorage.getItem('moonspec-theme') ?? '' } catch (_) { return '' } }

///|
#cfg(target="js")
extern "js" fn js_set_theme(value : String) -> Unit =
  #|(v) => { try { localStorage.setItem('moonspec-theme', v) } catch (_) {} }

///|
#cfg(target="js")
extern "js" fn js_focus(id : String) -> Unit =
  #|(id) => { setTimeout(() => document.getElementById(id)?.focus(), 0) }

///|
#cfg(target="js")
pub fn read_theme() -> Theme {
  Theme::parse(js_get_theme())
}

///|
#cfg(not(target="js"))
pub fn read_theme() -> Theme {
  Auto
}

///|
#cfg(target="js")
fn store_theme(theme : Theme) -> Unit {
  js_set_theme(theme.to_string())
}

///|
#cfg(not(target="js"))
fn store_theme(_theme : Theme) -> Unit {
  ()
}

///|
#cfg(target="js")
fn focus(id : String) -> Unit {
  js_focus(id)
}

///|
#cfg(not(target="js"))
fn focus(_id : String) -> Unit {
  ()
}

///|
/// Runs a side effect. `effect` exists only on the JS target, so native
/// builds (used for tests) skip it.
#cfg(target="js")
fn run_effect(f : () -> Unit) -> @rabbita.Cmd {
  @rabbita.effect(fn() noraise { f() })
}

///|
#cfg(not(target="js"))
fn run_effect(_f : () -> Unit) -> @rabbita.Cmd {
  @rabbita.none
}
