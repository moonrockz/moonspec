///|
fn main {
  let parser = build_parser()
  let args = @env.args()
  // Skip the program name (args[0])
  let cli_args : Array[String] = if args.length() > 1 {
    args[1:].to_owned()
  } else {
    []
  }
  let matches = parser.parse(argv=cli_args) catch {
    err => {
      die("\{err}")
      return
    }
  }
  match matches.subcommand {
    Some(("version", _)) => cmd_version()
    Some(("gen", gen_matches)) =>
      match gen_matches.subcommand {
        Some(("tests", sub)) => cmd_gen_tests(sub)
        Some(("steps", sub)) => cmd_gen_steps(sub)
        _ => ()
      }
    Some(("check", sub)) => cmd_check(sub)
    // No subcommand: argparse prints help (arg_required_else_help)
    _ => ()
  }
}

///|
/// Return the first value given for option `name`, if any.
fn option_value(matches : @argparse.Matches, name : String) -> String? {
  match matches.values.get(name) {
    Some(vals) if vals.length() > 0 => Some(vals[0])
    _ => None
  }
}

///|
/// Return all values given for positional `name`.
fn positional_values(
  matches : @argparse.Matches,
  name : String,
) -> Array[String] {
  matches.values.get_or_default(name, [])
}
