///|
fn get_version() -> String {
  "0.6.0"
}

///|
fn build_parser() -> @argparse.Command {
  // -- gen tests: generate _test.mbt files from .feature files
  let gen_tests = @argparse.Command(
    "tests",
    positionals=[
      @argparse.PositionArg(
        "files",
        num_args=@argparse.ValueRange(lower=1),
        about=".feature or .feature.md files to generate tests from",
      ),
    ],
    options=[
      @argparse.OptionArg(
        "output-dir",
        short='o',
        about="Output directory for generated test files",
      ),
      @argparse.OptionArg(
        "world",
        short='w',
        about="World type name (e.g. CalcWorld)",
      ),
      @argparse.OptionArg(
        "mode",
        short='m',
        about="Codegen mode: per-scenario (default) or per-feature",
      ),
      @argparse.OptionArg(
        "config",
        short='c',
        about="Path to moonspec.json5 config file",
      ),
    ],
    about="Generate _test.mbt files from .feature or .feature.md files",
  )
  // -- gen steps: generate configure from #moonspec.* attributes
  let gen_steps = @argparse.Command(
    "steps",
    options=[
      @argparse.OptionArg(
        "dir",
        short='d',
        about="Directory to scan for step definitions",
      ),
      @argparse.OptionArg(
        "config",
        short='c',
        about="Path to moonspec.json5 config file",
      ),
    ],
    about="Generate configure from #moonspec.* attributes",
  )
  // -- gen: code generation commands
  let gen = @argparse.Command(
    "gen",
    subcommands=[gen_tests, gen_steps],
    about="Code generation commands",
    arg_required_else_help=true,
  )
  // -- check: parse and validate .feature files
  let check = @argparse.Command(
    "check",
    positionals=[
      @argparse.PositionArg(
        "files",
        num_args=@argparse.ValueRange(lower=1),
        about=".feature or .feature.md files to check",
      ),
    ],
    about="Parse and validate .feature or .feature.md files",
  )
  // -- version
  let version = @argparse.Command("version", about="Print version information")
  @argparse.Command(
    "moonspec",
    about="BDD test framework for MoonBit",
    subcommands=[gen, check, version],
    arg_required_else_help=true,
  )
}
