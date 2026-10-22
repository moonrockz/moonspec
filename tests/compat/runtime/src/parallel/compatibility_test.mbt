///|
async test "public async bounded parallel executes every reusable fixture" {
  for (label, path) in @shared.fixtures() {
    let fixture = @shared.fixture(label, path)
    fixture.options.parallel(true)
    fixture.options.max_concurrent(2)
    let result = @moonspec.run(() => fixture.world(), fixture.options)
    fixture.emit(label, result)
  }
}
