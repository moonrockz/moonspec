///|
/// Cucumber Messages NDJSON formatter.
/// Emits Envelope messages as newline-delimited JSON using the
/// `moonrockz/cucumber-messages` library.
pub(all) struct MessagesFormatter {
  priv mut buffer : String
}

///|
/// Create a new MessagesFormatter.
pub fn MessagesFormatter::new() -> MessagesFormatter {
  { buffer: "" }
}

///|
/// Return accumulated NDJSON output.
pub fn MessagesFormatter::output(self : MessagesFormatter) -> String {
  self.buffer
}

///|
/// Append an NDJSON line to the buffer.
fn MessagesFormatter::emit_line(
  self : MessagesFormatter,
  line : String,
) -> Unit {
  if self.buffer.length() > 0 {
    self.buffer = self.buffer + "\n"
  }
  self.buffer = self.buffer + line
}

///|
/// Build a JSON timestamp object with zero values.
fn zero_timestamp() -> Json {
  { "seconds": (0 : Int).to_json(), "nanos": (0 : Int).to_json() }
}

///|
pub impl Formatter for MessagesFormatter with on_run_start(self, _info) {
  let envelope : Json = { "testRunStarted": { "timestamp": zero_timestamp() } }
  self.emit_line(envelope.stringify())
}

///|
pub impl Formatter for MessagesFormatter with on_run_finish(self, result) {
  let success = result.summary.failed == 0
  let envelope : Json = {
    "testRunFinished": {
      "success": success.to_json(),
      "timestamp": zero_timestamp(),
    },
  }
  self.emit_line(envelope.stringify())
}
