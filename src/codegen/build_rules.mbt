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
/// Returns the new content and the number of entries added.
pub fn render_build_rules(
  existing : String,
  features : Array[String],
  package_dir~ : String,
  world~ : String,
  cli~ : CliCommand = Installed,
  test_kind~ : @config.TestKind = WhiteBox,
) -> (String, Int32) {
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
    return (existing, 0)
  }
  let prefix = if existing.trim(chars="\n").is_empty() {
    ""
  } else {
    existing.trim_end(chars="\n").to_owned() + "\n\n"
  }
  (prefix + blocks.join("\n"), blocks.length())
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
