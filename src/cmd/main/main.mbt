///|
let version = "0.1.0"

///|
fn eprintln(msg : String) -> Unit {
  @fs.write_string_to_file("/dev/stderr", msg + "\n") catch {
    _ => println(msg)
  }
}

///|
fn die(msg : String) -> Unit {
  eprintln(msg)
  @sys.exit(1)
}

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

///|
fn cmd_version() -> Unit {
  println("moonspec \{version}")
}

///|
fn cmd_gen_tests(value : @clap.SimpleValue) -> Unit {
  let files = value.positional_args
  let output_dir : String? = match value.args.get("output-dir") {
    Some(vals) => Some(vals[0])
    None => None
  }
  // Load config: start from defaults, overlay config file, then CLI flags
  let mut config = @codegen.CodegenConfig::default()
  let config_path : String? = match value.args.get("config") {
    Some(vals) => Some(vals[0])
    None => None
  }
  // Try explicit --config path, or fall back to moonspec.json5 in cwd
  let config_file : String? = match config_path {
    Some(p) => Some(p)
    None => {
      let default_content = @fs.read_file_to_string("moonspec.json5") catch {
        _ => ""
      }
      if default_content.length() > 0 {
        Some("moonspec.json5")
      } else {
        None
      }
    }
  }
  match config_file {
    Some(path) => {
      let json5_content = @fs.read_file_to_string(path) catch {
        @fs.IOError(msg) => {
          die("Error reading config \{path}: \{msg}")
          return
        }
      }
      config = @codegen.CodegenConfig::from_json5(json5_content) catch {
        err => {
          die("Error parsing config \{path}: \{err}")
          return
        }
      }
    }
    None => ()
  }
  // CLI flags override config file values
  match value.args.get("world") {
    Some(vals) => config = { ..config, world: vals[0] }
    None => ()
  }
  match value.args.get("mode") {
    Some(vals) =>
      match vals[0] {
        "per-feature" =>
          config = { ..config, mode: @codegen.CodegenMode::PerFeature }
        "per-scenario" =>
          config = { ..config, mode: @codegen.CodegenMode::PerScenario }
        other => {
          die("Unknown mode: \{other} (expected per-scenario or per-feature)")
          return
        }
      }
    None => ()
  }
  if config.world.length() == 0 {
    die(
      "Error: --world (-w) is required. Specify the World type name (e.g. -w CalcWorld)",
    )
    return
  }
  for file in files {
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        die("Error reading \{file}: \{msg}")
        return
      }
    }
    let test_code = @codegen.generate_test_file(content, file, config~)
    let test_filename = @codegen.feature_to_test_filename(file)
    let output_path = match output_dir {
      Some(dir) => dir + "/" + test_filename
      None => test_filename
    }
    @fs.write_string_to_file(output_path, test_code) catch {
      @fs.IOError(msg) => {
        die("Error writing \{output_path}: \{msg}")
        return
      }
    }
    println(output_path)
  }
}

///|
fn cmd_gen_steps(_value : @clap.SimpleValue) -> Unit {
  eprintln("moonspec gen steps: not yet implemented")
  @sys.exit(1)
}

///|
fn cmd_check(value : @clap.SimpleValue) -> Unit {
  let files = value.positional_args
  let mut has_errors = false
  for file in files {
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        eprintln("Error reading \{file}: \{msg}")
        has_errors = true
        continue
      }
    }
    let source = @gherkin.Source::from_string(content, uri=file)
    let doc = @gherkin.parse(source) catch {
      @gherkin.UnexpectedToken(message~, ..)
      | @gherkin.UnexpectedEof(message~, ..)
      | @gherkin.InconsistentTableCells(message~, ..) => {
        eprintln(message)
        has_errors = true
        continue
      }
      @gherkin.CompositeError(errors~) => {
        for e in errors {
          match e {
            @gherkin.UnexpectedToken(message~, ..)
            | @gherkin.UnexpectedEof(message~, ..)
            | @gherkin.InconsistentTableCells(message~, ..) => eprintln(message)
            _ => ()
          }
        }
        has_errors = true
        continue
      }
    }
    let feature = match doc.feature {
      Some(f) => f
      None => {
        println("\{file}: (empty)")
        continue
      }
    }
    let mut scenario_count = 0
    let mut step_count = 0
    let tags : Array[String] = []
    for tag in feature.tags {
      tags.push(tag.name)
    }
    for child in feature.children {
      match child {
        @gherkin.FeatureChild::Scenario(scenario) => {
          scenario_count += 1
          step_count += scenario.steps.length()
          for tag in scenario.tags {
            if not(tags.contains(tag.name)) {
              tags.push(tag.name)
            }
          }
        }
        @gherkin.FeatureChild::Background(bg) => step_count += bg.steps.length()
        _ => ()
      }
    }
    println("\{file}:")
    println("  Feature: \{feature.name}")
    println("  Scenarios: \{scenario_count}")
    println("  Steps: \{step_count}")
    if not(tags.is_empty()) {
      let tag_list = tags.join(", ")
      println("  Tags: \{tag_list}")
    }
  }
  if has_errors {
    @sys.exit(1)
  }
}

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
