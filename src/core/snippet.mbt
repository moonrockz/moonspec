///|
/// Strip trailing spaces from a string.
fn strip_trailing_space(s : String) -> String {
  let len = s.length()
  let mut end = len
  while end > 0 && s[end - 1] == ' ' {
    end = end - 1
  }
  if end == len {
    return s
  }
  let buf = StringBuilder()
  for i = 0; i < end; i = i + 1 {
    buf.write_char(s[i].to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
/// Generate a code snippet for implementing an undefined step.
///
/// Detects potential cucumber expression parameters in the step text:
/// integers become {int}, quoted strings become {string}, decimals become {float}.
fn generate_snippet(step_text : String, keyword : String) -> String {
  let registrar = match keyword {
    "Given " => "given"
    "When " => "when"
    "Then " => "then"
    _ => "step"
  }
  let pattern = infer_pattern(step_text)
  let kw = strip_trailing_space(keyword)
  let buf = StringBuilder()
  buf.write_string("s.")
  buf.write_string(registrar)
  buf.write_string("(\"")
  buf.write_string(pattern)
  buf.write_string("\", fn(ctx) raise {\n")
  buf.write_string("  raise PendingStep(step=\"")
  buf.write_string(pattern)
  buf.write_string("\", keyword=\"")
  buf.write_string(kw)
  buf.write_string("\", message=\"TODO: implement step\")\n")
  buf.write_string("})")
  buf.to_string()
}

///|
/// Infer cucumber expression pattern from concrete step text.
/// Replaces integers with {int}, quoted strings with {string}, decimals with {float}.
fn infer_pattern(text : String) -> String {
  let buf = StringBuilder()
  let len = text.length()
  let mut i = 0
  while i < len {
    let ch = text[i]
    // Detect quoted strings: "..."
    if ch == '"' {
      let mut j = i + 1
      while j < len && text[j] != '"' {
        j = j + 1
      }
      if j < len {
        buf.write_string("{string}")
        i = j + 1
        continue
      }
    }
    // Detect numbers: sequences of digits, optionally with decimal point
    if ch >= '0' && ch <= '9' {
      let mut j = i
      let mut has_dot = false
      while j < len &&
            ((text[j] >= '0' && text[j] <= '9') || (text[j] == '.' && !has_dot)) {
        if text[j] == '.' {
          has_dot = true
        }
        j = j + 1
      }
      if has_dot {
        buf.write_string("{float}")
      } else {
        buf.write_string("{int}")
      }
      i = j
      continue
    }
    buf.write_char(ch.to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}
