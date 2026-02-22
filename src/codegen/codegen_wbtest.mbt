test "generate_test_file produces async test blocks" {
  let feature_content =
    "Feature: Login\n\n  Scenario: Valid credentials\n    Given a user\n    When they log in\n    Then they see the dashboard\n"
  let output = generate_test_file(feature_content, "features/login.feature")
  assert_true!(contains(output, "async test"))
  assert_true!(contains(output, "Feature: Login / Scenario: Valid credentials"))
  assert_true!(contains(output, "features/login.feature"))
}

test "generate_test_file includes hash for staleness detection" {
  let content = "Feature: X\n\n  Scenario: Y\n    Given z\n"
  let output = generate_test_file(content, "features/x.feature")
  assert_true!(contains(output, "// moonspec:hash:"))
}

test "feature_to_test_filename converts paths" {
  assert_eq!(
    feature_to_test_filename("features/login.feature"),
    "login_feature_test.mbt",
  )
  assert_eq!(
    feature_to_test_filename("features/admin/users.feature"),
    "admin_users_feature_test.mbt",
  )
}

test "generate_test_file handles scenario outline with examples" {
  let content =
    "Feature: Math\n\n  Scenario Outline: Add numbers\n    Given <a> and <b>\n    Then result is <sum>\n\n    Examples:\n      | a | b | sum |\n      | 1 | 2 | 3   |\n      | 4 | 5 | 9   |\n"
  let output = generate_test_file(content, "features/math.feature")
  assert_true!(contains(output, "async test"))
  assert_true!(contains(output, "a=1"))
  assert_true!(contains(output, "a=4"))
}

test "generate_test_file handles empty feature" {
  let content = "Feature: Empty\n"
  let output = generate_test_file(content, "features/empty.feature")
  assert_true!(contains(output, "// moonspec:hash:"))
  // Should not contain any async test blocks
  assert_true!(not(contains(output, "async test")))
}

test "simple_hash produces consistent output" {
  let h1 = simple_hash("hello")
  let h2 = simple_hash("hello")
  assert_eq!(h1, h2)
  // Different input should produce different hash
  let h3 = simple_hash("world")
  assert_true!(h1 != h3)
}
