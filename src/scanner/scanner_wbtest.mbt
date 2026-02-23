///|
test "extract given attribute from method with self" {
  let source =
    #|#moonspec.given("I have {int} cucumbers")
    #|fn set_cucumbers(self : MyWorld, count : Int) -> Unit {
    #|  self.cucumbers = count
    #|}
  let result = scan_source(source, "steps.mbt")
  assert_eq(result.step_fns.length(), 1)
  let step = result.step_fns[0]
  assert_eq(step.keyword, "given")
  assert_eq(step.pattern, "I have {int} cucumbers")
  assert_eq(step.fn_name, "set_cucumbers")
  assert_eq(step.world_type, "MyWorld")
  assert_eq(step.params.length(), 1)
  assert_eq(step.params[0].name, "count")
  assert_eq(step.params[0].type_name, "Int")
  assert_eq(step.source_file, "steps.mbt")
  assert_eq(step.is_method, true)
}

///|
test "extract world config with init" {
  let source = "#moonspec.world(init = \"Self::new\")\nstruct MyWorld {\n  mut cucumbers : Int\n}\n"
  let result = scan_source(source, "world.mbt")
  assert_eq(result.world_configs.length(), 1)
  let world = result.world_configs[0]
  assert_eq(world.type_name, "MyWorld")
  assert_eq(world.init_fn, Some("Self::new"))
  assert_eq(world.source_file, "world.mbt")
}

///|
test "extract world config without init" {
  let source =
    #|#moonspec.world
    #|struct SimpleWorld {
    #|  mut value : Int
    #|}
  let result = scan_source(source, "world.mbt")
  assert_eq(result.world_configs.length(), 1)
  let world = result.world_configs[0]
  assert_eq(world.type_name, "SimpleWorld")
  assert_eq(world.init_fn, None)
}

///|
test "multiple step keywords in one file" {
  let source =
    #|#moonspec.given("a user named {string}")
    #|fn set_user(self : World, name : String) -> Unit {
    #|  self.name = name
    #|}
    #|
    #|#moonspec.when("the user logs in")
    #|fn user_logs_in(self : World) -> Unit {
    #|  self.logged_in = true
    #|}
    #|
    #|#moonspec.then("the user should be greeted")
    #|fn check_greeting(self : World) -> Unit {
    #|  ()
    #|}
  let result = scan_source(source, "multi.mbt")
  assert_eq(result.step_fns.length(), 3)
  assert_eq(result.step_fns[0].keyword, "given")
  assert_eq(result.step_fns[1].keyword, "when")
  assert_eq(result.step_fns[2].keyword, "then")
  assert_eq(result.step_fns[0].fn_name, "set_user")
  assert_eq(result.step_fns[1].fn_name, "user_logs_in")
  assert_eq(result.step_fns[2].fn_name, "check_greeting")
}

///|
test "standalone function (non-method)" {
  let source =
    #|#moonspec.given("a standalone step")
    #|fn standalone_step(world : World) -> Unit {
    #|  ()
    #|}
  let result = scan_source(source, "standalone.mbt")
  assert_eq(result.step_fns.length(), 1)
  let step = result.step_fns[0]
  assert_eq(step.fn_name, "standalone_step")
  assert_eq(step.world_type, "World")
  assert_eq(step.is_method, false)
  assert_eq(step.params.length(), 0)
}

///|
test "ignore functions without moonspec attributes" {
  let source =
    #|fn regular_function(x : Int) -> Int {
    #|  x + 1
    #|}
    #|
    #|#moonspec.given("a step")
    #|fn actual_step(self : W) -> Unit {
    #|  ()
    #|}
    #|
    #|fn another_regular() -> Unit {
    #|  ()
    #|}
  let result = scan_source(source, "mixed.mbt")
  assert_eq(result.step_fns.length(), 1)
  assert_eq(result.step_fns[0].fn_name, "actual_step")
  assert_eq(result.world_configs.length(), 0)
}
