///|
test "File inputs preserve valid scenarios and structured read errors" {
  let options = @moonspec.RunOptions([
    @moonspec.FeatureSource::File("fixtures/passing.feature"),
    @moonspec.FeatureSource::File("fixtures/does-not-exist.feature"),
  ])
  let result = @moonspec.run_sync(() => @shared.portable_world(), options)
  assert_eq(result.summary.passed, 1)
  assert_eq(result.parse_errors.length(), 1)
  assert_eq(result.parse_errors[0].uri, "fixtures/does-not-exist.feature")
  assert_true(result.parse_errors[0].message.length() > 0)
  options.no_color(true)
  let report = try {
    @moonspec.run_or_fail_sync(() => @shared.portable_world(), options)
    ""
  } catch {
    @core.RunFailed(errors~, ..) as error => {
      assert_true(
        errors[0]
        is @core.ParseFailed(uri="fixtures/does-not-exist.feature", ..),
      )
      error.to_string()
    }
    error => fail(error.to_string())
  }
  assert_true(report.contains("fixtures/does-not-exist.feature"))
  assert_true(report.contains("1 parse error"))
}

///|
test "sync output failures retain typed operation path and message" {
  let options = @shared.portable_options()
  let path = "fixtures/does-not-exist/output.ndjson"
  options.add_formatter(@format.MessagesFormatter::new(), File(path))
  let rejected = try {
    let _ = @moonspec.run_sync(() => @shared.portable_world(), options)
    false
  } catch {
    @moonspec.SyncExecutionError::HostIoFailed(
      operation~,
      path=actual,
      message~
    ) => {
      assert_eq(operation, "write")
      assert_eq(actual, path)
      assert_true(message.length() > 0)
      true
    }
    error => fail(error.to_string())
  }
  assert_true(rejected)
}
