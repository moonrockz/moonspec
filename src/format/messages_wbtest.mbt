///|
test "MessagesFormatter serializes TestRunStarted envelope" {
  let fmt = MessagesFormatter::new()
  let json : Json = {
    "testRunStarted": {
      "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
    },
  }
  let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
    _ => panic()
  }
  @core.MessageSink::on_message(fmt, envelope)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
}

///|
test "MessagesFormatter serializes TestRunFinished envelope" {
  let fmt = MessagesFormatter::new()
  let json : Json = {
    "testRunFinished": {
      "success": true.to_json(),
      "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
    },
  }
  let envelope : @cucumber_messages.Envelope = @json.from_json(json) catch {
    _ => panic()
  }
  @core.MessageSink::on_message(fmt, envelope)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunFinished"))
  assert_true(string_contains(output, "\"success\":true"))
}

///|
test "MessagesFormatter emits NDJSON with multiple envelopes" {
  let fmt = MessagesFormatter::new()
  let json1 : Json = {
    "testRunStarted": {
      "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
    },
  }
  let json2 : Json = {
    "testRunFinished": {
      "success": true.to_json(),
      "timestamp": { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() },
    },
  }
  let env1 : @cucumber_messages.Envelope = @json.from_json(json1) catch {
    _ => panic()
  }
  let env2 : @cucumber_messages.Envelope = @json.from_json(json2) catch {
    _ => panic()
  }
  @core.MessageSink::on_message(fmt, env1)
  @core.MessageSink::on_message(fmt, env2)
  let output = fmt.output()
  assert_true(string_contains(output, "testRunStarted"))
  assert_true(string_contains(output, "testRunFinished"))
  // Verify NDJSON format (newline-separated)
  let lines = output.split("\n").collect()
  assert_eq(lines.length(), 2)
}
