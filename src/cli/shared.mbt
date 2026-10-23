///|
fn uses_shared(config : @config.MoonspecConfig) -> Bool {
  config.shared is Some(_) || config.execution is Some(Targeted(..))
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
    let json = @json.parse(read_required("moon.mod.json")) catch {
      _ => raise @codegen.InvalidPlan("invalid moon.mod.json")
    }
    if json is Object(obj) {
      if obj.get("name") is Some(String(value)) {
        name = Some(value)
      }
      if obj.get("source") is Some(String(value)) {
        source = Some(value)
      }
    }
  } else {
    raise @codegen.InvalidPlan(
      "run shared generation from a module root containing moon.mod or moon.mod.json",
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
) -> (@codegen.GenerationPlan, String) raise @codegen.PlanError {
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
      ignore(
        @json.parse(read_required(shared_dir + "/moon.pkg.json")) catch {
          _ =>
            raise @codegen.InvalidPlan(
              "shared.package has invalid moon.pkg.json",
            )
        },
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
  validate_shared_outputs(plan, base)
  (plan, base)
}

///|
fn shared_manifest(plan : @codegen.GenerationPlan) -> String {
  let files = plan
    .files()
    .map(fn(file) {
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
/// .3 deliberately permits only fresh or byte-identical complete trees.
/// Stale reconciliation belongs to the following regeneration change.
fn validate_shared_outputs(
  plan : @codegen.GenerationPlan,
  base : String,
) -> Unit raise @codegen.PlanError {
  let manifest_path = base + "/manifest.json"
  let owned = @fs.path_exists(manifest_path)
  if owned && read_required(manifest_path) != shared_manifest(plan) {
    raise @codegen.InvalidPlan(
      "shared manifest differs or output tree is stale; safe reconciliation is required before writing " +
      manifest_path,
    )
  }
  for file in plan.files() {
    let path = base + "/" + file.path
    let mut parent = dirname(path)
    while parent != "." && parent != "/" {
      if @fs.path_exists(parent) && !(@fs.is_dir(parent) catch { _ => false }) {
        raise @codegen.InvalidPlan("output parent collision: " + parent)
      }
      parent = dirname(parent)
    }
    if @fs.path_exists(path) {
      if !owned {
        raise @codegen.InvalidPlan("unowned output collision: " + path)
      }
      if read_required(path) != file.content {
        raise @codegen.InvalidPlan("modified generated output: " + path)
      }
    }
  }
}

///|
fn cmd_gen_shared(
  value : @argparse.Matches,
  files : Array[String],
  directory : String,
  config : @config.MoonspecConfig,
  apply~ : Bool,
) -> Unit {
  let (plan, base) = plan_shared_command(value, files, directory, config) catch {
    @codegen.InvalidPlan(message) => {
      shared_failure(message)
      return
    }
  }
  let outputs = plan.files()
  if !apply {
    println("Shared generation plan: " + base)
    for file in outputs {
      println("--- " + base + "/" + file.path + "\n" + file.content)
    }
    println("--- " + base + "/manifest.json\n" + shared_manifest(plan))
    return
  }
  // All expected failures, inputs, imports, targets and collisions were checked.
  for file in outputs {
    let path = base + "/" + file.path
    ensure_parent_dir(path)
    @fs.write_string_to_file(path, file.content) catch {
      @fs.IOError(message) => {
        shared_failure("writing " + path + ": " + message)
        return
      }
    }
    println(path)
  }
  @fs.write_string_to_file(base + "/manifest.json", shared_manifest(plan)) catch {
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
