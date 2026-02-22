///|
/// Replace all occurrences of `old` with `new_val` in `s`.
fn string_replace(s : String, old : String, new_val : String) -> String {
  let buf = StringBuilder::new()
  let s_len = s.length()
  let old_len = old.length()
  if old_len == 0 {
    return s
  }
  let mut i = 0
  while i < s_len {
    if i + old_len <= s_len {
      let mut matches = true
      for j = 0; j < old_len; j = j + 1 {
        if s[i + j] != old[j] {
          matches = false
          break
        }
      }
      if matches {
        buf.write_string(new_val)
        i = i + old_len
        continue
      }
    }
    buf.write_char(s[i].to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}

///|
/// Expand a Scenario Outline into concrete scenarios.
/// Returns array of (scenario_name, steps) pairs.
pub fn expand_outline(
  name : String,
  template_steps : Array[(String, String)],
  headers : Array[String],
  rows : Array[Array[String]],
) -> Array[(String, Array[(String, String)])] {
  let results : Array[(String, Array[(String, String)])] = []
  for row in rows {
    // Build parameter suffix for scenario name
    let params : Array[String] = []
    for i = 0; i < headers.length(); i = i + 1 {
      params.push(headers[i] + "=" + row[i])
    }
    let scenario_name = name + " (" + params.join(", ") + ")"
    // Substitute <placeholder> in each step text
    let steps : Array[(String, String)] = []
    for pair in template_steps {
      let (keyword, text) = pair
      let mut expanded_text = text
      for i = 0; i < headers.length(); i = i + 1 {
        expanded_text = string_replace(
          expanded_text,
          "<" + headers[i] + ">",
          row[i],
        )
      }
      steps.push((keyword, expanded_text))
    }
    results.push((scenario_name, steps))
  }
  results
}
