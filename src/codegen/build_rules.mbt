///|
/// Name of the moon.pkg `rule` that runs `moonspec gen tests`.
let build_rule_name = "moonspec-tests"

///|
/// How a build rule runs the moonspec CLI.
pub(all) enum CliCommand {
  /// The `moonspec` binary on `PATH`, from
  /// `moon install moonrockz/moonspec/cmd/moonspec`.
  Installed
  /// `moonx`, which runs the CLI from the registry without an install.
  /// The version is pinned so that builds are reproducible.
  Moonx(version~ : String)
} derive(Eq, Debug)

///|
pub extend CliCommand with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend CliCommand with Eq::{not_equal, equal}

///|
/// The command that runs the moonspec CLI, without arguments.
pub fn CliCommand::prefix(self : CliCommand) -> String {
  match self {
    Installed => "moonspec"
    Moonx(version~) => "moonx moonrockz/moonspec/cmd/moonspec@" + version
  }
}

///|
/// A registry CLI pin cannot honor the requested build-rule execution mode.
pub suberror BuildRuleError {
  UnsupportedExecution(version~ : String)
  UnsupportedVersion(version~ : String)
} derive(Debug)

///|
pub extend BuildRuleError with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Add the moon.pkg `rule` and `dev_build` entries that regenerate the tests
/// of each feature file before `moon check`, `moon build` and `moon test`.
///
/// `existing` is the current moon.pkg content (empty for a new file).
/// `features` are paths relative to the module root, where moon runs build
/// commands. `package_dir` is the package directory, also relative to the
/// module root. Entries that are already present (the rule by name, a
/// `dev_build` by output file) are not added again, so a second run changes
/// nothing.
///
/// `cli` selects how the rule runs the CLI (default: the installed
/// `moonspec` binary). `test_kind` selects white-box (default) or black-box
/// test file names.
///
/// Returns the new content and the number of entries added or updated.
/// Existing canonical generated rules update their CLI prefix and execution flag.
/// Stable registry pins below 0.12.0 omit the flag for legacy async generation.
/// Sync with those pins raises `UnsupportedExecution`; unknown or prerelease
/// pins raise `UnsupportedVersion` for either mode. Stable pins from 0.12.0
/// follow the explicit-selection contract. Installed CLIs must support the
/// selected execution mode.
pub fn render_build_rules(
  existing : String,
  features : Array[String],
  package_dir~ : String,
  world~ : String,
  cli~ : CliCommand = Installed,
  test_kind~ : @config.TestKind = WhiteBox,
  execution~ : @config.ExecutionMode = Async,
) -> (String, Int32) raise BuildRuleError {
  let execution_value = match execution {
    Async => "async"
    Sync => "sync"
  }
  let execution_flag = match cli {
    Installed => " --execution " + execution_value
    Moonx(version~) =>
      if registry_supports_execution(version) {
        " --execution " + execution_value
      } else {
        match execution {
          Async => ""
          Sync => raise UnsupportedExecution(version~)
        }
      }
  }
  let (existing, updated) = update_rule_command(
    existing,
    cli.prefix(),
    execution_flag,
  )
  let blocks : Array[String] = []
  if !existing.contains("name: \"" + build_rule_name + "\"") {
    blocks.push(
      "rule(\n" +
      "  name: \"" +
      build_rule_name +
      "\",\n" +
      "  command: \"" +
      cli.prefix() +
      " gen tests $input -w " +
      world +
      execution_flag +
      " -o $output\",\n" +
      ")\n",
    )
  }
  let outputs : Array[String] = []
  for feature in features {
    let output = build_rules_test_filename(feature, kind=test_kind)
    if existing.contains("output: \"" + output + "\"") ||
      outputs.contains(output) {
      continue
    }
    outputs.push(output)
    blocks.push(
      "dev_build(\n" +
      "  rule: \"" +
      build_rule_name +
      "\",\n" +
      "  input: \"" +
      escape_string(relative_to_package(feature, package_dir)) +
      "\",\n" +
      "  output: \"" +
      escape_string(output) +
      "\",\n" +
      ")\n",
    )
  }
  if blocks.is_empty() {
    return (existing, updated)
  }
  let prefix = if existing.trim(chars="\n").is_empty() {
    ""
  } else {
    existing.trim_end(chars="\n").to_owned() + "\n\n"
  }
  (prefix + blocks.join("\n"), blocks.length() + updated)
}

///|
/// Name of the generated test file for a feature. White-box tests (the
/// default) can use the package's private World type.
pub fn build_rules_test_filename(
  feature : String,
  kind~ : @config.TestKind = WhiteBox,
) -> String {
  feature_to_test_filename(feature, kind~)
}

///|
/// Express `path` (relative to the module root) relative to `package_dir`
/// (also relative to the module root). Absolute paths are returned unchanged.
pub fn relative_to_package(path : String, package_dir : String) -> String {
  if path.has_prefix("/") {
    return path
  }
  let target = path_segments(path)
  let base = path_segments(package_dir)
  let mut common = 0
  while common < base.length() &&
        common < target.length() - 1 &&
        base[common] == target[common] {
    common += 1
  }
  let parts : Array[String] = []
  for _ in common..<base.length() {
    parts.push("..")
  }
  for i in common..<target.length() {
    parts.push(target[i])
  }
  parts.join("/")
}

///|
/// Split a relative path into its segments, without empty and "." segments.
fn path_segments(path : String) -> Array[String] {
  let segments : Array[String] = []
  for part in path.split("/") {
    if part != "" && part != "." {
      segments.push(part.to_owned())
    }
  }
  segments
}

///|
/// Update only the command of the canonical generated rule, preserving other rules.
fn update_rule_command(
  existing : String,
  prefix : String,
  execution_flag : String,
) -> (String, Int32) {
  let marker = "rule(\n  name: \"" + build_rule_name + "\",\n  command: \""
  guard existing.split_once(marker) is Some((before, after)) else {
    return (existing, 0)
  }
  let suffix = "\",\n)"
  guard after.split_once(suffix) is Some((command, rest)) else {
    return (existing, 0)
  }
  guard command.split_once(" gen tests $input ") is Some((old_prefix, args)) else {
    return (existing, 0)
  }
  guard old_prefix == "moonspec" ||
    old_prefix.has_prefix("moonx moonrockz/moonspec/cmd/moonspec@") else {
    return (existing, 0)
  }
  // Keep unrelated generation options, changing only the CLI and execution.
  let args = " " + args.to_owned()
  let updated_args = if args.contains(" --execution async") {
    args.replace(old=" --execution async", new=execution_flag)
  } else if args.contains(" --execution sync") {
    args.replace(old=" --execution sync", new=execution_flag)
  } else {
    args.replace(old=" -o $output", new=execution_flag + " -o $output")
  }
  let updated = prefix + " gen tests $input" + updated_args
  if updated == command.to_owned() {
    (existing, 0)
  } else {
    (before.to_owned() + marker + updated + suffix + rest.to_owned(), 1)
  }
}

///|
/// Explicit execution selection starts with the stable 0.12.0 contract.
/// Reject ambiguous pins rather than trusting a registry CLI's config default.
fn registry_supports_execution(version : String) -> Bool raise BuildRuleError {
  let parts = version.split(".").to_array()
  if parts.length() != 3 {
    raise UnsupportedVersion(version~)
  }
  for part in parts {
    if part.is_empty() || (part.length() > 1 && part[0] == '0') {
      raise UnsupportedVersion(version~)
    }
    for i in 0..<part.length() {
      if part[i] < '0' || part[i] > '9' {
        raise UnsupportedVersion(version~)
      }
    }
  }
  parts[0] != "0" ||
  parts[1].length() > 2 ||
  (parts[1].length() == 2 && parts[1] >= "12")
}
