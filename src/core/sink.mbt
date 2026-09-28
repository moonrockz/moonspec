///|
/// A sink that receives cucumber-messages Envelope events during a test run.
pub(open) trait MessageSink {
  fn on_message(Self, @cucumber_messages.Envelope) -> Unit
  fn output(Self) -> String
}
