///|
/// A boolean expression over tags, supporting `and`, `or`, `not`,
/// parentheses, and bare `@tag` literals.
pub(all) enum TagExpression {
  TagLiteral(String)
  Not(TagExpression)
  And(TagExpression, TagExpression)
  Or(TagExpression, TagExpression)
  Always // matches everything (empty expression)
} derive(Debug, Eq)

///|
pub extend TagExpression with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TagExpression with Eq::{not_equal, equal}

///|
/// A syntax error in a tag expression.
///
/// Every variant carries the whole expression, so the message can show it.
pub(all) suberror TagExpressionError {
  /// The expression ended where a tag, `not` or `(` was expected.
  UnexpectedEnd(expression~ : String)
  /// A token appeared where it is not allowed, for example `and @a`,
  /// `@a @b` or `@a)`.
  UnexpectedToken(expression~ : String, token~ : String)
  /// A `(` has no matching `)`.
  UnclosedParen(expression~ : String)
} derive(Eq, Debug)

///|
pub extend TagExpressionError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend TagExpressionError with Eq::{not_equal, equal}

///|
pub extend TagExpressionError with Show::{to_string, output}

///|
pub impl Show for TagExpressionError with fn output(self, logger) {
  let detail = match self {
    UnexpectedEnd(expression~) =>
      (expression, "expected a tag, `not` or `(` but the expression ended")
    UnexpectedToken(expression~, token~) =>
      (expression, "unexpected \"\{token}\"")
    UnclosedParen(expression~) => (expression, "missing `)`")
  }
  logger.write_string(
    "invalid tag expression \{detail.0.escape()}: \{detail.1}",
  )
}

///|
/// Parse a tag expression string into a TagExpression AST.
/// An empty or whitespace-only string yields `Always` which matches any set
/// of tags. Malformed input raises a `TagExpressionError`.
pub fn TagExpression::parse(
  input : String,
) -> TagExpression raise TagExpressionError {
  let trimmed = trim_string(input)
  if trimmed.is_empty() {
    return Always
  }
  let parser = TagParser::{ expression: input, tokens: tokenize_tags(trimmed), }
  let (expr, pos) = parser.parse_or(0)
  if pos < parser.tokens.length() {
    raise UnexpectedToken(expression=input, token=parser.tokens[pos])
  }
  expr
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
    Not(inner) => !inner.matches(tags)
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
  let buf = StringBuilder()
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
    let buf = StringBuilder()
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
priv struct TagParser {
  expression : String
  tokens : Array[String]
}

///|
fn TagParser::parse_or(
  self : TagParser,
  pos : Int32,
) -> (TagExpression, Int32) raise TagExpressionError {
  let (first, next) = self.parse_and(pos)
  let mut left = first
  let mut p = next
  while p < self.tokens.length() && self.tokens[p] == "or" {
    let (right, after) = self.parse_and(p + 1)
    left = Or(left, right)
    p = after
  }
  (left, p)
}

///|
fn TagParser::parse_and(
  self : TagParser,
  pos : Int32,
) -> (TagExpression, Int32) raise TagExpressionError {
  let (first, next) = self.parse_not(pos)
  let mut left = first
  let mut p = next
  while p < self.tokens.length() && self.tokens[p] == "and" {
    let (right, after) = self.parse_not(p + 1)
    left = And(left, right)
    p = after
  }
  (left, p)
}

///|
fn TagParser::parse_not(
  self : TagParser,
  pos : Int32,
) -> (TagExpression, Int32) raise TagExpressionError {
  if pos < self.tokens.length() && self.tokens[pos] == "not" {
    let (inner, next) = self.parse_not(pos + 1)
    (Not(inner), next)
  } else {
    self.parse_atom(pos)
  }
}

///|
fn TagParser::parse_atom(
  self : TagParser,
  pos : Int32,
) -> (TagExpression, Int32) raise TagExpressionError {
  guard pos < self.tokens.length() else {
    raise UnexpectedEnd(expression=self.expression)
  }
  match self.tokens[pos] {
    "(" => {
      let (inner, next) = self.parse_or(pos + 1)
      guard next < self.tokens.length() else {
        raise UnclosedParen(expression=self.expression)
      }
      guard self.tokens[next] == ")" else {
        raise UnexpectedToken(
          expression=self.expression,
          token=self.tokens[next],
        )
      }
      (inner, next + 1)
    }
    ")" | "and" | "or" as token =>
      raise UnexpectedToken(expression=self.expression, token~)
    tag => (TagLiteral(tag), pos + 1)
  }
}
