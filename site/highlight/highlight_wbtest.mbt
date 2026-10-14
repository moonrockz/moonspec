///|
fn kinds(tokens : Array[Token]) -> String {
  tokens
  .filter(t => t.kind != Plain)
  .map(t => {
    let k = match t.kind {
      Keyword => "kw"
      Str => "str"
      Comment => "com"
      Number => "num"
      Tag => "tag"
      Plain => "plain"
    }
    k + ":" + t.text
  })
  .join(" ")
}

///|
fn joined(tokens : Array[Token]) -> String {
  tokens.map(t => t.text).join("")
}

///|
test "gherkin keywords, strings, numbers, tags, comments" {
  let src = "@smoke\nFeature: Calculator\n  # note\n  Scenario: Add\n    Given a calculator\n    When I add 2 and \"x\"\n"
  let tokens = highlight("gherkin", src)
  assert_eq(joined(tokens), src)
  inspect(
    kinds(tokens),
    content="tag:@smoke kw:Feature: com:# note kw:Scenario: kw:Given kw:When num:2 str:\"x\"",
  )
}

///|
test "moonbit keywords, attributes, strings, comments" {
  let src = "#moonspec.given(\"a {int}\")\nfn f(w : W) -> Unit { // hi\n  let n = 42\n}"
  let tokens = highlight("moonbit", src)
  assert_eq(joined(tokens), src)
  inspect(
    kinds(tokens),
    content="tag:#moonspec.given str:\"a {int}\" kw:fn com:// hi kw:let num:42",
  )
}

///|
test "shell comments and strings; unknown languages are plain" {
  let src = "# 1. add\nmoon add \"moonrockz/moonspec\"\n"
  assert_eq(
    kinds(highlight("bash", src)),
    "com:# 1. add str:\"moonrockz/moonspec\"",
  )
  let plain = highlight("text", "anything 42")
  assert_eq(plain, [{ kind: Plain, text: "anything 42", }])
  assert_eq(highlight("moonbit", ""), [])
}

///|
test "unterminated strings run to the end of the line" {
  let src = "let s = \"open\nnext"
  let tokens = highlight("moonbit", src)
  assert_eq(joined(tokens), src)
  inspect(kinds(tokens), content="kw:let str:\"open")
}
