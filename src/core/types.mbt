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
  NullVal
  DocStringVal(DocString)
  DataTableVal(DataTable)
}

///|
pub impl Show for StepValue with fn output(self, logger) {
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
    NullVal => logger.write_string("NullVal")
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
/// Debug repr reuses the Show output, since CustomVal holds an opaque `Any`.
pub impl @debug.Debug for StepValue with fn to_repr(self) {
  @debug.Repr(self.to_string())
}

///|
pub impl Eq for StepValue with fn equal(self, other) -> Bool {
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
    (NullVal, NullVal) => true
    (DocStringVal(a), DocStringVal(b)) => a == b
    (DataTableVal(a), DataTableVal(b)) => a == b
    _ => false
  }
}

///|
pub extend StepValue with Show::{to_string, output}

///|
pub extend StepValue with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepValue with Eq::{not_equal, equal}

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
pub impl Show for PendingAttachment with fn output(self, logger) {
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
pub impl Eq for PendingAttachment with fn equal(self, other) -> Bool {
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
pub extend PendingAttachment with Show::{to_string, output}

///|
pub extend PendingAttachment with Eq::{not_equal, equal}

///|
/// A step argument carrying both the typed value and the original matched text.
pub(all) struct StepArg {
  value : StepValue
  raw : String
} derive(Debug, Eq)

///|
pub extend StepArg with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepArg with Eq::{not_equal, equal}

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
    @cucumber_expressions.ParamValue::NullVal => NullVal
  }
  { value, raw: param.raw, }
}

///|
/// Step execution context. Wraps matched arguments with scenario/step metadata
/// and an attachment buffer.
pub(all) struct Ctx {
  priv step_args : Array[StepArg]
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  priv attachments : Array[PendingAttachment]
}

///|
/// Create a new Ctx.
#alias(new)
pub fn Ctx::Ctx(
  args : Array[StepArg],
  scenario : ScenarioInfo,
  step : StepInfo,
) -> Ctx {
  {
    step_args: args,
    scenario_info: scenario,
    step_info: step,
    attachments: [],
  }
}

///|
/// Index access to step arguments.
#alias("_[_]")
pub fn Ctx::at(self : Ctx, index : Int) -> StepArg {
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
/// Trait for any context that can buffer attachments.
pub trait Attachable {
  fn attach(Self, String, String, file_name? : String) -> Unit
  fn attach_bytes(Self, Bytes, String, file_name? : String) -> Unit
  fn attach_url(Self, String, String) -> Unit
  fn pending_attachments(Self) -> Array[PendingAttachment]
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
/// Access buffered attachments (for executor draining).
pub fn Ctx::pending_attachments(self : Ctx) -> Array[PendingAttachment] {
  self.attachments
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
} derive(Debug, Eq)

///|
pub extend ScenarioInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ScenarioInfo with Eq::{not_equal, equal}

///|
/// Information about a step being executed.
pub(all) struct StepInfo {
  keyword : String
  text : String
} derive(Debug, Eq)

///|
pub extend StepInfo with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend StepInfo with Eq::{not_equal, equal}

///|
/// Structured error reported to after-hooks.
pub(all) enum HookError {
  StepFailed(step~ : String, keyword~ : StepKeyword, message~ : String)
  ScenarioFailed(
    feature_name~ : String,
    scenario_name~ : String,
    message~ : String
  )
} derive(Debug, Eq)

///|
pub extend HookError with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend HookError with Eq::{not_equal, equal}

///|
/// Result passed to after-hooks indicating pass/fail with structured errors.
pub(all) enum HookResult {
  Passed
  Failed(Array[HookError])
} derive(Debug, Eq)

///|
pub extend HookResult with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend HookResult with Eq::{not_equal, equal}

///|
/// Hook context for test run-level hooks (before/after_test_run).
pub(all) struct RunHookCtx {
  priv attachments : Array[PendingAttachment]
}

///|
#alias(new)
pub fn RunHookCtx::RunHookCtx() -> RunHookCtx {
  { attachments: [], }
}

///|
pub fn RunHookCtx::pending_attachments(
  self : RunHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn RunHookCtx::attach(
  self : RunHookCtx,
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
pub fn RunHookCtx::attach_bytes(
  self : RunHookCtx,
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
pub fn RunHookCtx::attach_url(
  self : RunHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Hook context for test case-level hooks (before/after_test_case).
pub(all) struct CaseHookCtx {
  priv scenario_info : ScenarioInfo
  priv attachments : Array[PendingAttachment]
}

///|
#alias(new)
pub fn CaseHookCtx::CaseHookCtx(scenario : ScenarioInfo) -> CaseHookCtx {
  { scenario_info: scenario, attachments: [], }
}

///|
pub fn CaseHookCtx::scenario(self : CaseHookCtx) -> ScenarioInfo {
  self.scenario_info
}

///|
pub fn CaseHookCtx::pending_attachments(
  self : CaseHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn CaseHookCtx::attach(
  self : CaseHookCtx,
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
pub fn CaseHookCtx::attach_bytes(
  self : CaseHookCtx,
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
pub fn CaseHookCtx::attach_url(
  self : CaseHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Hook context for test step-level hooks (before/after_test_step).
pub(all) struct StepHookCtx {
  priv scenario_info : ScenarioInfo
  priv step_info : StepInfo
  priv attachments : Array[PendingAttachment]
}

///|
#alias(new)
pub fn StepHookCtx::StepHookCtx(
  scenario : ScenarioInfo,
  step : StepInfo,
) -> StepHookCtx {
  { scenario_info: scenario, step_info: step, attachments: [], }
}

///|
pub fn StepHookCtx::scenario(self : StepHookCtx) -> ScenarioInfo {
  self.scenario_info
}

///|
pub fn StepHookCtx::step(self : StepHookCtx) -> StepInfo {
  self.step_info
}

///|
pub fn StepHookCtx::pending_attachments(
  self : StepHookCtx,
) -> Array[PendingAttachment] {
  self.attachments
}

///|
pub fn StepHookCtx::attach(
  self : StepHookCtx,
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
pub fn StepHookCtx::attach_bytes(
  self : StepHookCtx,
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
pub fn StepHookCtx::attach_url(
  self : StepHookCtx,
  url : String,
  media_type : String,
) -> Unit {
  self.attachments.push(PendingAttachment::External(url~, media_type~))
}

///|
/// Immutable wrapper around an array of cell values in a DataTable row.
pub struct Cells {
  priv data : Array[String]
} derive(Debug, Eq)

///|
pub extend Cells with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Cells with Eq::{not_equal, equal}

///|
fn Cells::Cells(data : Array[String]) -> Cells {
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
} derive(Debug, Eq)

///|
pub extend Row with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Row with Eq::{not_equal, equal}

///|
fn Row::Row(cells : Array[String]) -> Row {
  { cells: Cells(cells), }
}

///|
/// Immutable wrapper around an array of rows in a DataTable.
pub struct Rows {
  priv data : Array[Row]
} derive(Debug, Eq)

///|
pub extend Rows with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Rows with Eq::{not_equal, equal}

///|
fn Rows::Rows(data : Array[Row]) -> Rows {
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
} derive(Debug, Eq)

///|
pub extend Column with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Column with Eq::{not_equal, equal}

///|
fn Column::Column(name~ : String, index~ : Int) -> Column {
  { name, index, }
}

///|
/// Immutable wrapper around an array of columns in a DataTable.
pub struct Columns {
  priv data : Array[Column]
} derive(Debug, Eq)

///|
pub extend Columns with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Columns with Eq::{not_equal, equal}

///|
fn Columns::Columns(data : Array[Column]) -> Columns {
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
} derive(Debug, Eq)

///|
pub extend DataTable with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DataTable with Eq::{not_equal, equal}

///|
fn DataTable::DataTable(raw_rows : Array[Array[String]]) -> DataTable {
  let columns = if raw_rows.length() > 0 {
    Columns(raw_rows[0].mapi(fn(i, name) { Column(name~, index=i) }))
  } else {
    Columns([])
  }
  let rows = Rows(raw_rows.map(fn(cells) { Row(cells) }))
  { rows, columns, }
}

///|
/// Construct a DataTable from raw row data (public factory).
pub fn DataTable::from_rows(raw_rows : Array[Array[String]]) -> DataTable {
  DataTable(raw_rows)
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
    let map : Map[String, String] = Map([])
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
} derive(Debug, Eq)

///|
pub extend DocString with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend DocString with Eq::{not_equal, equal}

///|
fn DocString::DocString(content~ : String, media_type? : String) -> DocString {
  { content, media_type, }
}
