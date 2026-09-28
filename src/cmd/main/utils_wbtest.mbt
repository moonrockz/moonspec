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
