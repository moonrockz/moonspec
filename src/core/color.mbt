///|
/// Decide whether moonspec output uses ANSI colors.
///
/// `no_color` is the value compiled into the test (from `RunOptions`,
/// `moonspec.json5` or `moonspec gen tests --no-color`). Environment variables
/// override it at runtime:
///
/// - `MOONSPEC_COLOR=always` or `MOONSPEC_COLOR=never` forces color on or off.
/// - `NO_COLOR` with any non-empty value turns color off (https://no-color.org).
pub fn color_enabled(no_color? : Bool = false) -> Bool {
  match @env.get_env_var("MOONSPEC_COLOR") {
    Some("always") => return true
    Some("never") => return false
    _ => ()
  }
  match @env.get_env_var("NO_COLOR") {
    Some(value) if value != "" => false
    _ => !no_color
  }
}

///|
/// ANSI color codes used by the failure report.
priv enum Color {
  Green
  Red
  Yellow
  Cyan
}

///|
/// Wrap `text` in the ANSI code for `c` when `color` is true.
fn paint(text : String, c : Color, color : Bool) -> String {
  if !color {
    return text
  }
  let code = match c {
    Green => "32"
    Red => "31"
    Yellow => "33"
    Cyan => "36"
  }
  "\u001b[" + code + "m" + text + "\u001b[0m"
}
