///|
test "compile_pickles: single scenario produces one pickle" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://simple", "Feature: Simple\n\n  Scenario: S1\n    Given a step\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].name, "S1")
  assert_eq(pickles[0].uri, "test://simple")
  assert_eq(pickles[0].steps.length(), 1)
  assert_eq(pickles[0].steps[0].text, "a step")
}

///|
test "compile_pickles: background steps prepended" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://bg", "Feature: BG\n\n  Background:\n    Given setup\n\n  Scenario: S1\n    When action\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].steps.length(), 2)
  assert_eq(pickles[0].steps[0].text, "setup")
  assert_eq(pickles[0].steps[1].text, "action")
}

///|
test "compile_pickles: scenario outline expanded" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://outline", "Feature: Outline\n\n  Scenario Outline: Add\n    Given I have <a>\n\n    Examples:\n      | a   |\n      | one |\n      | two |\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 2)
  assert_eq(pickles[0].steps[0].text, "I have one")
  assert_eq(pickles[1].steps[0].text, "I have two")
}

///|
test "compile_pickles: tags inherited from feature and scenario" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://tags", "@feature-tag\nFeature: Tagged\n\n  @scenario-tag\n  Scenario: S1\n    Given a step\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  let tag_names = pickles[0].tags.map(fn(t) { t.name })
  assert_true(tag_names.contains("@feature-tag"))
  assert_true(tag_names.contains("@scenario-tag"))
}

///|
test "compile_pickles: step types mapped from keywords" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://types", "Feature: Types\n\n  Scenario: S1\n    Given context\n    When action\n    Then outcome\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].type_ {
    Some(Context) => ()
    _ => fail("expected Context")
  }
  match pickles[0].steps[1].type_ {
    Some(Action) => ()
    _ => fail("expected Action")
  }
  match pickles[0].steps[2].type_ {
    Some(Outcome) => ()
    _ => fail("expected Outcome")
  }
}

///|
test "compile_pickles: empty scenario produces no pickles" {
  let cache = FeatureCache::new()
  cache.load_text("test://empty", "Feature: Empty\n\n  Scenario: No steps\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 0)
}

///|
test "compile_pickles: multiple features from cache" {
  let cache = FeatureCache::new()
  cache.load_text("test://a", "Feature: A\n\n  Scenario: S1\n    Given a\n")
  cache.load_text("test://b", "Feature: B\n\n  Scenario: S2\n    Given b\n")
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 2)
}

///|
test "compile_pickles: unique pickle ids" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://multi", "Feature: Multi\n\n  Scenario: S1\n    Given a\n\n  Scenario: S2\n    Given b\n",
  )
  let pickles = compile_pickles(cache)
  assert_true(pickles[0].id != pickles[1].id)
}

///|
test "compile_pickles: step with doc string" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://docstring", "Feature: DocString\n\n  Scenario: S1\n    Given a payload\n      \"\"\"\n      hello world\n      \"\"\"\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  assert_eq(pickles[0].steps.length(), 1)
  assert_true(pickles[0].steps[0].argument is Some(_))
  match pickles[0].steps[0].argument {
    Some(arg) => {
      assert_true(arg.docString is Some(_))
      match arg.docString {
        Some(ds) => assert_eq(ds.content, "hello world")
        None => fail("expected docString")
      }
    }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: step with doc string media type" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://docstring-mt", "Feature: DocString\n\n  Scenario: S1\n    Given a payload\n      \"\"\"json\n      {\"key\": \"value\"}\n      \"\"\"\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.docString {
        Some(ds) => assert_eq(ds.mediaType, Some("json"))
        None => fail("expected docString")
      }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: step with data table" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://datatable", "Feature: DataTable\n\n  Scenario: S1\n    Given the following users\n      | name  | age |\n      | Alice | 30  |\n      | Bob   | 25  |\n",
  )
  let pickles = compile_pickles(cache)
  assert_eq(pickles.length(), 1)
  match pickles[0].steps[0].argument {
    Some(arg) => {
      assert_true(arg.dataTable is Some(_))
      match arg.dataTable {
        Some(dt) => {
          assert_eq(dt.rows.length(), 3)
          assert_eq(dt.rows[0].cells[0].value, "name")
          assert_eq(dt.rows[1].cells[0].value, "Alice")
        }
        None => fail("expected dataTable")
      }
    }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: outline substitutes in doc string" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://outline-ds", "Feature: Outline DS\n\n  Scenario Outline: S1\n    Given a payload\n      \"\"\"\n      hello <name>\n      \"\"\"\n\n    Examples:\n      | name  |\n      | Alice |\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.docString {
        Some(ds) => assert_eq(ds.content, "hello Alice")
        None => fail("expected docString")
      }
    None => fail("expected argument")
  }
}

///|
test "compile_pickles: outline substitutes in data table cells" {
  let cache = FeatureCache::new()
  cache.load_text(
    "test://outline-dt", "Feature: Outline DT\n\n  Scenario Outline: S1\n    Given the data\n      | col   |\n      | <val> |\n\n    Examples:\n      | val   |\n      | hello |\n",
  )
  let pickles = compile_pickles(cache)
  match pickles[0].steps[0].argument {
    Some(arg) =>
      match arg.dataTable {
        Some(dt) => assert_eq(dt.rows[1].cells[0].value, "hello")
        None => fail("expected dataTable")
      }
    None => fail("expected argument")
  }
}
