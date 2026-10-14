///|
async fn main {
  match parse_args(@env.args()) {
    Ok(args) => build_site(args)
    Err(message) => {
      println("prerender: " + message)
      @sys.exit(2)
    }
  }
}
