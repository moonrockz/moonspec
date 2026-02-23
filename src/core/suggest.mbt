///|
/// Return the smaller of two integers.
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Compute Levenshtein edit distance between two strings.
fn levenshtein_distance(a : String, b : String) -> Int {
  let m = a.length()
  let n = b.length()
  if m == 0 {
    return n
  }
  if n == 0 {
    return m
  }
  let mut prev : Array[Int] = Array::make(n + 1, 0)
  let mut curr : Array[Int] = Array::make(n + 1, 0)
  for j = 0; j <= n; j = j + 1 {
    prev[j] = j
  }
  for i = 1; i <= m; i = i + 1 {
    curr[0] = i
    for j = 1; j <= n; j = j + 1 {
      let cost = if a[i - 1] == b[j - 1] { 0 } else { 1 }
      let del = prev[j] + 1
      let ins = curr[j - 1] + 1
      let sub = prev[j - 1] + cost
      curr[j] = min(del, min(ins, sub))
    }
    let tmp = prev
    prev = curr
    curr = tmp
  }
  prev[n]
}

///|
/// Normalize a pattern for comparison: replace {int}, {string}, etc. with placeholders.
fn normalize_pattern(pattern : String) -> String {
  let buf = StringBuilder::new()
  let len = pattern.length()
  let mut i = 0
  while i < len {
    if pattern[i] == '{' {
      let mut j = i + 1
      while j < len && pattern[j] != '}' {
        j = j + 1
      }
      if j < len {
        buf.write_string("_")
        i = j + 1
        continue
      }
    }
    buf.write_char(pattern[i].to_int().unsafe_to_char())
    i = i + 1
  }
  buf.to_string()
}

///|
/// Find up to 3 registered step patterns closest to the given step text.
fn find_suggestions(registry : StepRegistry, text : String) -> Array[String] {
  let normalized_text = normalize_pattern(text)
  let candidates : Array[(String, Int)] = []
  for entry in registry.entries {
    let pattern = entry.def.pattern
    let normalized = normalize_pattern(pattern)
    let dist = levenshtein_distance(normalized_text, normalized)
    let threshold = normalized_text.length() / 2
    if dist <= threshold && dist > 0 {
      candidates.push((pattern, dist))
    }
  }
  candidates.sort_by(fn(a, b) { a.1.compare(b.1) })
  let result : Array[String] = []
  let limit = min(candidates.length(), 3)
  for i = 0; i < limit; i = i + 1 {
    result.push(candidates[i].0)
  }
  result
}
