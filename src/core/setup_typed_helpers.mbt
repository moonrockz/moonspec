///|
fn validate_arity(ctx : Ctx, expected : Int) -> Unit raise Error {
  let actual = ctx.args().length()
  if actual != expected {
    raise Failure::Failure("expected \{expected} step args, got \{actual}")
  }
}
