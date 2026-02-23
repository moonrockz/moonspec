///|
test "detect_manual_registration finds impl World block" {
  let source =
    #|impl @moonspec.World for MyWorld with register_steps(self, s) {
    #|  s.given("something", fn(args) { () })
    #|}
  assert_true(has_manual_registration(source, "MyWorld"))
}

///|
test "detect_manual_registration returns false for other types" {
  let source =
    #|impl @moonspec.World for OtherWorld with register_steps(self, s) {
    #|  s.given("something", fn(args) { () })
    #|}
  assert_true(not(has_manual_registration(source, "MyWorld")))
}

///|
test "detect_manual_registration returns false for unrelated code" {
  let source =
    #|fn some_function() -> Unit {
    #|  ()
    #|}
  assert_true(not(has_manual_registration(source, "MyWorld")))
}

///|
test "detect_manual_registration returns false for empty string" {
  assert_true(not(has_manual_registration("", "MyWorld")))
}
