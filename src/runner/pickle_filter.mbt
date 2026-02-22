///|
/// Filter compiled pickles by tags, names, or URI+line.
pub struct PickleFilter {
  tag_expression : TagExpression
  scenario_names : Array[String]
}

///|
pub fn PickleFilter::new() -> PickleFilter {
  { tag_expression: Always, scenario_names: [] }
}

///|
pub fn PickleFilter::with_tags(
  self : PickleFilter,
  expr : String,
) -> PickleFilter raise Error {
  let parsed = TagExpression::parse(expr)
  { ..self, tag_expression: parsed }
}

///|
pub fn PickleFilter::with_names(
  self : PickleFilter,
  names : Array[String],
) -> PickleFilter {
  { ..self, scenario_names: names }
}

///|
/// Apply all active filters. Filters are AND'd.
pub fn PickleFilter::apply(
  self : PickleFilter,
  pickles : Array[@cucumber_messages.Pickle],
) -> Array[@cucumber_messages.Pickle] {
  let result : Array[@cucumber_messages.Pickle] = []
  for pickle in pickles {
    if self.matches(pickle) {
      result.push(pickle)
    }
  }
  result
}

///|
fn PickleFilter::matches(
  self : PickleFilter,
  pickle : @cucumber_messages.Pickle,
) -> Bool {
  // Tag filter
  let tag_names = pickle.tags.map(fn(t) { t.name })
  if not(self.tag_expression.matches(tag_names)) {
    return false
  }
  // Name filter
  if not(self.scenario_names.is_empty()) {
    let mut name_match = false
    for name in self.scenario_names {
      if pickle.name == name {
        name_match = true
        break
      }
    }
    if not(name_match) {
      return false
    }
  }
  true
}
