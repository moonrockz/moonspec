///|
fn cmd_version() -> Unit {
  println("moonspec \{get_version()}")
}

///|
fn cmd_gen_tests(value : @argparse.Matches) -> Unit {
  let files = positional_values(value, "files")
  let output_dir : String? = option_value(value, "output-dir")
  let config_path : String? = option_value(value, "config")
  let moonspec_config = load_config(config_path)
  // Resolve world: CLI --world overrides config
  let world = match option_value(value, "world") {
    Some(v) => v
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
  if files.length() > 1 &&
    output_dir is Some(path) &&
    str_ends_with(path, ".mbt") {
    die(
      "Error: --output-dir (-o) names a single .mbt file, but got \{files.length()} feature files",
    )
    return
  }
  // CLI --mode flag (applies to all files if set)
  let cli_mode : String? = option_value(value, "mode")
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
    let config = @codegen.CodegenConfig::{
      mode,
      world,
      skip_tags: moonspec_config.skip_tags,
      formatters: moonspec_config.formatters,
      no_color: resolve_no_color(
        value.flags.get_or_default("no-color", false),
        moonspec_config,
      ),
    }
    let content = @fs.read_file_to_string(file) catch {
      @fs.IOError(msg) => {
        die("Error reading \{file}: \{msg}")
        return
      }
    }
    let test_code = @codegen.generate_test_file(content, file, config~)
    let output_path = test_output_path(output_dir, file)
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
fn cmd_gen_steps(value : @argparse.Matches) -> Unit {
  let scan_dir = option_value(value, "dir").unwrap_or("src")
  let config = load_config(option_value(value, "config"))
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
  let all_steps : Map[String, Array[@scanner.StepFnInfo]] = Map([])
  let file_contents : Map[String, String] = Map([])
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
fn cmd_check(value : @argparse.Matches) -> Unit {
  let files = positional_values(value, "files")
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
            if !tags.contains(tag.name) {
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
    if !tags.is_empty() {
      let tag_list = tags.join(", ")
      println("  Tags: \{tag_list}")
    }
  }
  if has_errors {
    @sys.exit(1)
  }
}
