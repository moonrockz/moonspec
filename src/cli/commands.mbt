///|
fn cmd_version() -> Unit {
  println("moonspec \{get_version()}")
}

///|
fn cmd_gen_tests(value : @argparse.Matches) -> Unit {
  let files = positional_values(value, "files")
  let output_dir : String? = option_value(value, "output-dir")
  let config_path : String? = option_value(value, "config")
  let moonspec_config = load_config_for(config_path, output_dir.unwrap_or("."))
  if uses_shared(moonspec_config, option_value(value, "execution")) {
    cmd_gen_shared(
      value,
      files,
      output_dir.unwrap_or("."),
      moonspec_config,
      apply=!value.flags.get_or_default("preview", false),
    )
    return
  }
  if value.flags.get_or_default("preview", false) {
    die("Error: --preview currently supports shared package generation only")
    return
  }
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
  let execution = match
    resolve_execution(option_value(value, "execution"), moonspec_config) {
    Ok(Scalar(mode)) => mode
    Ok(Targeted(..)) => {
      die("Error: shared package generation requires a validated plan")
      return
    }
    Err(message) => {
      die(message)
      return
    }
  }
  let test_kind = match
    resolve_test_kind(option_value(value, "test-kind"), moonspec_config) {
    Ok(kind) => kind
    Err(msg) => {
      die(msg)
      return
    }
  }
  let no_color = resolve_no_color(
    value.flags.get_or_default("no-color", false),
    moonspec_config,
  )
  for file in files {
    let output_path = test_output_path(output_dir, file, test_kind)
    if !write_test_file(
        file,
        output_path,
        world~,
        execution~,
        cli_mode~,
        no_color~,
        moonspec_config~,
      ) {
      return
    }
    println(output_path)
  }
}

///|
/// Generate the test file for one feature file. Returns false (after `die`)
/// on an error.
fn write_test_file(
  file : String,
  output_path : String,
  world~ : String,
  execution~ : @config.ExecutionMode,
  cli_mode~ : String?,
  no_color~ : Bool,
  moonspec_config~ : @config.MoonspecConfig,
) -> Bool {
  let mode_str = match cli_mode {
    Some(m) => m
    None => moonspec_config.resolve_mode(file)
  }
  let mode = match mode_str {
    "per-feature" => @codegen.CodegenMode::PerFeature
    "per-scenario" => @codegen.CodegenMode::PerScenario
    other => {
      die("Unknown mode: \{other} (expected per-scenario or per-feature)")
      return false
    }
  }
  let config = @codegen.CodegenConfig::{
    execution: Scalar(execution),
    shared: None,
    mode,
    world,
    skip_tags: moonspec_config.skip_tags,
    formatters: moonspec_config.formatters,
    no_color,
  }
  let content = @fs.read_file_to_string(file) catch {
    @fs.IOError(msg) => {
      die("Error reading \{file}: \{msg}")
      return false
    }
  }
  let test_code = @codegen.generate_test_file(content, file, config~) catch {
    _ => {
      die("Error: use shared generation plan")
      return false
    }
  }
  ensure_parent_dir(output_path)
  @fs.write_string_to_file(output_path, test_code) catch {
    @fs.IOError(msg) => {
      die("Error writing \{output_path}: \{msg}")
      return false
    }
  }
  true
}

///|
fn cmd_gen_build(value : @argparse.Matches) -> Unit {
  let files = positional_values(value, "files")
  let package_dir = option_value(value, "package").unwrap_or("src")
  let moonspec_config = load_config_for(
    option_value(value, "config"),
    package_dir,
  )
  if uses_shared(moonspec_config, option_value(value, "execution")) {
    cmd_gen_shared(
      value,
      files,
      package_dir,
      moonspec_config,
      apply=value.flags.get_or_default("apply", false),
      build=true,
    )
    return
  }
  if !positional_values(value, "refresh-output").is_empty() {
    die("Error: --refresh-output requires shared package generation")
    return
  }
  if option_value(value, "mode") is Some(_) ||
    value.flags.get_or_default("no-color", false) {
    die(
      "Error: --mode and --no-color build options require shared package generation",
    )
    return
  }
  let world = match option_value(value, "world") {
    Some(v) => v
    None => moonspec_config.world.unwrap_or("")
  }
  if world.length() == 0 {
    die("Error: --world (-w) is required, or set \"world\" in moonspec.json5")
    return
  }
  let pkg_path = package_dir + "/moon.pkg"
  if !@fs.path_exists(pkg_path) &&
    @fs.path_exists(package_dir + "/moon.pkg.json") {
    die(
      "Error: \{package_dir}/moon.pkg.json does not support rule/dev_build. Run `moon fmt` to migrate it to moon.pkg.",
    )
    return
  }
  let apply = value.flags.get_or_default("apply", false)
  // --moonx: the rule runs this CLI version through moonx, so the project
  // needs no installed `moonspec` binary.
  let execution = match
    resolve_execution(option_value(value, "execution"), moonspec_config) {
    Ok(Scalar(mode)) => mode
    Ok(Targeted(..)) => {
      die("Error: shared package generation requires a validated plan")
      return
    }
    Err(message) => {
      die(message)
      return
    }
  }
  let test_kind = match
    resolve_test_kind(option_value(value, "test-kind"), moonspec_config) {
    Ok(kind) => kind
    Err(msg) => {
      die(msg)
      return
    }
  }
  let cli : @codegen.CliCommand = if value.flags.get_or_default("moonx", false) {
    Moonx(version=get_version())
  } else {
    Installed
  }
  if !apply {
    let (snippet, _) = @codegen.render_build_rules(
      "",
      files,
      package_dir~,
      world~,
      cli~,
      test_kind~,
      execution~,
    ) catch {
      error => {
        die(build_rule_error_message(error))
        return
      }
    }
    println(snippet.trim_end(chars="\n"))
    return
  }
  let existing = if @fs.path_exists(pkg_path) {
    @fs.read_file_to_string(pkg_path) catch {
      @fs.IOError(msg) => {
        die("Error reading \{pkg_path}: \{msg}")
        return
      }
    }
  } else {
    ""
  }
  let (content, added) = @codegen.render_build_rules(
    existing,
    files,
    package_dir~,
    world~,
    cli~,
    test_kind~,
    execution~,
  ) catch {
    error => {
      die(build_rule_error_message(error))
      return
    }
  }
  if added == 0 {
    println("\{pkg_path} is up to date")
    return
  }
  @fs.write_string_to_file(pkg_path, content) catch {
    @fs.IOError(msg) => {
      die("Error writing \{pkg_path}: \{msg}")
      return
    }
  }
  println("Updated \{pkg_path}: added \{added} entries")
  // moon does not compile a dev_build output that did not exist when the
  // build started, so write missing test files now. Then the first
  // `moon test` already runs them.
  for file in files {
    let output_path = package_dir +
      "/" +
      @codegen.build_rules_test_filename(file, kind=test_kind)
    if @fs.path_exists(output_path) {
      continue
    }
    if !write_test_file(
        file,
        output_path,
        world~,
        execution~,
        cli_mode=None,
        no_color=resolve_no_color(false, moonspec_config),
        moonspec_config~,
      ) {
      return
    }
    println("Generated \{output_path}")
  }
  if content.contains("\"pre-build\"") {
    println(
      "Note: \{pkg_path} still has options(\"pre-build\"). Remove the moonspec entries there to avoid running codegen twice.",
    )
  }
}

///|
fn cmd_gen_steps(value : @argparse.Matches) -> Unit {
  let scan_dir = option_value(value, "dir").unwrap_or("src")
  let config = load_config(option_value(value, "config"))
  let output_mode = steps_output_mode(config.steps)
  if output_mode == "generated" {
    eprintln(
      "Warning: steps.output \"generated\" writes to _generated/, which is not part of any package, so the World impl does not compile there. Use \"alongside\" (the default) or \"per-package\".",
    )
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

///|
fn build_rule_error_message(error : @codegen.BuildRuleError) -> String {
  let reason = match error {
    @codegen.UnsupportedExecution(version~) =>
      "registry CLI pin " + version + " does not support sync execution"
    @codegen.UnsupportedVersion(version~) =>
      "registry CLI pin " + version + " has unknown execution support"
  }
  "Error: " +
  reason +
  ". Build the current checkout CLI with `mise run build:cli`, add its `_build/bin` to PATH, and rerun without --moonx."
}
