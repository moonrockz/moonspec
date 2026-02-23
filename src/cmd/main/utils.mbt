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
