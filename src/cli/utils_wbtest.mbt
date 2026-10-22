///|
test "test_output_path writes into the current directory by default" {
  assert_eq(
    test_output_path(None, "features/login.feature", WhiteBox),
    "login_feature_wbtest.mbt",
  )
}

///|
test "test_output_path joins an output directory" {
  assert_eq(
    test_output_path(Some("src"), "features/login.feature", BlackBox),
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
      BlackBox,
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

///|
test "resolve_test_kind: the CLI value, then the config, then wbtest" {
  let empty = @config.MoonspecConfig::empty()
  let config_bb = @config.MoonspecConfig::from_json5("{ test_kind: \"test\" }")
  assert_eq(resolve_test_kind(None, empty), Ok(WhiteBox))
  assert_eq(resolve_test_kind(None, config_bb), Ok(BlackBox))
  assert_eq(resolve_test_kind(Some("wbtest"), config_bb), Ok(WhiteBox))
  assert_true(resolve_test_kind(Some("black"), empty) is Err(_))
}

///|
test "execution selection uses CLI then merged config then async" {
  let sync = @config.MoonspecConfig::from_json5("{ execution: 'sync' }")
  let async_ = @config.MoonspecConfig::from_json5("{ execution: 'async' }")
  assert_eq(resolve_execution(None, @config.MoonspecConfig::empty()), Ok(Async))
  assert_eq(resolve_execution(None, sync), Ok(Sync))
  assert_eq(resolve_execution(Some("async"), sync), Ok(Async))
  assert_eq(resolve_execution(Some("sync"), async_), Ok(Sync))
  match resolve_execution(Some("parallel"), sync) {
    Err(message) => {
      assert_true(message.contains("--execution"))
      assert_true(message.contains("async"))
      assert_true(message.contains("sync"))
    }
    Ok(_) => fail("invalid CLI execution accepted")
  }
}

///|
test "gen tests and gen build accept the execution option" {
  for command in ["tests", "build"] {
    let matches = build_parser().parse(argv=[
      "gen", command, "features/login.feature", "--execution", "sync",
    ])
    guard matches.subcommand is Some(("gen", gen)) else { fail("missing gen") }
    guard gen.subcommand is Some((_, args)) else { fail("missing subcommand") }
    assert_eq(option_value(args, "execution"), Some("sync"))
  }
}

///|
fn cli_temp_dir(label : String) -> String raise Error {
  let entropy = match @env.rand(16) {
    Some(bytes) => bytes
    None => fail("host randomness is required for isolated CLI fixtures")
  }
  let nonce = StringBuilder()
  for i = 0; i < entropy.length(); i = i + 1 {
    nonce.write_string(entropy[i].to_int().to_string())
    nonce.write_string("-")
  }
  let path = "/tmp/moonspec-codegen-" + label + "-" + nonce.to_string()
  @fs.create_dir(path)
  path
}

///|
test "gen tests passes CLI sync execution through to emitted source" {
  let temp_dir = cli_temp_dir("tests")
  let feature = temp_dir + "/input.feature"
  let output = temp_dir + "/generated.mbt"
  @fs.write_string_to_file(
    feature, "Feature: CLI\n  Scenario: A\n    Given a user\n",
  )
  let matches = build_parser().parse(argv=[
    "gen", "tests", feature, "-w", "MyWorld", "-o", output, "--execution", "sync",
  ])
  guard matches.subcommand is Some((_, gen)) else { fail("missing gen") }
  guard gen.subcommand is Some((_, args)) else { fail("missing tests") }
  cmd_gen_tests(args)
  let generated = @fs.read_file_to_string(output)
  @fs.remove_file(output)
  @fs.remove_file(feature)
  @fs.remove_dir(temp_dir)
  assert_true(generated.contains("@moonspec.run_or_fail_sync("))
  assert_false(generated.contains("async test"))
}

///|
test "gen build apply carries sync execution to the rule and initial test file" {
  let package_dir = cli_temp_dir("build")
  let feature = package_dir + "/input.feature"
  @fs.write_string_to_file(
    feature, "Feature: Build\n  Scenario: A\n    Given a user\n",
  )
  let matches = build_parser().parse(argv=[
    "gen", "build", feature, "-w", "MyWorld", "--package", package_dir, "--execution",
    "sync", "--apply",
  ])
  guard matches.subcommand is Some((_, gen)) else { fail("missing gen") }
  guard gen.subcommand is Some((_, args)) else { fail("missing build") }
  cmd_gen_build(args)
  let rules = @fs.read_file_to_string(package_dir + "/moon.pkg")
  let output = package_dir + "/" + @codegen.build_rules_test_filename(feature)
  let generated = @fs.read_file_to_string(output)
  @fs.remove_file(output)
  @fs.remove_file(package_dir + "/moon.pkg")
  @fs.remove_file(feature)
  @fs.remove_dir(package_dir)
  assert_true(rules.contains("--execution sync"))
  assert_true(generated.contains("@moonspec.run_or_fail_sync("))
}
