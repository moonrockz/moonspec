///|
/// Check if source contains a manual `impl World for <type> with configure` block.
/// Uses simple substring matching — no AST parsing needed.
pub fn has_manual_registration(source : String, world_type : String) -> Bool {
  let needle = "impl @moonspec.World for " + world_type + " with configure"
  str_contains(source, needle)
}

///|
/// Check if haystack contains needle as a substring.
fn str_contains(haystack : String, needle : String) -> Bool {
  let hlen = haystack.length()
  let nlen = needle.length()
  if nlen == 0 {
    return true
  }
  if nlen > hlen {
    return false
  }
  let limit = hlen - nlen
  for i = 0; i <= limit; i = i + 1 {
    let mut matched = true
    for j = 0; j < nlen; j = j + 1 {
      if haystack[i + j] != needle[j] {
        matched = false
        break
      }
    }
    if matched {
      return true
    }
  }
  false
}
