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
