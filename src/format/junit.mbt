///|
pub(all) struct JUnitFormatter {
  priv mut buffer : String
}

///|
pub fn JUnitFormatter::new() -> JUnitFormatter {
  { buffer: "" }
}

///|
pub fn JUnitFormatter::output(self : JUnitFormatter) -> String {
  self.buffer
}

///|
impl Formatter for JUnitFormatter with on_run_finish(self, result) {
  let mut xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  xml = xml + "<testsuites tests=\"" + result.summary.total_scenarios.to_string() +
    "\""
  xml = xml + " failures=\"" + result.summary.failed.to_string() + "\""
  xml = xml + " time=\"" + ms_to_seconds(result.summary.duration_ms) + "\">\n"
  for feature in result.features {
    xml = xml + "  <testsuite name=\"" + escape_xml(feature.name) + "\""
    xml = xml + " tests=\"" + feature.scenarios.length().to_string() + "\""
    xml = xml + " time=\"" + ms_to_seconds(feature.duration_ms) + "\">\n"
    for scenario in feature.scenarios {
      xml = xml + "    <testcase name=\"" + escape_xml(scenario.scenario_name) +
        "\""
      xml = xml + " classname=\"" + escape_xml(scenario.feature_name) + "\""
      xml = xml + " time=\"" + ms_to_seconds(scenario.duration_ms) + "\">\n"
      match scenario.status {
        @runner.ScenarioStatus::Failed => {
          let msg = find_failure_message(scenario.steps)
          xml = xml + "      <failure message=\"" + escape_xml(msg) + "\"/>\n"
        }
        @runner.ScenarioStatus::Skipped => xml = xml + "      <skipped/>\n"
        _ => ()
      }
      xml = xml + "    </testcase>\n"
    }
    xml = xml + "  </testsuite>\n"
  }
  xml = xml + "</testsuites>\n"
  self.buffer = xml
}

///|
fn ms_to_seconds(ms : Int64) -> String {
  let s = ms / 1000L
  let frac = ms % 1000L
  let frac_str = frac.to_string()
  // Zero-pad to 3 digits
  let padded = if frac_str.length() == 1 {
    "00" + frac_str
  } else if frac_str.length() == 2 {
    "0" + frac_str
  } else {
    frac_str
  }
  s.to_string() + "." + padded
}

///|
fn escape_xml(s : String) -> String {
  let buf = StringBuilder::new()
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i]
    if c == '&' {
      buf.write_string("&amp;")
    } else if c == '<' {
      buf.write_string("&lt;")
    } else if c == '>' {
      buf.write_string("&gt;")
    } else if c == '"' {
      buf.write_string("&quot;")
    } else {
      buf.write_char(c.to_int().unsafe_to_char())
    }
  }
  buf.to_string()
}

///|
fn find_failure_message(steps : Array[@runner.StepResult]) -> String {
  for step in steps {
    match step.status {
      @runner.StepStatus::Failed(msg) => return msg
      _ => continue
    }
  }
  "unknown failure"
}
