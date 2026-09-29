///|
/// Human-readable failure report, in the style of cucumber-js. `moon test`
/// prints this when `run_or_fail` raises, so it names each failed feature,
/// scenario and step:
///
/// ```text
/// 1 failed, 1 total
///
/// 1) Feature: Add / Scenario: wrong sum # features/add.feature:3
///    ✔ Given the numbers 1 and 2
///    ✖ Then the result is 4
///        Expected 3 to equal 4
///    - And it is logged
/// ```
///
/// Only `RunFailed` uses color, when its `color` field is true.
pub impl Show for MoonspecError with fn output(self, logger) {
  let lines : Array[String] = []
  error_lines(self, lines, "", false)
  logger.write_string(lines.join("\n"))
}

///|
pub extend MoonspecError with Show::{to_string, output}

///|
/// Indent of step lines inside a scenario block, aligned after "1) ".
let item_indent = "   "

///|
/// Extra indent of the detail lines under a step.
let detail_indent = "    "

///|
fn error_lines(
  err : MoonspecError,
  lines : Array[String],
  indent : String,
  color : Bool,
) -> Unit {
  match err {
    UndefinedStep(..) | PendingStep(..) | StepFailed(..) =>
      step_error_lines(err, lines, indent, color)
    ParseFailed(..) => parse_lines(err, lines, indent, color)
    ScenarioFailed(..) => scenario_lines(err, lines, indent, color)
    RunFailed(summary~, errors~, color~) => {
      lines.push(summary)
      for i, error in errors {
        lines.push("")
        error_lines(error, lines, "\{i + 1}) ", color)
      }
    }
  }
}

///|
/// Print a scenario block. `prefix` goes in front of the header line only.
fn scenario_lines(
  err : MoonspecError,
  lines : Array[String],
  prefix : String,
  color : Bool,
) -> Unit {
  guard err is ScenarioFailed(scenario~, feature~, location~, steps~, errors~) else {
    return
  }
  let where_ = match location {
    Some(loc) => " # " + loc
    None => ""
  }
  lines.push(prefix + "Feature: \{feature} / Scenario: \{scenario}" + where_)
  if steps.is_empty() {
    for error in errors {
      error_lines(error, lines, item_indent, color)
    }
    return
  }
  for step in steps {
    match step {
      Passed(keyword~, step~) =>
        lines.push(
          item_indent + paint(step_text("✔", keyword, step), Green, color),
        )
      Skipped(keyword~, step~) =>
        lines.push(
          item_indent + paint(step_text("-", keyword, step), Cyan, color),
        )
      Problem(error) => error_lines(error, lines, item_indent, color)
    }
  }
}

///|
fn parse_lines(
  err : MoonspecError,
  lines : Array[String],
  prefix : String,
  color : Bool,
) -> Unit {
  guard err is ParseFailed(uri~, line~, message~) else { return }
  let where_ = match line {
    Some(n) => uri + ":" + n.to_string()
    None => uri
  }
  lines.push(prefix + "Parse error: " + where_)
  let detail = (if prefix == "" { "" } else { item_indent }) + detail_indent
  push_painted(lines, detail, message, Red, color)
}

///|
fn step_error_lines(
  err : MoonspecError,
  lines : Array[String],
  indent : String,
  color : Bool,
) -> Unit {
  let detail = indent + detail_indent
  match err {
    UndefinedStep(step~, keyword~, snippet~, suggestions~) => {
      lines.push(indent + paint(step_text("?", keyword, step), Yellow, color))
      push_painted(
        lines,
        detail,
        "Undefined step. Implement it with:",
        Yellow,
        color,
      )
      push_painted(lines, detail + "  ", snippet, Yellow, color)
      if suggestions.length() > 0 {
        push_painted(lines, detail, "Did you mean:", Yellow, color)
        for suggestion in suggestions {
          push_painted(lines, detail + "  ", suggestion, Yellow, color)
        }
      }
    }
    PendingStep(step~, keyword~, message~) => {
      lines.push(indent + paint(step_text("?", keyword, step), Yellow, color))
      push_painted(lines, detail, "Pending: " + message, Yellow, color)
    }
    StepFailed(step~, keyword~, message~) => {
      lines.push(indent + paint(step_text("✖", keyword, step), Red, color))
      push_painted(lines, detail, message, Red, color)
    }
    _ => error_lines(err, lines, indent, color)
  }
}

///|
fn step_text(marker : String, keyword : String, step : String) -> String {
  marker + " " + keyword.trim(chars=" ").to_owned() + " " + step
}

///|
/// Push each line of `text` with `indent` in front of it. Each line is painted
/// on its own, so line-based readers never see a color span a line break.
fn push_painted(
  lines : Array[String],
  indent : String,
  text : String,
  c : Color,
  color : Bool,
) -> Unit {
  for line in text.split("\n") {
    lines.push(indent + paint(line.to_owned(), c, color))
  }
}
