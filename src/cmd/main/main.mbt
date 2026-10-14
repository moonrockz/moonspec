///|
/// Deprecated alias of `moonrockz/moonspec/cmd/moonspec`.
///
/// `moon install` names the binary after the package directory, so this
/// package installs as `main`. Use `moonrockz/moonspec/cmd/moonspec`, which
/// installs as `moonspec`.
fn main {
  @cli.warn_deprecated_entry_point()
  @cli.run(@env.args())
}
