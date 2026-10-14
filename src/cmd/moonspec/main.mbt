///|
/// The moonspec CLI. `moon install moonrockz/moonspec/cmd/moonspec` installs
/// it as `moonspec`; `moonx moonrockz/moonspec/cmd/moonspec` runs it without
/// an install.
fn main {
  @cli.run(@env.args())
}
