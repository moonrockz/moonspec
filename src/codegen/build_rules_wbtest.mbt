///|
test "render_build_rules adds a rule and one dev_build per feature" {
  let (content, added) = render_build_rules(
    "",
    ["features/add.feature", "features/nested/sub.feature"],
    package_dir="src",
    world="CalcWorld",
  )
  assert_eq(added, 3)
  inspect(
    content,
    content=(
      #|rule(
      #|  name: "moonspec-tests",
      #|  command: "moonspec gen tests $input -w CalcWorld --execution async -o $output",
      #|)
      #|
      #|dev_build(
      #|  rule: "moonspec-tests",
      #|  input: "../features/add.feature",
      #|  output: "add_feature_wbtest.mbt",
      #|)
      #|
      #|dev_build(
      #|  rule: "moonspec-tests",
      #|  input: "../features/nested/sub.feature",
      #|  output: "nested_sub_feature_wbtest.mbt",
      #|)
      #|
    ),
  )
}

///|
test "render_build_rules keeps existing content and adds only missing entries" {
  let existing =
    #|import {
    #|  "moonrockz/moonspec",
    #|}
    #|
    #|rule(
    #|  name: "moonspec-tests",
    #|  command: "moonspec gen tests $input -w CalcWorld --execution async -o $output",
    #|)
    #|
    #|dev_build(
    #|  rule: "moonspec-tests",
    #|  input: "../features/add.feature",
    #|  output: "add_feature_wbtest.mbt",
    #|)
    #|
  let (content, added) = render_build_rules(
    existing,
    ["features/add.feature", "features/sub.feature"],
    package_dir="src",
    world="CalcWorld",
  )
  assert_eq(added, 1)
  assert_true(content.has_prefix(existing))
  assert_true(
    content.has_suffix(
      "\ndev_build(\n  rule: \"moonspec-tests\",\n  input: \"../features/sub.feature\",\n  output: \"sub_feature_wbtest.mbt\",\n)\n",
    ),
  )
}

///|
test "render_build_rules changes nothing on a second run" {
  let features = ["features/add.feature"]
  let (once, _) = render_build_rules(
    "import {\n}\n",
    features,
    package_dir="src",
    world="CalcWorld",
  )
  let (twice, added) = render_build_rules(
    once,
    features,
    package_dir="src",
    world="CalcWorld",
  )
  assert_eq(added, 0)
  assert_eq(twice, once)
}

///|
test "render_build_rules separates new entries from content without a trailing newline" {
  let (content, _) = render_build_rules(
    "import {\n}",
    ["features/add.feature"],
    package_dir="src",
    world="W",
  )
  assert_true(content.has_prefix("import {\n}\n\nrule(\n"))
  let (content, _) = render_build_rules(
    "import {\n}\n\n\n",
    ["features/add.feature"],
    package_dir="src",
    world="W",
  )
  assert_true(content.has_prefix("import {\n}\n\nrule(\n"))
}

///|
test "relative_to_package walks up from the package directory" {
  assert_eq(
    relative_to_package("features/a.feature", "src"),
    "../features/a.feature",
  )
  assert_eq(
    relative_to_package("./features/a.feature", "./src/lib/"),
    "../../features/a.feature",
  )
  assert_eq(
    relative_to_package("features/a.feature", "."),
    "features/a.feature",
  )
  assert_eq(relative_to_package("src/a.feature", "src"), "a.feature")
  assert_eq(relative_to_package("/abs/a.feature", "src"), "/abs/a.feature")
}

///|
test "build_rules_test_filename uses the white-box test suffix" {
  assert_eq(
    build_rules_test_filename("features/add.feature"),
    "add_feature_wbtest.mbt",
  )
  assert_eq(
    build_rules_test_filename("features/guide.feature.md"),
    "guide_feature_wbtest.mbt",
  )
}

///|
test "render_build_rules runs the CLI through moonx when asked" {
  let (content, _) = render_build_rules(
    "",
    ["features/add.feature"],
    package_dir="src",
    world="CalcWorld",
    cli=Moonx(version="0.10.2"),
  )
  inspect(
    content,
    content=(
      #|rule(
      #|  name: "moonspec-tests",
      #|  command: "moonx moonrockz/moonspec/cmd/moonspec@0.10.2 gen tests $input -w CalcWorld -o $output",
      #|)
      #|
      #|dev_build(
      #|  rule: "moonspec-tests",
      #|  input: "../features/add.feature",
      #|  output: "add_feature_wbtest.mbt",
      #|)
      #|
    ),
  )
}

///|
test "CliCommand renders the command prefix" {
  assert_eq(Installed.prefix(), "moonspec")
  assert_eq(
    Moonx(version="1.2.3").prefix(),
    "moonx moonrockz/moonspec/cmd/moonspec@1.2.3",
  )
}

///|
test "render_build_rules names black-box test files on request" {
  let (content, _) = render_build_rules(
    "",
    ["features/add.feature"],
    package_dir="src",
    world="CalcWorld",
    test_kind=BlackBox,
  )
  assert_true(content.contains("output: \"add_feature_test.mbt\""))
  assert_eq(
    build_rules_test_filename("features/add.feature", kind=BlackBox),
    "add_feature_test.mbt",
  )
}

///|
test "build rules pin sync execution for regeneration and keep file visibility independent" {
  for kind in [@config.TestKind::WhiteBox, BlackBox] {
    let (content, added) = render_build_rules(
      "",
      ["features/login.feature"],
      package_dir="src",
      world="MyWorld",
      execution=Sync,
      test_kind=kind,
    )
    assert_eq(added, 2)
    assert_true(
      content.contains(
        "gen tests $input -w MyWorld --execution sync -o $output",
      ),
    )
    assert_true(
      content.contains(
        build_rules_test_filename("features/login.feature", kind~),
      ),
    )
    let (again, count) = render_build_rules(
      content,
      ["features/login.feature"],
      package_dir="src",
      world="MyWorld",
      execution=Sync,
      test_kind=kind,
    )
    assert_eq(again, content)
    assert_eq(count, 0)
  }
}

///|
test "changing execution updates an existing generated rule before regeneration" {
  let features = ["features/login.feature"]
  let (async_rules, _) = render_build_rules(
    "",
    features,
    package_dir="src",
    world="MyWorld",
  )
  let (sync_rules, changed) = render_build_rules(
    async_rules,
    features,
    package_dir="src",
    world="MyWorld",
    execution=Sync,
  )
  assert_eq(changed, 1)
  assert_true(sync_rules.contains("--execution sync"))
  assert_false(sync_rules.contains("--execution async"))
  assert_eq(sync_rules.split("dev_build(").count(), 2)
}

///|
test "legacy build rules gain an explicit execution choice" {
  let legacy = "rule(\n  name: \"moonspec-tests\",\n  command: \"moonspec gen tests $input -w MyWorld -o $output\",\n)\n"
  let (updated, count) = render_build_rules(
    legacy,
    [],
    package_dir="src",
    world="MyWorld",
    execution=Sync,
  )
  assert_eq(count, 1)
  assert_true(updated.contains("--execution sync"))
  let (async_, _) = render_build_rules(
    updated,
    [],
    package_dir="src",
    world="MyWorld",
    execution=Async,
  )
  assert_true(async_.contains("--execution async"))
}

///|
test "registry 0.11.0 async build rules omit unsupported execution flags" {
  let (content, _) = render_build_rules(
    "",
    ["features/login.feature"],
    package_dir="src",
    world="MyWorld",
    cli=Moonx(version="0.11.0"),
  )
  assert_true(
    content.contains("moonx moonrockz/moonspec/cmd/moonspec@0.11.0 gen tests"),
  )
  assert_false(content.contains("--execution"))
}

///|
test "registry 0.11.0 sync build rules reject the incapable CLI" {
  let rejected = try {
    ignore(
      render_build_rules(
        "",
        [],
        package_dir="src",
        world="MyWorld",
        cli=Moonx(version="0.11.0"),
        execution=Sync,
      ),
    )
    false
  } catch {
    UnsupportedExecution(version~) => version == "0.11.0"
    _ => false
  }
  assert_true(rejected)
}

///|
test "unknown and prerelease registry pins reject both execution modes" {
  for
    version in [
      "latest", "0.12.0-rc.1", "0.12", "v0.12.0", "0.12.0+local", "0.012.0", "0.12.invalid",
    ] {
    for execution in [@config.ExecutionMode::Async, Sync] {
      let rejected = try {
        ignore(
          render_build_rules(
            "",
            [],
            package_dir="src",
            world="MyWorld",
            cli=Moonx(version~),
            execution~,
          ),
        )
        false
      } catch {
        UnsupportedVersion(..) => true
        _ => false
      }
      assert_true(rejected)
    }
  }
}

///|
test "stable capable registry pins retain explicit execution selection" {
  for version in ["0.12.0", "0.12.1", "0.13.0", "0.100.0", "1.0.0"] {
    for execution in [@config.ExecutionMode::Async, Sync] {
      let (content, _) = render_build_rules(
        "",
        [],
        package_dir="src",
        world="MyWorld",
        cli=Moonx(version~),
        execution~,
      )
      assert_true(content.contains("moonspec@" + version + " gen tests"))
      let mode = match execution {
        Async => "async"
        Sync => "sync"
      }
      assert_true(content.contains("--execution " + mode))
    }
  }
}

///|
test "canonical regeneration updates prefix and removes unsupported flags while retaining other arguments" {
  let unrelated = "import {\n}\n\nrule(\n  name: \"other\",\n  command: \"echo --execution sync\",\n)\n\n"
  let legacy = unrelated +
    "rule(\n  name: \"moonspec-tests\",\n  command: \"moonx moonrockz/moonspec/cmd/moonspec@0.11.0 gen tests $input -w MyWorld --mode per-feature --execution sync --no-color -o $output\",\n)\n"
  let (installed, changed) = render_build_rules(
    legacy,
    [],
    package_dir="src",
    world="MyWorld",
    execution=Sync,
  )
  assert_eq(changed, 1)
  assert_true(installed.has_prefix(unrelated))
  assert_true(installed.contains("command: \"moonspec gen tests"))
  assert_true(
    installed.contains("--mode per-feature --execution sync --no-color"),
  )
  let (old_pin, changed) = render_build_rules(
    installed,
    [],
    package_dir="src",
    world="MyWorld",
    cli=Moonx(version="0.11.0"),
  )
  assert_eq(changed, 1)
  assert_true(old_pin.has_prefix(unrelated))
  assert_true(
    old_pin.contains(
      "command: \"moonx moonrockz/moonspec/cmd/moonspec@0.11.0 gen tests",
    ),
  )
  assert_true(old_pin.contains("--mode per-feature --no-color -o $output"))
  let (again, changed) = render_build_rules(
    old_pin,
    [],
    package_dir="src",
    world="MyWorld",
    cli=Moonx(version="0.11.0"),
  )
  assert_eq(again, old_pin)
  assert_eq(changed, 0)
}
