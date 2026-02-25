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
pub impl @core.MessageSink for MessagesFormatter with output(self) {
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
pub impl @core.MessageSink for MessagesFormatter with on_message(self, envelope) {
  let json = envelope.to_json().stringify()
  self.emit_line(json)
}
