///|
fn get_version() -> String {
  "0.4.0"
}

///|
fn build_parser() -> @clap.Parser {
  // -- gen tests: generate _test.mbt files from .feature files
  let gen_tests = @clap.SubCommand::new(
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
  )
  // -- gen steps: generate configure from #moonspec.* attributes
  let gen_steps = @clap.SubCommand::new(
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
    help="Generate configure from #moonspec.* attributes",
  )
  // -- gen: code generation commands
  let gen = @clap.SubCommand::new(help="Code generation commands", subcmds={
    "tests": gen_tests,
    "steps": gen_steps,
  })
  // -- check: parse and validate .feature files
  let check = @clap.SubCommand::new(
    args={
      "files": @clap.Arg::positional(
        nargs=AtLeast(1),
        help=".feature files to check",
      ),
    },
    help="Parse and validate .feature files",
  )
  // -- version
  let version = @clap.SubCommand::new(help="Print version information")
  @clap.Parser::new(
    prog="moonspec",
    description="BDD test framework for MoonBit",
    subcmds={ "gen": gen, "check": check, "version": version },
  )
}
