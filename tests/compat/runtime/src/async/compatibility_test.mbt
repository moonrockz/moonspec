///|
async test "public async sequential executes every reusable fixture" {
  for (label, path) in @shared.fixtures() {
    let fixture = @shared.fixture(label, path)
    let result = @moonspec.run(() => fixture.world(), fixture.options)
    fixture.emit(label, result)
  }
}
