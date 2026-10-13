///|
fn validate_arity(ctx : Ctx, expected : Int32) -> Unit raise Error {
  let actual = ctx.args().length()
  if actual != expected {
    raise Failure::Failure("expected \{expected} step args, got \{actual}")
  }
}
