///|
/// A boolean expression over tags, supporting `and`, `or`, `not`,
/// parentheses, and bare `@tag` literals.
pub(all) enum TagExpression {
  TagLiteral(String)
  Not(TagExpression)
  And(TagExpression, TagExpression)
  Or(TagExpression, TagExpression)
  Always // matches everything (empty expression)
} derive(Show, Eq)

///|
/// Parse a tag expression string into a TagExpression AST.
/// An empty string yields `Always` which matches any set of tags.
pub fn TagExpression::parse(input : String) -> TagExpression raise Error {
  let trimmed = trim_string(input)
  if trimmed.is_empty() {
    return Always
  }
  let tokens = tokenize_tags(trimmed)
  let result = parse_or(tokens, 0)
  result.0
}

///|
/// Evaluate whether this expression matches a given set of tags.
pub fn TagExpression::matches(
  self : TagExpression,
  tags : Array[String],
) -> Bool {
  match self {
    Always => true
    TagLiteral(name) => array_contains(tags, name)
    Not(inner) => not(inner.matches(tags))
    And(left, right) => left.matches(tags) && right.matches(tags)
    Or(left, right) => left.matches(tags) || right.matches(tags)
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

///|
fn trim_string(s : String) -> String {
  let chars = s.to_array()
  let len = chars.length()
  let mut start = 0
  let mut end = len
  while start < end && is_whitespace(chars[start]) {
    start = start + 1
  }
  while end > start && is_whitespace(chars[end - 1]) {
    end = end - 1
  }
  if start == 0 && end == len {
    return s
  }
  let buf = StringBuilder::new()
  for i = start; i < end; i = i + 1 {
    buf.write_char(chars[i])
  }
  buf.to_string()
}

///|
fn is_whitespace(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\n' || c == '\r'
}

///|
fn array_contains(arr : Array[String], value : String) -> Bool {
  for item in arr {
    if item == value {
      return true
    }
  }
  false
}

// ---------------------------------------------------------------------------
// Tokenizer
// ---------------------------------------------------------------------------

///|
fn tokenize_tags(input : String) -> Array[String] {
  let tokens : Array[String] = []
  let chars = input.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let c = chars[i]
    if is_whitespace(c) {
      i = i + 1
      continue
    }
    if c == '(' {
      tokens.push("(")
      i = i + 1
      continue
    }
    if c == ')' {
      tokens.push(")")
      i = i + 1
      continue
    }
    // Read a word (tag or keyword)
    let buf = StringBuilder::new()
    while i < len &&
          chars[i] != ' ' &&
          chars[i] != '\t' &&
          chars[i] != '\n' &&
          chars[i] != '\r' &&
          chars[i] != '(' &&
          chars[i] != ')' {
      buf.write_char(chars[i])
      i = i + 1
    }
    tokens.push(buf.to_string())
  }
  tokens
}

// ---------------------------------------------------------------------------
// Recursive descent parser
// Precedence (low to high): or < and < not < atom
// ---------------------------------------------------------------------------

///|
fn parse_or(tokens : Array[String], pos : Int) -> (TagExpression, Int) {
  let result = parse_and(tokens, pos)
  let mut left = result.0
  let mut p = result.1
  while p < tokens.length() && tokens[p] == "or" {
    let next_result = parse_and(tokens, p + 1)
    left = Or(left, next_result.0)
    p = next_result.1
  }
  (left, p)
}

///|
fn parse_and(tokens : Array[String], pos : Int) -> (TagExpression, Int) {
  let result = parse_not(tokens, pos)
  let mut left = result.0
  let mut p = result.1
  while p < tokens.length() && tokens[p] == "and" {
    let next_result = parse_not(tokens, p + 1)
    left = And(left, next_result.0)
    p = next_result.1
  }
  (left, p)
}

///|
fn parse_not(tokens : Array[String], pos : Int) -> (TagExpression, Int) {
  if pos < tokens.length() && tokens[pos] == "not" {
    let result = parse_not(tokens, pos + 1)
    (Not(result.0), result.1)
  } else {
    parse_atom(tokens, pos)
  }
}

///|
fn parse_atom(tokens : Array[String], pos : Int) -> (TagExpression, Int) {
  if pos >= tokens.length() {
    // Unexpected end; return Always as a safe fallback
    return (Always, pos)
  }
  let token = tokens[pos]
  if token == "(" {
    let result = parse_or(tokens, pos + 1)
    // Consume closing ')'
    let close = if result.1 < tokens.length() && tokens[result.1] == ")" {
      result.1 + 1
    } else {
      result.1
    }
    (result.0, close)
  } else {
    (TagLiteral(token), pos + 1)
  }
}
