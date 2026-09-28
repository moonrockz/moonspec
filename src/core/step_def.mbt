///|
/// A unique identifier for a step definition, assigned by the StepRegistry.
pub(all) struct StepDefId {
  priv value : String
} derive(Debug, Eq, Hash)

///|
pub extend StepDefId with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepDefId with Eq::{not_equal, equal}

///|
pub extend StepDefId with Hash::{hash, hash_combine}

///|
fn StepDefId::StepDefId(value : String) -> StepDefId {
  { value, }
}

///|
pub fn StepDefId::to_string(self : StepDefId) -> String {
  self.value
}

///|
/// Keyword classification for a step definition.
pub(all) enum StepKeyword {
  Given
  When
  Then
  Step
} derive(Debug, Eq)

///|
pub extend StepKeyword with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepKeyword with Eq::{not_equal, equal}

///|
/// Optional source location for a step definition (populated by codegen).
pub(all) struct StepSource {
  uri : String?
  line : Int?
} derive(Debug, Eq)

///|
pub extend StepSource with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepSource with Eq::{not_equal, equal}

///|
#alias(new)
pub fn StepSource::StepSource(
  uri? : String = "",
  line? : Int = 0,
) -> StepSource {
  {
    uri: if uri == "" {
      None
    } else {
      Some(uri)
    },
    line: if line == 0 {
      None
    } else {
      Some(line)
    },
  }
}

///|
/// A first-class step definition: keyword, pattern, handler, and optional source.
pub(all) struct StepDef {
  keyword : StepKeyword
  pattern : String
  handler : StepHandler
  source : StepSource?
  mut id : StepDefId?
}

///|
pub fn StepDef::given(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Given, pattern, handler: StepHandler(handler), source, id: None, }
}

///|
pub fn StepDef::when(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: When, pattern, handler: StepHandler(handler), source, id: None, }
}

///|
pub fn StepDef::then(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Then, pattern, handler: StepHandler(handler), source, id: None, }
}

///|
pub fn StepDef::step(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Step, pattern, handler: StepHandler(handler), source, id: None, }
}
