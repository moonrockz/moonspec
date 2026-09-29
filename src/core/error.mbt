///|
/// Structured error hierarchy for moonspec.
///
/// Step-level errors aggregate into ScenarioFailed, which aggregates
/// into RunFailed. This enables rich diagnostics and the `run_or_fail!` API.
pub suberror MoonspecError {
  UndefinedStep(
    step~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
  PendingStep(step~ : String, keyword~ : String, message~ : String)
  StepFailed(step~ : String, keyword~ : String, message~ : String)
  ScenarioFailed(
    scenario~ : String,
    feature~ : String,
    errors~ : Array[MoonspecError]
  )
  RunFailed(summary~ : String, errors~ : Array[MoonspecError])
}

///|
/// Create an UndefinedStep error.
pub fn undefined_step_error(
  step~ : String,
  keyword~ : String,
  snippet~ : String,
  suggestions~ : Array[String],
) -> Error {
  UndefinedStep(step~, keyword~, snippet~, suggestions~)
}

///|
/// Create a PendingStep error.
pub fn pending_step_error(
  step~ : String,
  keyword~ : String,
  message~ : String,
) -> Error {
  PendingStep(step~, keyword~, message~)
}

///|
/// Create a StepFailed error.
pub fn step_failed_error(
  step~ : String,
  keyword~ : String,
  message~ : String,
) -> Error {
  MoonspecError::StepFailed(step~, keyword~, message~)
}

///|
/// Create a ScenarioFailed error.
pub fn scenario_failed_error(
  scenario~ : String,
  feature~ : String,
  errors~ : Array[MoonspecError],
) -> MoonspecError {
  MoonspecError::ScenarioFailed(scenario~, feature~, errors~)
}

///|
/// Create a RunFailed error.
pub fn run_failed_error(
  summary~ : String,
  errors~ : Array[MoonspecError],
) -> Error {
  RunFailed(summary~, errors~)
}

///|
/// Human-readable failure report. `moon test` prints this when
/// `run_or_fail` raises, so it names each failed feature, scenario and step.
pub impl Show for MoonspecError with fn output(self, logger) {
  let lines : Array[String] = []
  error_lines(self, lines, "")
  logger.write_string(lines.join("\n"))
}

///|
pub extend MoonspecError with Show::{to_string, output}

///|
fn error_lines(
  err : MoonspecError,
  lines : Array[String],
  indent : String,
) -> Unit {
  let nested = indent + "  "
  match err {
    UndefinedStep(step~, keyword~, snippet~, suggestions~) => {
      lines.push(step_line(indent, keyword, step))
      lines.push(nested + "Undefined step. Implement it with:")
      push_indented(lines, nested + "  ", snippet)
      if suggestions.length() > 0 {
        lines.push(nested + "Did you mean:")
        for suggestion in suggestions {
          lines.push(nested + "  " + suggestion)
        }
      }
    }
    PendingStep(step~, keyword~, message~) => {
      lines.push(step_line(indent, keyword, step))
      push_indented(lines, nested, "Pending: " + message)
    }
    StepFailed(step~, keyword~, message~) => {
      lines.push(step_line(indent, keyword, step))
      push_indented(lines, nested, message)
    }
    ScenarioFailed(scenario~, feature~, errors~) => {
      lines.push(indent + "Feature: \{feature} / Scenario: \{scenario}")
      for error in errors {
        error_lines(error, lines, nested)
      }
    }
    RunFailed(summary~, errors~) => {
      lines.push(indent + summary)
      for error in errors {
        error_lines(error, lines, indent)
      }
    }
  }
}

///|
fn step_line(indent : String, keyword : String, step : String) -> String {
  indent + keyword.trim(chars=" ").to_owned() + " " + step
}

///|
/// Push each line of `text` with `indent` in front of it.
fn push_indented(lines : Array[String], indent : String, text : String) -> Unit {
  for line in text.split("\n") {
    lines.push(indent + line.to_owned())
  }
}
