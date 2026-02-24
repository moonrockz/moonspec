///|
/// A typed value extracted from step text, pattern-matchable for built-in types.
pub(all) enum StepValue {
  IntVal(Int)
  FloatVal(Double)
  DoubleVal(Double)
  LongVal(Int64)
  ByteVal(Byte)
  ShortVal(Int)
  StringVal(String)
  WordVal(String)
  AnonymousVal(String)
  BigDecimalVal(@decimal.Decimal)
  BigIntegerVal(BigInt)
  CustomVal(@any.Any)
  DocStringVal(DocString)
  DataTableVal(DataTable)
}

///|
impl Show for StepValue with output(self, logger) {
  match self {
    IntVal(v) => logger.write_string("IntVal(\{v})")
    FloatVal(v) => logger.write_string("FloatVal(\{v})")
    DoubleVal(v) => logger.write_string("DoubleVal(\{v})")
    LongVal(v) => logger.write_string("LongVal(\{v})")
    ByteVal(v) => logger.write_string("ByteVal(\{v})")
    ShortVal(v) => logger.write_string("ShortVal(\{v})")
    StringVal(v) => logger.write_string("StringVal(\{v})")
    WordVal(v) => logger.write_string("WordVal(\{v})")
    AnonymousVal(v) => logger.write_string("AnonymousVal(\{v})")
    BigDecimalVal(v) => logger.write_string("BigDecimalVal(\{v})")
    BigIntegerVal(v) => logger.write_string("BigIntegerVal(\{v})")
    CustomVal(any) => logger.write_string("CustomVal(<\{any.type_name()}>)")
    DocStringVal(d) => {
      let mt = match d.media_type {
        Some(t) => t
        None => ""
      }
      logger.write_string("DocStringVal(media_type=\{mt})")
    }
    DataTableVal(t) =>
      logger.write_string("DataTableVal(\{t.row_count()}x\{t.col_count()})")
  }
}

///|
impl Eq for StepValue with equal(self, other) -> Bool {
  match (self, other) {
    (IntVal(a), IntVal(b)) => a == b
    (FloatVal(a), FloatVal(b)) => a == b
    (DoubleVal(a), DoubleVal(b)) => a == b
    (LongVal(a), LongVal(b)) => a == b
    (ByteVal(a), ByteVal(b)) => a == b
    (ShortVal(a), ShortVal(b)) => a == b
    (StringVal(a), StringVal(b)) => a == b
    (WordVal(a), WordVal(b)) => a == b
    (AnonymousVal(a), AnonymousVal(b)) => a == b
    (BigDecimalVal(a), BigDecimalVal(b)) => a == b
    (BigIntegerVal(a), BigIntegerVal(b)) => a == b
    (CustomVal(_), CustomVal(_)) => true
    (DocStringVal(a), DocStringVal(b)) => a == b
    (DataTableVal(a), DataTableVal(b)) => a == b
    _ => false
  }
}

///|
/// A buffered attachment waiting to be emitted as an envelope.
pub(all) enum PendingAttachment {
  Embedded(
    body~ : String,
    encoding~ : @cucumber_messages.AttachmentContentEncoding,
    media_type~ : String,
    file_name~ : String?
  )
  External(url~ : String, media_type~ : String)
}

///|
impl Show for PendingAttachment with output(self, logger) {
  match self {
    Embedded(body~, encoding~, media_type~, file_name~) => {
      let enc_str = encoding.to_json().stringify()
      logger.write_string(
        "Embedded(body=\{body}, encoding=\{enc_str}, media_type=\{media_type}, file_name=\{file_name})",
      )
    }
    External(url~, media_type~) =>
      logger.write_string("External(url=\{url}, media_type=\{media_type})")
  }
}

///|
impl Eq for PendingAttachment with equal(self, other) -> Bool {
  match (self, other) {
    (
      Embedded(body=b1, encoding=e1, media_type=m1, file_name=f1),
      Embedded(body=b2, encoding=e2, media_type=m2, file_name=f2),
    ) =>
      b1 == b2 &&
      e1.to_json().stringify() == e2.to_json().stringify() &&
      m1 == m2 &&
      f1 == f2
    (External(url=u1, media_type=m1), External(url=u2, media_type=m2)) =>
      u1 == u2 && m1 == m2
    _ => false
  }
}

///|
/// A step argument carrying both the typed value and the original matched text.
pub(all) struct StepArg {
  value : StepValue
  raw : String
} derive(Show, Eq)

///|
/// Convert a cucumber-expressions Param to a StepArg.
pub fn StepArg::from_param(param : @cucumber_expressions.Param) -> StepArg {
  let value : StepValue = match param.value {
    @cucumber_expressions.ParamValue::IntVal(n) => IntVal(n)
    @cucumber_expressions.ParamValue::FloatVal(f) => FloatVal(f)
    @cucumber_expressions.ParamValue::DoubleVal(f) => DoubleVal(f)
    @cucumber_expressions.ParamValue::LongVal(n) => LongVal(n)
    @cucumber_expressions.ParamValue::ByteVal(b) => ByteVal(b)
    @cucumber_expressions.ParamValue::ShortVal(n) => ShortVal(n)
    @cucumber_expressions.ParamValue::StringVal(s) => StringVal(s)
    @cucumber_expressions.ParamValue::WordVal(s) => WordVal(s)
    @cucumber_expressions.ParamValue::AnonymousVal(s) => AnonymousVal(s)
    @cucumber_expressions.ParamValue::BigDecimalVal(d) => BigDecimalVal(d)
    @cucumber_expressions.ParamValue::BigIntegerVal(bi) => BigIntegerVal(bi)
    @cucumber_expressions.ParamValue::CustomVal(any) => CustomVal(any)
  }
  { value, raw: param.raw }
}

///|
/// Step execution context. Wraps matched arguments with scenario/step metadata
/// and an attachment buffer.
pub(all) struct Ctx {
  priv step_args : Array[StepArg]
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  attachments : Array[PendingAttachment]
}

///|
/// Create a new Ctx.
pub fn Ctx::new(
  args : Array[StepArg],
  scenario : ScenarioInfo,
  step : StepInfo,
) -> Ctx {
  { step_args: args, scenario_info: scenario, step_info: step, attachments: [] }
}

///|
/// Index access to step arguments.
pub fn Ctx::op_get(self : Ctx, index : Int) -> StepArg {
  self.step_args[index]
}

///|
/// Explicit index access to a step argument.
pub fn Ctx::arg(self : Ctx, index : Int) -> StepArg {
  self.step_args[index]
}

///|
/// View of all step arguments.
pub fn Ctx::args(self : Ctx) -> ArrayView[StepArg] {
  self.step_args[:]
}

///|
/// Convenience accessor: returns the StepValue at the given argument index.
pub fn Ctx::value(self : Ctx, index : Int) -> StepValue {
  self.step_args[index].value
}

///|
/// Scenario metadata (feature name, scenario name, tags).
pub fn Ctx::scenario(self : Ctx) -> ScenarioInfo {
  self.scenario_info
}

///|
/// Step metadata (keyword, text).
pub fn Ctx::step(self : Ctx) -> StepInfo {
  self.step_info
}

///|
/// Parse an AttachmentContentEncoding from a JSON string literal.
/// Workaround: enum constructors from external packages are not directly
/// accessible in MoonBit, so we round-trip through JSON.
fn parse_encoding(s : String) -> @cucumber_messages.AttachmentContentEncoding {
  @json.from_json(@json.parse(s) catch { _ => panic() }) catch {
    _ => panic()
  }
}

///|
/// Attach text content to the current step/hook.
pub fn Ctx::attach(
  self : Ctx,
  body : String,
  media_type : String,
  file_name? : String,
) -> Unit {
  let encoding = parse_encoding("\"IDENTITY\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
/// Attach binary content (Base64 encoded) to the current step/hook.
pub fn Ctx::attach_bytes(
  self : Ctx,
  data : Bytes,
  media_type : String,
  file_name? : String,
) -> Unit {
  let body = @base64.encode(data[:])
  let encoding = parse_encoding("\"BASE64\"")
  self.attachments.push(
    PendingAttachment::Embedded(body~, encoding~, media_type~, file_name~),
  )
}

///|
/// Attach an external URL reference to the current step/hook.
pub fn Ctx::attach_url(self : Ctx, url : String, media_type : String) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Result of matching step text against the registry.
pub(all) enum StepMatchResult {
  Matched(StepDef, Array[StepArg])
  Undefined(
    step_text~ : String,
    keyword~ : String,
    snippet~ : String,
    suggestions~ : Array[String]
  )
}

///|
/// Information about a scenario being executed.
pub(all) struct ScenarioInfo {
  feature_name : String
  scenario_name : String
  tags : Array[String]
} derive(Show, Eq)

///|
/// Information about a step being executed.
pub(all) struct StepInfo {
  keyword : String
  text : String
} derive(Show, Eq)

///|
/// Structured error reported to after-hooks.
pub(all) enum HookError {
  StepFailed(step~ : String, keyword~ : StepKeyword, message~ : String)
  ScenarioFailed(
    feature_name~ : String,
    scenario_name~ : String,
    message~ : String,
  )
} derive(Show, Eq)

///|
/// Result passed to after-hooks indicating pass/fail with structured errors.
pub(all) enum HookResult {
  Passed
  Failed(Array[HookError])
} derive(Show, Eq)

///|
/// Immutable wrapper around an array of cell values in a DataTable row.
pub struct Cells {
  priv data : Array[String]

  fn new(data : Array[String]) -> Cells
} derive(Show, Eq)

///|
fn Cells::new(data : Array[String]) -> Cells {
  { data, }
}

///|
pub fn Cells::values(self : Cells) -> ArrayView[String] {
  self.data[:]
}

///|
pub fn Cells::get(self : Cells, index : Int) -> String {
  self.data[index]
}

///|
pub fn Cells::length(self : Cells) -> Int {
  self.data.length()
}

///|
/// A single row in a DataTable, wrapping its cell values in an immutable Cells.
pub(all) struct Row {
  cells : Cells

  fn new(cells : Array[String]) -> Row
} derive(Show, Eq)

///|
fn Row::new(cells : Array[String]) -> Row {
  { cells: Cells(cells) }
}

///|
/// Immutable wrapper around an array of rows in a DataTable.
pub struct Rows {
  priv data : Array[Row]

  fn new(data : Array[Row]) -> Rows
} derive(Show, Eq)

///|
fn Rows::new(data : Array[Row]) -> Rows {
  { data, }
}

///|
pub fn Rows::values(self : Rows) -> ArrayView[Row] {
  self.data[:]
}

///|
pub fn Rows::get(self : Rows, index : Int) -> Row {
  self.data[index]
}

///|
pub fn Rows::length(self : Rows) -> Int {
  self.data.length()
}

///|
/// A named column in a DataTable, derived from the header row.
pub(all) struct Column {
  name : String
  index : Int

  fn new(name~ : String, index~ : Int) -> Column
} derive(Show, Eq)

///|
fn Column::new(name~ : String, index~ : Int) -> Column {
  { name, index }
}

///|
/// Immutable wrapper around an array of columns in a DataTable.
pub struct Columns {
  priv data : Array[Column]

  fn new(data : Array[Column]) -> Columns
} derive(Show, Eq)

///|
fn Columns::new(data : Array[Column]) -> Columns {
  { data, }
}

///|
pub fn Columns::values(self : Columns) -> ArrayView[Column] {
  self.data[:]
}

///|
pub fn Columns::get(self : Columns, index : Int) -> Column {
  self.data[index]
}

///|
pub fn Columns::length(self : Columns) -> Int {
  self.data.length()
}

///|
pub fn Columns::find(self : Columns, name : String) -> Column? {
  for col in self.data {
    if col.name == name {
      return Some(col)
    }
  }
  None
}

///|
/// A DataTable from a Gherkin step. First row is treated as column headers.
pub(all) struct DataTable {
  rows : Rows
  columns : Columns

  fn new(raw_rows : Array[Array[String]]) -> DataTable
} derive(Show, Eq)

///|
fn DataTable::new(raw_rows : Array[Array[String]]) -> DataTable {
  let columns = if raw_rows.length() > 0 {
    Columns(raw_rows[0].mapi(fn(i, name) { Column(name~, index=i) }))
  } else {
    Columns([])
  }
  let rows = Rows(raw_rows.map(fn(cells) { Row(cells) }))
  { rows, columns }
}

///|
/// Construct a DataTable from raw row data (public factory).
pub fn DataTable::from_rows(raw_rows : Array[Array[String]]) -> DataTable {
  DataTable::new(raw_rows)
}

///|
pub fn DataTable::row_count(self : DataTable) -> Int {
  self.rows.length()
}

///|
pub fn DataTable::col_count(self : DataTable) -> Int {
  self.columns.length()
}

///|
pub fn DataTable::as_maps(self : DataTable) -> Array[Map[String, String]] {
  let result : Array[Map[String, String]] = []
  if self.rows.length() <= 1 {
    return result
  }
  let headers = self.columns.values()
  for i = 1; i < self.rows.length(); i = i + 1 {
    let row = self.rows.get(i)
    let map : Map[String, String] = {}
    for j = 0; j < headers.length(); j = j + 1 {
      map[headers[j].name] = row.cells.get(j)
    }
    result.push(map)
  }
  result
}

///|
/// A DocString from a Gherkin step — multi-line text with optional media type.
pub(all) struct DocString {
  content : String
  media_type : String?

  fn new(content~ : String, media_type? : String) -> DocString
} derive(Show, Eq)

///|
fn DocString::new(content~ : String, media_type? : String) -> DocString {
  { content, media_type }
}
