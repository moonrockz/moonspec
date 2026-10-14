///|
test "detect_manual_registration finds impl World block" {
  let source =
    #|impl @moonspec.World for MyWorld with configure(self, setup) {
    #|  s.given("something", fn(ctx) { () })
    #|}
  assert_true(has_manual_registration(source, "MyWorld"))
}

///|
test "detect_manual_registration returns false for other types" {
  let source =
    #|impl @moonspec.World for OtherWorld with configure(self, setup) {
    #|  s.given("something", fn(ctx) { () })
    #|}
  assert_true(!has_manual_registration(source, "MyWorld"))
}

///|
test "detect_manual_registration returns false for unrelated code" {
  let source =
    #|fn some_function() -> Unit {
    #|  ()
    #|}
  assert_true(!has_manual_registration(source, "MyWorld"))
}

///|
test "detect_manual_registration returns false for empty string" {
  assert_true(!has_manual_registration("", "MyWorld"))
}

///|
test "has_manual_registration ignores the gen steps output" {
  // gen steps writes its output next to the step functions, so the next
  // scan reads it. Its impl is not a manual registration.
  let generated = generate_configure("MyWorld", [], source_hash="00000000")
  assert_false(has_manual_registration(generated, "MyWorld"))
}
