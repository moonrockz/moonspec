///|
pub(all) enum Kind {
  Plain
  Keyword
  Str
  Comment
  Number
  Tag
} derive(Eq, Debug)

///|
pub extend Kind with Eq::{equal, not_equal}

///|
pub extend Kind with @debug.Debug::{to_repr}

///|
pub(all) struct Token {
  kind : Kind
  text : String
} derive(Eq, Debug)

///|
pub extend Token with Eq::{equal, not_equal}

///|
pub extend Token with @debug.Debug::{to_repr}

///|
let moonbit_keywords : Array[String] = [
  "fn", "let", "mut", "if", "else", "match", "for", "while", "loop", "return", "break",
  "continue", "struct", "enum", "trait", "impl", "pub", "priv", "type", "test", "async",
  "raise", "noraise", "try", "catch", "guard", "is", "with", "using", "extern", "derive",
  "suberror", "true", "false",
]

///|
let gherkin_keywords : Array[String] = [
  "Feature:", "Background:", "Scenario Outline:", "Scenario Template:", "Scenario:",
  "Example:", "Rule:", "Examples:", "Scenarios:", "Given", "When", "Then", "And",
  "But", "*",
]

///|
/// Collects tokens and merges neighbouring plain text.
priv struct Out {
  tokens : Array[Token]
}

///|
fn Out::push(self : Out, kind : Kind, text : String) -> Unit {
  if text == "" {
    return
  }
  match (kind, self.tokens.last()) {
    (Plain, Some({ kind: Plain, text: prev, })) => {
      ignore(self.tokens.pop())
      self.tokens.push({ kind: Plain, text: prev + text, })
    }
    _ => self.tokens.push({ kind, text, })
  }
}

///|
fn is_ident_char(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') ||
  (c >= 'A' && c <= 'Z') ||
  (c >= '0' && c <= '9') ||
  c == '_'
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// Index after a string literal that starts at `i` (a `"`). Stops at the end
/// of the line when the string is not closed.
fn string_end(s : Array[Char], i : Int32) -> Int32 {
  let mut j = i + 1
  while j < s.length() && s[j] != '\n' {
    if s[j] == '\\' && j + 1 < s.length() {
      j = j + 2
      continue
    }
    if s[j] == '"' {
      return j + 1
    }
    j = j + 1
  }
  j
}

///|
fn line_end(s : Array[Char], i : Int32) -> Int32 {
  let mut j = i
  while j < s.length() && s[j] != '\n' {
    j = j + 1
  }
  j
}

///|
fn slice(s : Array[Char], from : Int32, to : Int32) -> String {
  String::from_array(s[from:to].to_owned())
}

///|
fn scan_moonbit(s : Array[Char], out : Out) -> Unit {
  let mut i = 0
  while i < s.length() {
    let c = s[i]
    if c == '/' && i + 1 < s.length() && s[i + 1] == '/' {
      let e = line_end(s, i)
      out.push(Comment, slice(s, i, e))
      i = e
    } else if c == '#' && i + 1 < s.length() && s[i + 1] == '|' {
      let e = line_end(s, i)
      out.push(Str, slice(s, i, e))
      i = e
    } else if c == '#' && i + 1 < s.length() && is_ident_char(s[i + 1]) {
      let mut j = i + 1
      while j < s.length() && (is_ident_char(s[j]) || s[j] == '.') {
        j = j + 1
      }
      out.push(Tag, slice(s, i, j))
      i = j
    } else if c == '"' {
      let e = string_end(s, i)
      out.push(Str, slice(s, i, e))
      i = e
    } else if is_digit(c) {
      let mut j = i
      while j < s.length() && (is_digit(s[j]) || s[j] == '_' || s[j] == '.') {
        j = j + 1
      }
      out.push(Number, slice(s, i, j))
      i = j
    } else if is_ident_char(c) {
      let mut j = i
      while j < s.length() && is_ident_char(s[j]) {
        j = j + 1
      }
      let word = slice(s, i, j)
      out.push(
        if moonbit_keywords.contains(word) {
          Keyword
        } else {
          Plain
        },
        word,
      )
      i = j
    } else {
      out.push(Plain, slice(s, i, i + 1))
      i = i + 1
    }
  }
}

///|
/// Strings and numbers inside one Gherkin step or table line.
fn scan_gherkin_rest(
  s : Array[Char],
  from : Int32,
  to : Int32,
  out : Out,
) -> Unit {
  let mut i = from
  while i < to {
    let c = s[i]
    if c == '"' {
      let se = string_end(s, i)
      let e = if se < to { se } else { to }
      out.push(Str, slice(s, i, e))
      i = e
    } else if is_digit(c) && (i == from || !is_ident_char(s[i - 1])) {
      let mut j = i
      while j < to && (is_digit(s[j]) || s[j] == '.') {
        j = j + 1
      }
      out.push(Number, slice(s, i, j))
      i = j
    } else {
      out.push(Plain, slice(s, i, i + 1))
      i = i + 1
    }
  }
}

///|
fn scan_gherkin(s : Array[Char], out : Out) -> Unit {
  let mut i = 0
  while i < s.length() {
    let e = line_end(s, i)
    let mut j = i
    while j < e && (s[j] == ' ' || s[j] == '\t') {
      j = j + 1
    }
    out.push(Plain, slice(s, i, j))
    let rest = slice(s, j, e)
    if rest.has_prefix("#") {
      out.push(Comment, rest)
    } else if rest.has_prefix("@") {
      let mut k = j
      while k < e {
        if s[k] == '@' {
          let mut m = k
          while m < e && s[m] != ' ' {
            m = m + 1
          }
          out.push(Tag, slice(s, k, m))
          k = m
        } else {
          out.push(Plain, slice(s, k, k + 1))
          k = k + 1
        }
      }
    } else {
      let mut matched = false
      for kw in gherkin_keywords {
        let n = kw.length()
        if rest.has_prefix(kw) &&
          (kw.has_suffix(":") || j + n >= e || s[j + n] == ' ') {
          out.push(Keyword, kw)
          scan_gherkin_rest(s, j + n, e, out)
          matched = true
          break
        }
      }
      if !matched {
        scan_gherkin_rest(s, j, e, out)
      }
    }
    if e < s.length() {
      out.push(Plain, "\n")
    }
    i = e + 1
  }
}

///|
fn scan_shell(s : Array[Char], out : Out) -> Unit {
  let mut i = 0
  while i < s.length() {
    let c = s[i]
    if c == '#' && (i == 0 || s[i - 1] == ' ' || s[i - 1] == '\n') {
      let e = line_end(s, i)
      out.push(Comment, slice(s, i, e))
      i = e
    } else if c == '"' || c == '\'' {
      let mut j = i + 1
      while j < s.length() && s[j] != c && s[j] != '\n' {
        j = j + 1
      }
      let e = if j < s.length() && s[j] == c { j + 1 } else { j }
      out.push(Str, slice(s, i, e))
      i = e
    } else {
      out.push(Plain, slice(s, i, i + 1))
      i = i + 1
    }
  }
}

///|
/// Tokens of `code` in `lang`. The token texts concatenate to `code`.
pub fn highlight(lang : String, code : String) -> Array[Token] {
  let out = Out::{ tokens: [], }
  let chars = code.to_array()
  match lang {
    "moonbit" | "mbt" => scan_moonbit(chars, out)
    "gherkin" | "feature" | "cucumber" => scan_gherkin(chars, out)
    "bash" | "sh" | "shell" | "console" | "zsh" => scan_shell(chars, out)
    "json" | "json5" | "jsonc" => scan_moonbit(chars, out)
    _ => out.push(Plain, code)
  }
  out.tokens
}
