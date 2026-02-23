// End-to-end integration test: parse source -> extract attributes -> generate code

///|
test "end-to-end: scan and generate from attributed source" {
  let source =
    #|struct CucumberWorld { mut cucumbers : Int } derive(Default)
    #|
    #|#moonspec.given("I have {int} cucumbers")
    #|fn set_cukes(self : CucumberWorld, count : Int) -> Unit {
    #|  self.cucumbers = count
    #|}
    #|
    #|#moonspec.when("I eat {int} cucumbers")
    #|fn eat_cukes(self : CucumberWorld, count : Int) -> Unit {
    #|  self.cucumbers = self.cucumbers - count
    #|}
    #|
    #|#moonspec.then("I should have {int} cucumbers")
    #|fn check_cukes(self : CucumberWorld, count : Int) -> Unit raise Error {
    #|  assert_eq(self.cucumbers, count)
    #|}
  let result = scan_source(source, "test.mbt")
  assert_eq(result.step_fns.length(), 3)
  // Group by world type
  let steps = result.step_fns
  assert_eq(steps[0].world_type, "CucumberWorld")
  // Generate
  let code = generate_configure("CucumberWorld", steps, source_hash="test123")
  // Verify generated code structure
  assert_true(str_contains(code, "impl @moonspec.World for CucumberWorld"))
  assert_true(str_contains(code, "set_cukes(self"))
  assert_true(str_contains(code, "eat_cukes(self"))
  assert_true(str_contains(code, "check_cukes(self"))
}
