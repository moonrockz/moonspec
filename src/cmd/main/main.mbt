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
fn load_config(config_path : String?) -> @config.MoonspecConfig {
  let path = match config_path {
    Some(p) => p
    None => {
      let content = @fs.read_file_to_string("moonspec.json5") catch { _ => "" }
      if content.length() > 0 {
        "moonspec.json5"
      } else {
        return @config.MoonspecConfig::empty()
      }
    }
  }
  let content = @fs.read_file_to_string(path) catch {
    @fs.IOError(msg) => {
      die("Error reading config \{path}: \{msg}")
      return @config.MoonspecConfig::empty()
    }
  }
  @config.MoonspecConfig::from_json5(content)
}

///|
fn cmd_gen_tests(value : @clap.SimpleValue) -> Unit {
  let files = value.positional_args
  let output_dir : String? = match value.args.get("output-dir") {
    Some(vals) => Some(vals[0])
    None => None
  }
  let config_path : String? = match value.args.get("config") {
    Some(vals) => Some(vals[0])
    None => None
  }
  let moonspec_config = load_config(config_path)
  // Resolve world: CLI --world overrides config
  let world = match value.args.get("world") {
    Some(vals) => vals[0]
    None =>
      match moonspec_config.world {
        Some(w) => w
        None => ""
      }
  }
  if world.length() == 0 {
    die(
      "Error: --world (-w) is required. Specify the World type name (e.g. -w CalcWorld)",
    )
    return
  }
  // CLI --mode flag (applies to all files if set)
  let cli_mode : String? = match value.args.get("mode") {
    Some(vals) => Some(vals[0])
    None => None
  }
  for file in files {
    let mode_str = match cli_mode {
      Some(m) => m
      None => moonspec_config.resolve_mode(file)
    }
    let mode = match mode_str {
      "per-feature" => @codegen.CodegenMode::PerFeature
      "per-scenario" => @codegen.CodegenMode::PerScenario
      other => {
        die("Unknown mode: \{other} (expected per-scenario or per-feature)")
        return
      }
    }
    let config = @codegen.CodegenConfig::{ mode, world }
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
fn str_ends_with(s : String, suffix : String) -> Bool {
  let slen = s.length()
  let suflen = suffix.length()
  if suflen > slen {
    return false
  }
  let offset = slen - suflen
  for i = 0; i < suflen; i = i + 1 {
    if s[offset + i] != suffix[i] {
      return false
    }
  }
  true
}

///|
fn str_to_lower(s : String) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i]
    if c >= 'A' && c <= 'Z' {
      buf.write_char((c.to_int() + 32).unsafe_to_char())
    } else {
      buf.write_char(c.to_int().unsafe_to_char())
    }
  }
  buf.to_string()
}

///|
fn dirname(path : String) -> String {
  let mut last_slash = -1
  for i = 0; i < path.length(); i = i + 1 {
    if path[i] == '/' {
      last_slash = i
    }
  }
  if last_slash < 0 {
    "."
  } else if last_slash == 0 {
    "/"
  } else {
    let buf = StringBuilder::new()
    for i = 0; i < last_slash; i = i + 1 {
      buf.write_char(path[i].to_int().unsafe_to_char())
    }
    buf.to_string()
  }
}

///|
fn ensure_parent_dir(path : String) -> Unit {
  let dir = dirname(path)
  if dir != "." && dir != "/" && not(@fs.path_exists(dir)) {
    // Create parent dirs recursively
    ensure_parent_dir(dir)
    @fs.create_dir(dir) catch { _ => () }
  }
}

///|
fn compute_steps_hash(steps : Array[@scanner.StepFnInfo]) -> String {
  let mut hash : UInt = 5381
  for step in steps {
    let s = step.source_file + ":" + step.line.to_string() + ":" + step.fn_name
    for i = 0; i < s.length(); i = i + 1 {
      let code : UInt = s[i].to_uint()
      hash = (hash << 5) + hash + code
    }
  }
  hash.to_string()
}

///|
fn discover_mbt_files(dir : String, files : Array[String]) -> Unit {
  let entries = @fs.read_dir(dir) catch { _ => return }
  for entry in entries {
    let full_path = dir + "/" + entry
    let is_directory = @fs.is_dir(full_path) catch { _ => false }
    if is_directory {
      discover_mbt_files(full_path, files)
    } else if str_ends_with(entry, ".mbt") &&
      not(str_ends_with(entry, "_wbtest.mbt")) &&
      not(str_ends_with(entry, "_test.mbt")) {
      files.push(full_path)
    }
  }
}

///|
fn resolve_output_path(
  mode : String,
  world_type : String,
  steps : Array[@scanner.StepFnInfo]
) -> String {
  let lower_world = str_to_lower(world_type)
  match mode {
    "generated" => "_generated/" + lower_world + "_steps.mbt"
    "alongside" => {
      let dir = if steps.is_empty() { "." } else { dirname(steps[0].source_file) }
      dir + "/" + lower_world + "_steps_gen.mbt"
    }
    "per-package" => {
      let dir = if steps.is_empty() { "." } else { dirname(steps[0].source_file) }
      dir + "/moonspec_gen.mbt"
    }
    custom_dir => custom_dir + "/" + lower_world + "_steps.mbt"
  }
}

///|
fn cmd_gen_steps(value : @clap.SimpleValue) -> Unit {
  let scan_dir = match value.args.get("dir") {
    Some(vals) => vals[0]
    None => "src"
  }
  let config = match value.args.get("config") {
    Some(vals) => load_config(Some(vals[0]))
    None => load_config(None)
  }
  let output_mode = match config.steps {
    Some(steps) =>
      match steps.output {
        Some(o) => o
        None => "generated"
      }
    None => "generated"
  }
  // Discover .mbt files
  let files : Array[String] = []
  discover_mbt_files(scan_dir, files)
  if files.is_empty() {
    println("No .mbt files found in \{scan_dir}")
    return
  }
  // Scan all files, caching contents for reuse in conflict detection
  let all_steps : Map[String, Array[@scanner.StepFnInfo]] = {}
  let file_contents : Map[String, String] = {}
  for file in files {
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        eprintln("Warning: could not read \{file}: \{msg}")
        continue
      }
    }
    file_contents.set(file, content)
    let result = @scanner.scan_source(content, file)
    for step in result.step_fns {
      match all_steps.get(step.world_type) {
        Some(arr) => arr.push(step)
        None => all_steps.set(step.world_type, [step])
      }
    }
  }
  if all_steps.is_empty() {
    println("No #moonspec.* attributes found")
    return
  }
  // Check for manual register_steps implementations that would conflict
  for world_type, _ in all_steps {
    for file in files {
      let content = match file_contents.get(file) {
        Some(c) => c
        None => continue
      }
      if @scanner.has_manual_registration(content, world_type) {
        eprintln(
          "Warning: \{file} contains a manual register_steps for \{world_type}. Generated code may conflict.",
        )
      }
    }
  }
  // Generate for each World type
  for world_type, steps in all_steps {
    let hash = compute_steps_hash(steps)
    let code = @scanner.generate_register_steps(world_type, steps, source_hash=hash)
    let output_path = resolve_output_path(output_mode, world_type, steps)
    // Ensure output directory exists
    ensure_parent_dir(output_path)
    @fs.write_string_to_file(output_path, code) catch {
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
