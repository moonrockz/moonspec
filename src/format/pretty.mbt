///|
/// Pretty console formatter with colored output and pass/fail markers.
/// Accumulates state from cucumber-messages envelopes and produces
/// formatted output as events arrive.
pub(all) struct PrettyFormatter {
  no_color : Bool
  mut buffer : String
  // uri -> feature name
  priv features : Map[String, String]
  // pickle id -> pickle info
  priv pickles : Map[String, PickleInfo]
  // test case id -> pickle id
  priv test_cases : Map[String, String]
  // test case started id -> test case id
  priv test_case_started : Map[String, String]
  // test step id -> pickle step id (within a test case)
  priv test_step_to_pickle_step : Map[String, String]
  // pickle step id -> step info
  priv pickle_steps : Map[String, StepLookup]
  // test case started id -> worst severity (Int) seen so far
  priv test_case_worst : Map[String, Int]
  priv mut current_feature_uri : String
  priv counts : SummaryCounts
}

///|
priv struct PickleInfo {
  name : String
  uri : String
}

///|
priv struct StepLookup {
  text : String
  keyword : String
}

///|
priv struct SummaryCounts {
  mut total : Int
  mut passed : Int
  mut failed : Int
  mut undefined : Int
  mut pending : Int
  mut skipped : Int
}

///|
/// Create a new PrettyFormatter.
pub fn PrettyFormatter::new(no_color? : Bool = false) -> PrettyFormatter {
  {
    no_color,
    buffer: "",
    features: {},
    pickles: {},
    test_cases: {},
    test_case_started: {},
    test_step_to_pickle_step: {},
    pickle_steps: {},
    test_case_worst: {},
    current_feature_uri: "",
    counts: { total: 0, passed: 0, failed: 0, undefined: 0, pending: 0, skipped: 0 },
  }
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
// Status markers (envelope-driven, using cucumber-messages status)
// ---------------------------------------------------------------------------

///|
fn msg_step_status_marker(
  status : @cucumber_messages.TestStepResultStatus,
  no_color : Bool,
) -> String {
  match status {
    Passed => ansi_green("\u{2713}", no_color)
    Failed => ansi_red("\u{2717}", no_color)
    Undefined => ansi_yellow("?", no_color)
    Pending => ansi_cyan("\u{23F8}", no_color)
    Skipped => ansi_gray("-", no_color)
    Ambiguous => ansi_red("!", no_color)
    Unknown => ansi_gray("?", no_color)
  }
}

// ---------------------------------------------------------------------------
// Helper: keyword from PickleStepType
// ---------------------------------------------------------------------------

///|
fn keyword_from_step_type(
  type_ : @cucumber_messages.PickleStepType?,
) -> String {
  match type_ {
    Some(Context) => "Given "
    Some(Action) => "When "
    Some(Outcome) => "Then "
    _ => ""
  }
}

// ---------------------------------------------------------------------------
// Helper: status severity for "worst status" tracking
// Severity levels: 0=passed, 1=skipped, 2=pending, 3=undefined, 4=ambiguous, 5=failed
// ---------------------------------------------------------------------------

///|
fn status_to_severity(
  status : @cucumber_messages.TestStepResultStatus,
) -> Int {
  match status {
    Passed => 0
    Skipped => 1
    Pending => 2
    Undefined => 3
    Ambiguous => 4
    Failed => 5
    Unknown => 0
  }
}

///|
/// Increment the appropriate counter based on severity level.
fn increment_count_for_severity(counts : SummaryCounts, severity : Int) -> Unit {
  match severity {
    0 => counts.passed = counts.passed + 1
    1 => counts.skipped = counts.skipped + 1
    2 => counts.pending = counts.pending + 1
    3 => counts.undefined = counts.undefined + 1
    4 => counts.failed = counts.failed + 1 // ambiguous counted as failed
    5 => counts.failed = counts.failed + 1
    _ => counts.skipped = counts.skipped + 1
  }
}

// ---------------------------------------------------------------------------
// MessageSink implementation
// ---------------------------------------------------------------------------

///|
pub impl @core.MessageSink for PrettyFormatter with on_message(self, envelope) {
  match envelope {
    GherkinDocument(doc) => {
      let uri = match doc.uri {
        Some(u) => u
        None => ""
      }
      let feature_name = match doc.feature {
        Some(f) => f.name
        None => uri
      }
      self.features[uri] = feature_name
    }
    Pickle(pickle) => {
      self.pickles[pickle.id] = { name: pickle.name, uri: pickle.uri }
      for step in pickle.steps {
        let keyword = keyword_from_step_type(step.type_)
        self.pickle_steps[step.id] = { text: step.text, keyword }
      }
    }
    TestCase(tc) => {
      self.test_cases[tc.id] = tc.pickleId
      // Map each test step id to its pickle step id
      for test_step in tc.testSteps {
        match test_step.pickleStepId {
          Some(psid) => self.test_step_to_pickle_step[test_step.id] = psid
          None => () // hook step, not a pickle step
        }
      }
    }
    TestCaseStarted(tcs) => {
      self.test_case_started[tcs.id] = tcs.testCaseId
      self.test_case_worst[tcs.id] = 0 // 0 = passed (best)
      // Look up pickle info
      let pickle_id = match self.test_cases.get(tcs.testCaseId) {
        Some(pid) => pid
        None => ""
      }
      let pickle_info = self.pickles.get(pickle_id)
      match pickle_info {
        Some(info) => {
          // Print feature header if URI changed
          if info.uri != self.current_feature_uri {
            self.current_feature_uri = info.uri
            let feature_name = match self.features.get(info.uri) {
              Some(n) => n
              None => info.uri
            }
            self.buffer = self.buffer + "Feature: " + feature_name + "\n\n"
          }
          // Print scenario header
          self.buffer = self.buffer + "  Scenario: " + info.name + "\n"
        }
        None => ()
      }
    }
    TestStepFinished(tsf) => {
      // Only format pickle steps (not hook steps)
      match self.test_step_to_pickle_step.get(tsf.testStepId) {
        Some(pickle_step_id) => {
          let status = tsf.testStepResult.status
          let step_info = self.pickle_steps.get(pickle_step_id)
          match step_info {
            Some(info) => {
              let marker = msg_step_status_marker(status, self.no_color)
              self.buffer = self.buffer +
                "    " +
                marker +
                " " +
                info.keyword +
                info.text +
                "\n"
            }
            None => ()
          }
          // Update worst status for this test case
          let tcs_id = tsf.testCaseStartedId
          let current_worst = match self.test_case_worst.get(tcs_id) {
            Some(w) => w
            None => 0
          }
          let new_severity = status_to_severity(status)
          if new_severity > current_worst {
            self.test_case_worst[tcs_id] = new_severity
          }
        }
        None => () // hook step, skip
      }
    }
    TestCaseFinished(tcf) => {
      let tcs_id = tcf.testCaseStartedId
      let worst = match self.test_case_worst.get(tcs_id) {
        Some(w) => w
        None => 0
      }
      self.buffer = self.buffer + "\n"
      // Increment counts
      self.counts.total = self.counts.total + 1
      increment_count_for_severity(self.counts, worst)
    }
    TestRunFinished(_) => {
      let c = self.counts
      let scenario_word = if c.total == 1 { "scenario" } else { "scenarios" }
      let parts : Array[String] = []
      if c.passed > 0 {
        parts.push(c.passed.to_string() + " passed")
      }
      if c.failed > 0 {
        parts.push(c.failed.to_string() + " failed")
      }
      if c.undefined > 0 {
        parts.push(c.undefined.to_string() + " undefined")
      }
      if c.pending > 0 {
        parts.push(c.pending.to_string() + " pending")
      }
      if c.skipped > 0 {
        parts.push(c.skipped.to_string() + " skipped")
      }
      let detail = string_join(parts, ", ")
      self.buffer = self.buffer +
        c.total.to_string() +
        " " +
        scenario_word +
        " (" +
        detail +
        ")\n"
    }
    _ => () // Ignore other envelope types
  }
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
