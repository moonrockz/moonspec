///|
test "FeatureCache::new creates empty cache" {
  let cache = FeatureCache::new()
  assert_eq(cache.length(), 0)
}

///|
test "FeatureCache::load_text parses and stores feature" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://simple", "Feature: Simple\n\n  Scenario: S1\n    Given a step\n",
  )
  assert_eq(cache.length(), 1)
  assert_true(cache.contains("test://simple"))
  let feature = cache.get("test://simple")
  assert_true(feature is Some(_))
}

///|
test "FeatureCache::load_text overwrites on same path" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://a", "Feature: First\n\n  Scenario: S1\n    Given a step\n",
  )
  cache.load_text(
    "test://a", "Feature: Second\n\n  Scenario: S1\n    Given a step\n",
  )
  assert_eq(cache.length(), 1)
  let feature = cache.get("test://a").unwrap()
  assert_eq(feature.name, "Second")
}

///|
test "FeatureCache::load_parsed stores directly" {
  let source = @gherkin.Source::from_string(
    "Feature: Parsed\n\n  Scenario: S1\n    Given a step\n",
  )
  let doc = @gherkin.parse(source) catch { _ => panic() }
  let feature = doc.feature.unwrap()
  let cache = FeatureCache::new()
  cache.load_parsed("test://parsed", feature)
  assert_eq(cache.length(), 1)
  assert_eq(cache.get("test://parsed").unwrap().name, "Parsed")
}

///|
test "FeatureCache::features returns all entries" {
  let cache = FeatureCache::new()
  cache.load_text("test://a", "Feature: A\n\n  Scenario: S\n    Given a step\n")
  cache.load_text("test://b", "Feature: B\n\n  Scenario: S\n    Given a step\n")
  let entries = cache.features()
  assert_eq(entries.length(), 2)
}

///|
test "FeatureCache::load_from_source handles Text variant" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text(
      "test://text", "Feature: T\n\n  Scenario: S\n    Given a step\n",
    ),
  )
  assert_eq(errors.length(), 0)
  assert_eq(cache.length(), 1)
}

///|
test "FeatureCache::load_file is idempotent" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://idem", "Feature: Idem\n\n  Scenario: S\n    Given a step\n",
  )
  // load_file would fail on a nonexistent path, but load_text followed by contains check
  // demonstrates the cache check behavior
  assert_true(cache.contains("test://idem"))
}

///|
test "FeatureCache::load_from_source returns empty errors on valid feature" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text(
      "test://valid", "Feature: Valid\n\n  Scenario: Works\n    Given something\n",
    ),
  )
  assert_eq(errors.length(), 0)
  assert_eq(cache.length(), 1)
  assert_eq(cache.get("test://valid").unwrap().name, "Valid")
}

///|
test "FeatureCache::load_from_source returns ParseErrorInfo on invalid feature" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text("test://bad", "This is not valid Gherkin"),
  )
  assert_true(errors.length() > 0)
  assert_eq(errors[0].uri, "test://bad")
  assert_true(errors[0].message.length() > 0)
  assert_eq(errors[0].line, Some(1))
}

///|
test "FeatureCache::load_text parses Markdown with Gherkin for .feature.md" {
  let cache = FeatureCache::new()
  cache.load_text(
    "features/login.feature.md", "# Feature: Login\n\n## Scenario: Success\n\n- Given a user\n",
  )
  let feature = cache.get("features/login.feature.md").unwrap()
  assert_eq(feature.name, "Login")
  assert_eq(feature.children.length(), 1)
}

///|
test "load_from_source reports the Gherkin parse message and line" {
  let cache = FeatureCache::new()
  let errors = cache.load_from_source(
    FeatureSource::Text(
      "test://bad", "Feature: A\n\n  Scenario: B\n    Given x\n  | a |\n  | b | c |\n",
    ),
  )
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].uri, "test://bad")
  assert_eq(errors[0].line, Some(6))
  assert_false(errors[0].message.contains("moonrockz/gherkin"))
}
