///|
test "test_output_path writes into the current directory by default" {
  assert_eq(
    test_output_path(None, "features/login.feature"),
    "login_feature_test.mbt",
  )
}

///|
test "test_output_path joins an output directory" {
  assert_eq(
    test_output_path(Some("src"), "features/login.feature"),
    "src/login_feature_test.mbt",
  )
}

///|
test "test_output_path uses an .mbt output as the exact file path" {
  // moon pre-build runs from the module root with `-o $output`
  assert_eq(
    test_output_path(
      Some("./src/todolist_feature_wbtest.mbt"),
      "./features/todolist.feature",
    ),
    "./src/todolist_feature_wbtest.mbt",
  )
}

///|
test "resolve_no_color: the CLI flag or the config turns color off" {
  let empty = @config.MoonspecConfig::empty()
  let config_on = @config.MoonspecConfig::from_json5("{ no_color: true }")
  assert_false(resolve_no_color(false, empty))
  assert_true(resolve_no_color(true, empty))
  assert_true(resolve_no_color(false, config_on))
}

///|
test "steps_output_mode defaults to alongside" {
  // The World impl must live in the package of the world type, so the
  // default writes the generated file next to the step definitions.
  assert_eq(steps_output_mode(None), "alongside")
  assert_eq(
    steps_output_mode(Some({ output: None, exclude: None, })),
    "alongside",
  )
}

///|
test "steps_output_mode uses the configured output" {
  assert_eq(
    steps_output_mode(Some({ output: Some("per-package"), exclude: None, })),
    "per-package",
  )
}
