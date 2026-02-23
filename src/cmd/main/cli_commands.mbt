///|
fn cmd_version() -> Unit {
  println("moonspec \{get_version()}")
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
  // Check for manual configure implementations that would conflict
  for world_type, _ in all_steps {
    for file in files {
      let content = match file_contents.get(file) {
        Some(c) => c
        None => continue
      }
      if @scanner.has_manual_registration(content, world_type) {
        eprintln(
          "Warning: \{file} contains a manual configure for \{world_type}. Generated code may conflict.",
        )
      }
    }
  }
  // Generate for each World type
  for world_type, steps in all_steps {
    let hash = compute_steps_hash(steps)
    let code = @scanner.generate_configure(world_type, steps, source_hash=hash)
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
