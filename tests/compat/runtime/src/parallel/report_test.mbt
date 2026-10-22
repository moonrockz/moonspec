///|
async test "run_or_fail keeps structured errors and useful reports" {
  for (label, path) in @shared.fixtures() {
    let fixture = @shared.fixture(label, path)
    fixture.options.parallel(true)
    fixture.options.max_concurrent(2)
    fixture.options.no_color(true)
    let report = try {
      @moonspec.run_or_fail(() => fixture.world(), fixture.options)
      ""
    } catch {
      @core.RunFailed(summary~, errors~, color~) as error => {
        assert_true(summary.length() > 0)
        assert_true(errors.length() > 0)
        assert_false(color)
        error.to_string()
      }
      error => fail("unexpected error: " + error.to_string())
    }
    @shared.verify_report(label, report)
    let value : Json = { "fixture": Json(label), "report": Json(report) }
    println("REPORT:" + value.stringify())
  }
}
