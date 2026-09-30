///|
/// Trait for extracting typed values from step arguments.
/// Implementations convert a StepArg into the target type,
/// raising an Error if the StepValue variant doesn't match.
pub(open) trait FromStepArg {
  fn from_step_arg(StepArg) -> Self raise Error
}

///|
pub impl FromStepArg for Int with fn from_step_arg(arg) {
  match arg.value {
    IntVal(v) => v
    other => raise Failure::Failure("expected IntVal, got \{other}")
  }
}

///|
pub impl FromStepArg for Double with fn from_step_arg(arg) {
  match arg.value {
    FloatVal(v) => v
    DoubleVal(v) => v
    other =>
      raise Failure::Failure("expected FloatVal or DoubleVal, got \{other}")
  }
}

///|
pub impl FromStepArg for Int64 with fn from_step_arg(arg) {
  match arg.value {
    LongVal(v) => v
    other => raise Failure::Failure("expected LongVal, got \{other}")
  }
}

///|
pub impl FromStepArg for Byte with fn from_step_arg(arg) {
  match arg.value {
    ByteVal(v) => v
    other => raise Failure::Failure("expected ByteVal, got \{other}")
  }
}

///|
pub impl FromStepArg for String with fn from_step_arg(arg) {
  match arg.value {
    StringVal(v) => v
    WordVal(v) => v
    AnonymousVal(v) => v
    other =>
      raise Failure::Failure(
        "expected StringVal, WordVal, or AnonymousVal, got \{other}",
      )
  }
}

///|
pub impl FromStepArg for BigInt with fn from_step_arg(arg) {
  match arg.value {
    BigIntegerVal(v) => v
    other => raise Failure::Failure("expected BigIntegerVal, got \{other}")
  }
}

///|
pub impl FromStepArg for @decimal.Decimal with fn from_step_arg(arg) {
  match arg.value {
    BigDecimalVal(v) => v
    other => raise Failure::Failure("expected BigDecimalVal, got \{other}")
  }
}

///|
pub impl FromStepArg for DataTable with fn from_step_arg(arg) {
  match arg.value {
    DataTableVal(v) => v
    other => raise Failure::Failure("expected DataTableVal, got \{other}")
  }
}

///|
pub extend DataTable with FromStepArg::{from_step_arg}

///|
pub impl FromStepArg for DocString with fn from_step_arg(arg) {
  match arg.value {
    DocStringVal(v) => v
    other => raise Failure::Failure("expected DocStringVal, got \{other}")
  }
}

///|
pub extend DocString with FromStepArg::{from_step_arg}
