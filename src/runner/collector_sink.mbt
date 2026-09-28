///|
/// Test helper that collects all envelopes into an array.
pub(all) struct CollectorSink {
  envelopes : Array[@cucumber_messages.Envelope]
}

///|
pub fn CollectorSink::new() -> CollectorSink {
  { envelopes: [], }
}

///|
pub impl @core.MessageSink for CollectorSink with fn on_message(self, envelope) {
  self.envelopes.push(envelope)
}

///|
pub impl @core.MessageSink for CollectorSink with fn output(_self) {
  ""
}

///|
pub extend CollectorSink with @moonrockz/moonspec/core.MessageSink::{
  output,
  on_message,
}
