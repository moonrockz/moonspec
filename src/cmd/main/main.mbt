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
        args={
          "files": @clap.Arg::positional(
            nargs=AtLeast(1),
            help=".feature files to generate tests from",
          ),
          "output-dir": @clap.Arg::named(
            short='o',
            nargs=Fixed(1),
            help="Output directory for generated test files",
          ),
        },
        help="Generate _test.mbt files from .feature files",
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
fn cmd_gen(value : @clap.SimpleValue) -> Unit {
  let files = value.positional_args
  let output_dir : String? = match value.args.get("output-dir") {
    Some(vals) => Some(vals[0])
    None => None
  }
  for file in files {
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        die("Error reading \{file}: \{msg}")
        return
      }
    }
    let test_code = @codegen.generate_test_file(content, file)
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
        "gen" => cmd_gen(subcmd)
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
