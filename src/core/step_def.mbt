///|
/// Keyword classification for a step definition.
pub(all) enum StepKeyword {
  Given
  When
  Then
  Step
} derive(Show, Eq)

///|
/// Optional source location for a step definition (populated by codegen).
pub(all) struct StepSource {
  uri : String?
  line : Int?
} derive(Show, Eq)

///|
pub fn StepSource::new(uri? : String = "", line? : Int = 0) -> StepSource {
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
}

///|
pub fn StepDef::given(
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Given, pattern, handler: StepHandler(handler), source }
}

///|
pub fn StepDef::when(
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: When, pattern, handler: StepHandler(handler), source }
}

///|
pub fn StepDef::then(
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Then, pattern, handler: StepHandler(handler), source }
}

///|
pub fn StepDef::step(
  pattern : String,
  handler : (Array[StepArg]) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  { keyword: Step, pattern, handler: StepHandler(handler), source }
}
