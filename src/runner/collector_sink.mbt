///|
/// Test helper that collects all envelopes into an array.
pub(all) struct CollectorSink {
  envelopes : Array[@cucumber_messages.Envelope]
}

///|
pub fn CollectorSink::new() -> CollectorSink {
  { envelopes: [] }
}

///|
pub impl @core.MessageSink for CollectorSink with on_message(self, envelope) {
  self.envelopes.push(envelope)
}
