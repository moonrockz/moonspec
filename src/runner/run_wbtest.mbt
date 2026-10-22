///|
test "parse_retry_tag returns None when no retry tag" {
  let result = parse_retry_tag(["@smoke", "@slow"])
  assert_eq(result, None)
}

///|
test "parse_retry_tag extracts count from @retry(N)" {
  let result = parse_retry_tag(["@smoke", "@retry(3)"])
  assert_eq(result, Some(3))
}

///|
test "parse_retry_tag returns None for empty tags" {
  let result = parse_retry_tag([])
  assert_eq(result, None)
}

///|
test "parse_retry_tag handles @retry(1)" {
  let result = parse_retry_tag(["@retry(1)"])
  assert_eq(result, Some(1))
}

///|
test "parse_retry_tag clamps large values to 100" {
  let result = parse_retry_tag(["@retry(99999)"])
  assert_eq(result, Some(100))
}

///|
test "parse_retry_tag allows value at cap boundary" {
  let result = parse_retry_tag(["@retry(100)"])
  assert_eq(result, Some(100))
}

///|
test "gherkin_media_type selects markdown for .feature.md" {
  assert_eq(
    gherkin_media_type("features/a.feature"),
    "text/x.cucumber.gherkin+plain",
  )
  assert_eq(
    gherkin_media_type("features/a.feature.md"),
    "text/x.cucumber.gherkin+markdown",
  )
}

///|
test "RunOptions no_color defaults to false" {
  let options = RunOptions([])
  assert_false(options.get_no_color())
  options.no_color(true)
  assert_true(options.get_no_color())
}
