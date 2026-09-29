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
      #|  command: "moonspec gen tests $input -w CalcWorld -o $output",
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
    #|  command: "moonspec gen tests $input -w CalcWorld -o $output",
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
