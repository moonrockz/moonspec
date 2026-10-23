///|
fn uses_shared(
  config : @config.MoonspecConfig,
  cli_execution : String?,
) -> Bool {
  config.shared is Some(_) ||
  (cli_execution is None && config.execution is Some(Targeted(..)))
}

///|
/// Nearer configuration replaces complete execution/shared fields.
fn load_config_for(
  path : String?,
  directory : String,
) -> @config.MoonspecConfig {
  if path is Some(_) {
    return load_config(path)
  }
  let directory = normalized_relative(directory) catch {
    _ => return load_config(None)
  }
  let mut config = load_config(None)
  let mut current = ""
  for part in directory.split("/") {
    if part.is_empty() || part == "." {
      continue
    }
    if part == ".." {
      return config
    }
    current = if current.is_empty() {
      part.to_owned()
    } else {
      current + "/" + part.to_owned()
    }
    for suffix in ["/moonspec.json", "/moonspec.json5"] {
      if load_config_file_optional(current + suffix) is Some(nearer) {
        config = config.merge(nearer)
      }
    }
  }
  config
}

///|
fn shared_failure(message : String) -> Unit {
  die("Error: " + message)
}

///|
fn read_required(path : String) -> String raise @codegen.PlanError {
  @fs.read_file_to_string(path) catch {
    @fs.IOError(message) =>
      raise @codegen.InvalidPlan("reading " + path + ": " + message)
  }
}

///|
fn module_metadata() -> (String, String) raise @codegen.PlanError {
  let mut name : String? = None
  let mut source : String? = None
  if @fs.path_exists("moon.mod") {
    let (ast, errors) = @moon_config.parse_moon_mod(read_required("moon.mod"))
    if !errors.is_empty() || !@moon_config.validate_moon_mod(ast).is_empty() {
      raise @codegen.InvalidPlan(
        "invalid moon.mod; module name/source must be validated before generation",
      )
    }
    if ast is @moon_config.Obj(fields, ..) {
      for field in fields {
        let (key, value) = field
        match (key, value) {
          ("name", @moon_config.Str(value, ..)) => name = Some(value)
          ("source", @moon_config.Str(value, ..)) => source = Some(value)
          _ => ()
        }
      }
    }
  } else if @fs.path_exists("moon.mod.json") {
    raise @codegen.InvalidPlan(
      "moon.mod.json is no longer supported by the compiler; run moon fmt to migrate it to moon.mod before shared generation",
    )
  } else {
    raise @codegen.InvalidPlan(
      "run shared generation from a module root containing moon.mod",
    )
  }
  let name = match name {
    Some(name) if !name.is_empty() => name
    _ => raise @codegen.InvalidPlan("module name is required")
  }
  (name, source.unwrap_or("."))
}

///|
fn normalized_relative(path : String) -> String raise @codegen.PlanError {
  let mut path = path
  if path.has_prefix("/") {
    let cwd = @env.current_dir().unwrap_or("")
    if cwd.is_empty() || !path.has_prefix(cwd + "/") {
      raise @codegen.InvalidPlan(
        "output must be inside the current module; use module-relative paths for filesystem aliases",
      )
    }
    path = path[cwd.length() + 1:].to_owned()
  }
  let parts : Array[String] = []
  for part in path.split("/") {
    if part == ".." {
      raise @codegen.InvalidPlan("output/source paths must not contain ..")
    }
    if part != "." && !part.is_empty() {
      parts.push(part.to_owned())
    }
  }
  parts.join("/")
}

///|
fn plan_shared_command(
  value : @argparse.Matches,
  files : Array[String],
  directory : String,
  config : @config.MoonspecConfig,
) -> (Array[@codegen.PlannedFile], String) raise @codegen.PlanError {
  if value.flags.get_or_default("moonx", false) {
    raise @codegen.InvalidPlan(
      "registry CLI target-policy capability is unavailable; build the current local CLI with mise run build:cli, add _build/bin to PATH, and rerun without --moonx",
    )
  }
  if directory.has_suffix(".mbt") {
    raise @codegen.InvalidPlan(
      "shared generation requires an output directory, not one .mbt file",
    )
  }
  let execution = match
    resolve_execution(option_value(value, "execution"), config) {
    Ok(policy) => policy
    Err(message) => raise @codegen.InvalidPlan(message)
  }
  let test_kind = match
    resolve_test_kind(option_value(value, "test-kind"), config) {
    Ok(kind) => kind
    Err(message) => raise @codegen.InvalidPlan(message)
  }
  let (module_name, source) = module_metadata()
  let source = normalized_relative(source)
  let directory = normalized_relative(directory)
  let package_path = if source.is_empty() {
    directory
  } else if directory == source {
    ""
  } else if directory.has_prefix(source + "/") {
    directory[source.length() + 1:].to_owned()
  } else {
    raise @codegen.InvalidPlan(
      "output directory must be beneath module source directory " + source,
    )
  }
  if config.shared is Some(shared) &&
    (
      shared.package_path == module_name ||
      shared.package_path.has_prefix(module_name + "/")
    ) {
    let relative = if shared.package_path == module_name {
      ""
    } else {
      shared.package_path[module_name.length() + 1:].to_owned()
    }
    let shared_dir = (if source.is_empty() { "." } else { source }) +
      (if relative.is_empty() { "" } else { "/" + relative })
    if relative.split("/").any(p => p.has_prefix("_") || p.has_prefix(".")) {
      raise @codegen.InvalidPlan("shared.package must be compiler-visible")
    }
    if @fs.path_exists(shared_dir + "/moon.pkg") {
      let (ast, errors) = @moon_config.parse_moon_pkg(
        read_required(shared_dir + "/moon.pkg"),
      )
      if ast is @moon_config.Obj(fields, ..) {
        for field in fields {
          if field is ("import", imports) && imports_async_runtime(imports) {
            raise @codegen.InvalidPlan(
              "shared.package must import the portable root and exclude async runtime imports",
            )
          }
          if field is ("supported-targets", @moon_config.Str(targets, ..)) {
            let supported = targets.split("+").map(p => p.to_owned()).to_array()
            for target in ["wasm", "wasm-gc", "js", "native"] {
              if !supported.contains(target) {
                raise @codegen.InvalidPlan(
                  "shared.package must support wasm, wasm-gc, js and native; missing " +
                  target,
                )
              }
            }
          }
        }
      }
      if !errors.is_empty() || !@moon_config.validate_moon_pkg(ast).is_empty() {
        raise @codegen.InvalidPlan(
          "shared.package has invalid moon.pkg: " + shared.package_path,
        )
      }
    } else if @fs.path_exists(shared_dir + "/moon.pkg.json") {
      raise @codegen.InvalidPlan(
        "shared.package moon.pkg.json is no longer supported by the compiler; run moon fmt to migrate it to moon.pkg before generation",
      )
    } else {
      raise @codegen.InvalidPlan(
        "shared.package does not exist: " + shared.package_path,
      )
    }
  }
  let inputs : Array[@codegen.FeatureInput] = []
  for file in files {
    let mode = match
      option_value(value, "mode").unwrap_or(config.resolve_mode(file)) {
      "per-scenario" => @codegen.PerScenario
      "per-feature" => @codegen.PerFeature
      other =>
        raise @codegen.InvalidPlan(
          "Unknown mode: " + other + " (expected per-scenario or per-feature)",
        )
    }
    inputs.push({ uri: file, content: read_required(file), mode, })
  }
  let generation = @codegen.CodegenConfig::{
    execution,
    shared: config.shared,
    world: "",
    mode: PerScenario,
    skip_tags: config.skip_tags,
    formatters: config.formatters,
    no_color: resolve_no_color(
      value.flags.get_or_default("no-color", false),
      config,
    ),
  }
  let plan = @codegen.plan_shared_generation(
    inputs,
    module_name~,
    package_path~,
    config=generation,
    test_kind~,
  )
  let base = (if directory.is_empty() { "." } else { directory }) +
    "/moonspec_gen"
  (plan.files(), base)
}

///|
fn shared_manifest(outputs : Array[@codegen.PlannedFile]) -> String {
  let files = outputs.map(fn(file) {
    Json::object({
      "path": Json::string(file.path),
      "content": Json::string(file.content),
    })
  })
  Json::object({
    "generator": Json::string("moonspec-shared-v1"),
    "files": Json::array(files),
  }).stringify(indent=2) +
  "\n"
}

///|
fn previous_shared_outputs(
  base : String,
) -> Map[String, String] raise @codegen.PlanError {
  let path = base + "/manifest.json"
  if !@fs.path_exists(path) {
    return Map([])
  }
  let original = read_required(path)
  let json = @json.parse(original) catch {
    _ => raise @codegen.InvalidPlan("malformed ownership manifest: " + path)
  }
  if original != json.stringify(indent=2) + "\n" {
    raise @codegen.InvalidPlan(
      "malformed ownership manifest: noncanonical or duplicate keys in " + path,
    )
  }
  let files = match json {
    Object(fields) if fields.length() == 2 => {
      guard fields.get("generator") is Some(String("moonspec-shared-v1")) &&
        fields.get("files") is Some(Array(files)) else {
        raise @codegen.InvalidPlan("malformed ownership manifest: " + path)
      }
      files
    }
    _ => raise @codegen.InvalidPlan("malformed ownership manifest: " + path)
  }
  let owned : Map[String, String] = Map([])
  for file in files {
    guard file is Object(fields) &&
      fields.length() == 2 &&
      fields.get("path") is Some(String(relative)) &&
      fields.get("content") is Some(String(content)) else {
      raise @codegen.InvalidPlan("malformed ownership entry: " + path)
    }
    let parts = relative.split("/").to_array()
    guard parts.length() == 2 &&
      ["shared", "sync", "async"].contains(parts[0].to_owned()) &&
      !parts[1].has_prefix(".") &&
      !parts[1].is_empty() &&
      (parts[1] == "moon.pkg" || parts[1].has_suffix(".mbt")) &&
      content.has_prefix(
        "// Generated by moonspec shared codegen. DO NOT EDIT.\n",
      ) &&
      owned.get(relative) is None else {
      raise @codegen.InvalidPlan("malformed ownership entry: " + relative)
    }
    owned.set(relative, content)
  }
  if owned.get("shared/moon.pkg") is None ||
    owned.get("shared/sources.mbt") is None {
    raise @codegen.InvalidPlan(
      "malformed ownership manifest: missing common outputs in " + path,
    )
  }
  owned
}

///|
fn validate_shared_outputs(
  outputs : Array[@codegen.PlannedFile],
  base : String,
) -> Map[String, String] raise @codegen.PlanError {
  let owned = previous_shared_outputs(base)
  for relative, original in owned {
    let path = base + "/" + relative
    if @fs.path_exists(path) && read_required(path) != original {
      raise @codegen.InvalidPlan("modified generated output: " + path)
    }
  }
  for file in outputs {
    let path = base + "/" + file.path
    let mut parent = dirname(path)
    while parent != "." && parent != "/" {
      if @fs.path_exists(parent) && !(@fs.is_dir(parent) catch { _ => false }) {
        raise @codegen.InvalidPlan("output parent collision: " + parent)
      }
      parent = dirname(parent)
    }
    if @fs.path_exists(path) && owned.get(file.path) is None {
      raise @codegen.InvalidPlan("unowned output collision: " + path)
    }
  }
  owned
}

///|
fn cmd_gen_shared(
  value : @argparse.Matches,
  files : Array[String],
  directory : String,
  config : @config.MoonspecConfig,
  apply~ : Bool,
  build~ : Bool = false,
) -> Unit {
  let (outputs, base) = plan_shared_command(value, files, directory, config) catch {
    @codegen.InvalidPlan(message) => {
      shared_failure(message)
      return
    }
  }
  let outputs = shared_build_outputs(
    outputs,
    base,
    files,
    directory,
    value,
    build~,
  ) catch {
    @codegen.InvalidPlan(message) => {
      shared_failure(message)
      return
    }
  }
  let owned = validate_shared_outputs(outputs, base) catch {
    @codegen.InvalidPlan(message) => {
      shared_failure(message)
      return
    }
  }
  let refresh = positional_values(value, "refresh-output").map(path => {
    normalized_relative(path)
  }) catch {
    @codegen.InvalidPlan(message) => {
      shared_failure(message)
      return
    }
  }
  for path in refresh {
    if !outputs.any(file => {
        file.path.has_suffix(".mbt") &&
        (normalized_relative(base + "/" + file.path) catch { _ => "" }) == path
      }) {
      shared_failure(
        "refresh-output must name a planned generated source: " + path,
      )
      return
    }
  }
  if !apply {
    println("Shared generation plan: " + base)
    for relative, _ in owned {
      if !outputs.any(file => file.path == relative) &&
        @fs.path_exists(base + "/" + relative) {
        println("--- remove " + base + "/" + relative)
      }
    }
    for file in outputs {
      println("--- " + base + "/" + file.path + "\n" + file.content)
    }
    println("--- " + base + "/manifest.json\n" + shared_manifest(outputs))
    return
  }
  // All expected failures, inputs, imports, targets and collisions were checked.
  for relative, _ in owned {
    let path = base + "/" + relative
    if !outputs.any(file => file.path == relative) && @fs.path_exists(path) {
      @fs.remove_file(path) catch {
        @fs.IOError(message) => {
          shared_failure("removing " + path + ": " + message)
          return
        }
      }
    }
  }
  for file in outputs {
    let path = base + "/" + file.path
    if !refresh.contains(normalized_relative(path) catch { _ => path }) &&
      @fs.path_exists(path) &&
      (read_required(path) catch { _ => "" }) == file.content {
      continue
    }
    ensure_parent_dir(path)
    @fs.write_string_to_file(path, file.content) catch {
      @fs.IOError(message) => {
        shared_failure("writing " + path + ": " + message)
        return
      }
    }
    println(path)
  }
  let manifest = shared_manifest(outputs)
  let manifest_path = base + "/manifest.json"
  if @fs.path_exists(manifest_path) &&
    (read_required(manifest_path) catch { _ => "" }) == manifest {
    return
  }
  @fs.write_string_to_file(manifest_path, manifest) catch {
    @fs.IOError(message) => {
      shared_failure("writing manifest: " + message)
      return
    }
  }
}

///|
fn imports_async_runtime(ast : @moon_config.Ast) -> Bool {
  match ast {
    @moon_config.Str(path, ..) =>
      path == "moonrockz/moonspec/async" ||
      path == "moonbitlang/async" ||
      path.has_prefix("moonbitlang/async/")
    @moon_config.Arr(items, ..) => items.to_array().any(imports_async_runtime)
    @moon_config.Obj(fields, ..) =>
      fields.to_array().any(fn(field) { imports_async_runtime(field.1) })
    _ => false
  }
}

///|
let shared_rule_marker = "\n// Moonspec shared regeneration rule. DO NOT EDIT.\n"

///|
fn shell_argument(value : String) -> String {
  "'" + value.replace(old="'", new="'\"'\"'") + "'"
}

///|
fn shared_build_outputs(
  outputs : Array[@codegen.PlannedFile],
  base : String,
  files : Array[String],
  directory : String,
  value : @argparse.Matches,
  build~ : Bool,
) -> Array[@codegen.PlannedFile] raise @codegen.PlanError {
  let owned = previous_shared_outputs(base)
  if !build &&
    !owned.values().any(content => content.contains(shared_rule_marker)) {
    return outputs
  }
  let (command, inputs) = {
    let args = ["moonspec", "gen", "build"]
    for file in files {
      args.push(shell_argument(file))
    }
    args.push("--package " + shell_argument(normalized_relative(directory)))
    args.push("--apply")
    for key in ["config", "mode", "execution", "test-kind"] {
      if option_value(value, key) is Some(option) {
        args.push("--" + key + " " + shell_argument(option))
      }
    }
    if value.flags.get_or_default("no-color", false) {
      args.push("--no-color")
    }
    let inputs = files.copy()
    // Track every existing configuration participating in hierarchical resolution.
    if option_value(value, "config") is Some(path) {
      inputs.push(path)
    } else {
      let parts = normalized_relative(directory).split("/").to_array()
      let mut current = ""
      for i in 0..<=parts.length() {
        for suffix in ["moonspec.json", "moonspec.json5"] {
          let path = current + suffix
          if @fs.path_exists(path) {
            inputs.push(path)
          }
        }
        if i < parts.length() && !parts[i].is_empty() {
          current += parts[i].to_owned() + "/"
        }
      }
    }
    (args.join(" "), inputs)
  }
  // Moon must see each test source as a local dev_build output. Order launcher
  // refresh after common-source generation so discovery observes changed tests.
  outputs.map(fn(file) {
    if !file.path.has_suffix("/moon.pkg") {
      return file
    }
    let directory = file.path.split("/").to_array()[0].to_owned()
    let suffix = {
      let package_dir = base + "/" + directory
      let inputs = if directory == "shared" {
        inputs
      } else {
        [base + "/shared/sources.mbt"]
      }
      let input_json = Json::array(
        inputs.map(path => {
          Json::string(@codegen.relative_to_package(path, package_dir))
        }),
      ).stringify()
      let local_outputs = outputs.filter(output => {
        output.path.has_prefix(directory + "/") &&
        output.path.has_suffix(".mbt")
      })
      let output_json = Json::array(
        local_outputs.map(output => {
          Json::string(output.path[directory.length() + 1:].to_owned())
        }),
      ).stringify()
      let refresh_args = local_outputs
        .map(output => {
          " --refresh-output " + shell_argument(base + "/" + output.path)
        })
        .join("")
      shared_rule_marker +
      "rule(\n  name: \"moonspec-shared\",\n  command: " +
      Json::string(command + refresh_args).stringify() +
      ",\n)\n" +
      "dev_build(\n  rule: \"moonspec-shared\",\n  input: " +
      input_json +
      ",\n  output: " +
      output_json +
      ",\n)\n"
    }
    { ..file, content: file.content + suffix, }
  })
}
