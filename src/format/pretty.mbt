///|
/// Pretty console formatter with colored output and pass/fail markers.
pub(all) struct PrettyFormatter {
  no_color : Bool
  mut buffer : String
}

///|
/// Create a new PrettyFormatter.
pub fn PrettyFormatter::new(no_color? : Bool = false) -> PrettyFormatter {
  { no_color, buffer: "" }
}

///|
/// Return accumulated output.
pub fn PrettyFormatter::output(self : PrettyFormatter) -> String {
  self.buffer
}

// ---------------------------------------------------------------------------
// ANSI color helpers
// ---------------------------------------------------------------------------

///|
fn ansi_green(text : String, no_color : Bool) -> String {
  if no_color {
    text
  } else {
    "\u001b[32m" + text + "\u001b[0m"
  }
}

///|
fn ansi_red(text : String, no_color : Bool) -> String {
  if no_color {
    text
  } else {
    "\u001b[31m" + text + "\u001b[0m"
  }
}

///|
fn ansi_yellow(text : String, no_color : Bool) -> String {
  if no_color {
    text
  } else {
    "\u001b[33m" + text + "\u001b[0m"
  }
}

///|
fn ansi_cyan(text : String, no_color : Bool) -> String {
  if no_color {
    text
  } else {
    "\u001b[36m" + text + "\u001b[0m"
  }
}

///|
fn ansi_gray(text : String, no_color : Bool) -> String {
  if no_color {
    text
  } else {
    "\u001b[90m" + text + "\u001b[0m"
  }
}

// ---------------------------------------------------------------------------
// Status markers
// ---------------------------------------------------------------------------

///|
fn step_status_marker(status : @runner.StepStatus, no_color : Bool) -> String {
  match status {
    @runner.StepStatus::Passed => ansi_green("\u{2713}", no_color)
    @runner.StepStatus::Failed(_) => ansi_red("\u{2717}", no_color)
    @runner.StepStatus::Undefined => ansi_yellow("?", no_color)
    @runner.StepStatus::Pending => ansi_cyan("\u{23F8}", no_color)
    @runner.StepStatus::Skipped => ansi_gray("-", no_color)
  }
}

///|
fn scenario_status_marker(
  status : @runner.ScenarioStatus,
  no_color : Bool,
) -> String {
  match status {
    @runner.ScenarioStatus::Passed => ansi_green("\u{2713} PASS", no_color)
    @runner.ScenarioStatus::Failed => ansi_red("\u{2717} FAIL", no_color)
    @runner.ScenarioStatus::Undefined => ansi_yellow("? UNDEF", no_color)
    @runner.ScenarioStatus::Pending => ansi_cyan("\u{23F8} PENDING", no_color)
    @runner.ScenarioStatus::Skipped => ansi_gray("- SKIP", no_color)
  }
}

// ---------------------------------------------------------------------------
// Formatter trait implementation
// ---------------------------------------------------------------------------

///|
pub impl Formatter for PrettyFormatter with on_feature_start(self, name) {
  self.buffer = self.buffer + "Feature: " + name + "\n\n"
}

///|
pub impl Formatter for PrettyFormatter with on_scenario_finish(self, result) {
  let marker = scenario_status_marker(result.status, self.no_color)
  self.buffer = self.buffer +
    "  " +
    marker +
    " Scenario: " +
    result.scenario_name +
    "\n"
  for step in result.steps {
    let step_marker = step_status_marker(step.status, self.no_color)
    self.buffer = self.buffer +
      "    " +
      step_marker +
      " " +
      step.keyword +
      step.text +
      "\n"
  }
  self.buffer = self.buffer + "\n"
}

///|
pub impl Formatter for PrettyFormatter with on_run_finish(self, result) {
  let s = result.summary
  let scenario_word = if s.total_scenarios == 1 {
    "scenario"
  } else {
    "scenarios"
  }
  let parts : Array[String] = []
  if s.passed > 0 {
    parts.push(s.passed.to_string() + " passed")
  }
  if s.failed > 0 {
    parts.push(s.failed.to_string() + " failed")
  }
  if s.undefined > 0 {
    parts.push(s.undefined.to_string() + " undefined")
  }
  if s.pending > 0 {
    parts.push(s.pending.to_string() + " pending")
  }
  if s.skipped > 0 {
    parts.push(s.skipped.to_string() + " skipped")
  }
  let detail = string_join(parts, ", ")
  self.buffer = self.buffer +
    s.total_scenarios.to_string() +
    " " +
    scenario_word +
    " (" +
    detail +
    ")\n"
}

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

///|
/// Check if `haystack` contains `needle` as a substring.
pub fn string_contains(haystack : String, needle : String) -> Bool {
  let h_len = haystack.length()
  let n_len = needle.length()
  if n_len == 0 {
    return true
  }
  if n_len > h_len {
    return false
  }
  for i = 0; i <= h_len - n_len; i = i + 1 {
    let mut found = true
    for j = 0; j < n_len; j = j + 1 {
      if haystack[i + j] != needle[j] {
        found = false
        break
      }
    }
    if found {
      return true
    }
  }
  false
}

///|
/// Join an array of strings with a separator.
fn string_join(parts : Array[String], sep : String) -> String {
  let mut result = ""
  for i, part in parts {
    if i > 0 {
      result = result + sep
    }
    result = result + part
  }
  result
}
