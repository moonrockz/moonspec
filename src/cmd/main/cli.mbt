///|
fn get_version() -> String {
  "1.0.0"
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
        about="Output directory, or an exact .mbt file path for one feature file",
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
    flags=[
      @argparse.FlagArg(
        "no-color",
        long="no-color",
        about="Generate tests that print the failure report without ANSI colors",
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
  // -- gen build: moon.pkg rule/dev_build entries for feature files
  let gen_build = @argparse.Command(
    "build",
    positionals=[
      @argparse.PositionArg(
        "files",
        num_args=@argparse.ValueRange(lower=1),
        about=".feature or .feature.md files, relative to the module root",
      ),
    ],
    options=[
      @argparse.OptionArg(
        "package",
        short='p',
        about="Package directory that gets the tests (default: src)",
      ),
      @argparse.OptionArg(
        "world",
        short='w',
        about="World type name (e.g. CalcWorld)",
      ),
      @argparse.OptionArg(
        "config",
        short='c',
        about="Path to moonspec.json5 config file",
      ),
    ],
    flags=[
      @argparse.FlagArg(
        "apply",
        long="apply",
        about="Write the missing entries to <package>/moon.pkg instead of printing them",
      ),
    ],
    about="Generate moon.pkg rule/dev_build entries that run `gen tests` before each build",
  )
  // -- gen: code generation commands
  let gen = @argparse.Command(
    "gen",
    subcommands=[gen_tests, gen_steps, gen_build],
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
