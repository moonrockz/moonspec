///|
test "public sync executes every reusable fixture" {
  for (label, path) in @shared.fixtures() {
    let fixture = @shared.fixture(label, path)
    let result = @moonspec.run_sync(() => fixture.world(), fixture.options)
    fixture.emit(label, result)
  }
}
