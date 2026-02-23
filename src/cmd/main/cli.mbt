///|
let version = "0.1.0"

///|
fn build_parser() -> @clap.Parser {
  @clap.Parser::new(
    prog="moonspec",
    description="BDD test framework for MoonBit",
    subcmds={
      "gen": @clap.SubCommand::new(
        help="Code generation commands",
        subcmds={
          "tests": @clap.SubCommand::new(
            args={
              "files": @clap.Arg::positional(
                nargs=AtLeast(1),
                help=".feature files to generate tests from",
              ),
              "output-dir": @clap.Arg::named(
                short='o',
                nargs=AtMost(1),
                help="Output directory for generated test files",
              ),
              "world": @clap.Arg::named(
                short='w',
                nargs=AtMost(1),
                help="World type name (e.g. CalcWorld)",
              ),
              "mode": @clap.Arg::named(
                short='m',
                nargs=AtMost(1),
                help="Codegen mode: per-scenario (default) or per-feature",
              ),
              "config": @clap.Arg::named(
                short='c',
                nargs=AtMost(1),
                help="Path to moonspec.json5 config file",
              ),
            },
            help="Generate _test.mbt files from .feature files",
          ),
          "steps": @clap.SubCommand::new(
            args={
              "dir": @clap.Arg::named(
                short='d',
                nargs=AtMost(1),
                help="Directory to scan for step definitions",
              ),
              "config": @clap.Arg::named(
                short='c',
                nargs=AtMost(1),
                help="Path to moonspec.json5 config file",
              ),
            },
            help="Generate register_steps from #moonspec.* attributes",
          ),
        },
      ),
      "check": @clap.SubCommand::new(
        args={
          "files": @clap.Arg::positional(
            nargs=AtLeast(1),
            help=".feature files to check",
          ),
        },
        help="Parse and validate .feature files",
      ),
      "version": @clap.SubCommand::new(help="Print version information"),
    },
  )
}
