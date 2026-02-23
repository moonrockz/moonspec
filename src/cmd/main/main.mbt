///|
fn main {
  let parser = build_parser()
  let args = @env.args()
  // Skip the program name (args[0])
  let cli_args : Array[String] = if args.length() > 1 {
    args[1:].to_array()
  } else {
    []
  }
  let value = @clap.SimpleValue::new(parser.prog)
  let help_message = parser.parse(value, cli_args[:]) catch {
    err => {
      die("Error: \{err}")
      return
    }
  }
  match help_message {
    Some(msg) => {
      println(msg)
      return
    }
    None => ()
  }
  match value.subcmd {
    Some(subcmd) =>
      match subcmd.name {
        "version" => cmd_version()
        "gen" =>
          match subcmd.subcmd {
            Some(gen_subcmd) =>
              match gen_subcmd.name {
                "tests" => cmd_gen_tests(gen_subcmd)
                "steps" => cmd_gen_steps(gen_subcmd)
                _ => ()
              }
            None => {
              let help = parser.gen_help_message(["moonspec", "gen"], {})
              println(help)
            }
          }
        "check" => cmd_check(subcmd)
        _ => ()
      }
    None => {
      // No subcommand — show help
      let help = parser.gen_help_message(["moonspec"], {})
      println(help)
    }
  }
}
