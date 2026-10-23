///|
pub fn hook_events(options : @moonspec.RunOptions) -> Array[String] raise {
  let bodies : Array[String] = []
  for line in options.get_sinks()[0].output().split("\n") {
    match @json.parse(line.to_owned()) {
      { "attachment": { "body": String(body), .. }, .. } => bodies.push(body)
      _ => ()
    }
  }
  bodies
}

///|
pub fn verify_hooks(options : @moonspec.RunOptions) -> Unit raise {
  assert_eq(hook_events(options), [
    "before_run", "before_case:Portable", "before_step:a fresh World", "after_step:Passed",
    "after_case:Portable:Passed", "before_case:Retry", "before_step:a fresh World",
    "after_step:Passed", "before_step:the attempt fails", "after_step:Failed", "after_case:Retry:Failed",
    "before_case:Retry", "before_step:a fresh World", "after_step:Passed", "before_step:the attempt fails",
    "after_step:Failed", "after_case:Retry:Failed", "after_run:Failed",
  ])
}
