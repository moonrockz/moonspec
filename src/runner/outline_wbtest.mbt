///|
test "expand_outline produces one scenario per examples row" {
  let template_steps = [
    ("Given ", "I have <start> cucumbers"),
    ("When ", "I eat <eat> cucumbers"),
    ("Then ", "I should have <left> cucumbers"),
  ]
  let headers = ["start", "eat", "left"]
  let rows = [["12", "5", "7"], ["20", "5", "15"]]
  let expanded = expand_outline("eating", template_steps, headers, rows)
  assert_eq(expanded.length(), 2)
  assert_eq(expanded[0].0, "eating (start=12, eat=5, left=7)")
  assert_eq(expanded[0].1[0].1, "I have 12 cucumbers")
  assert_eq(expanded[1].0, "eating (start=20, eat=5, left=15)")
}

///|
test "expand_outline with single row" {
  let template_steps = [("Given ", "I have <n> items")]
  let headers = ["n"]
  let rows = [["42"]]
  let expanded = expand_outline("single", template_steps, headers, rows)
  assert_eq(expanded.length(), 1)
  assert_eq(expanded[0].1[0].1, "I have 42 items")
}
