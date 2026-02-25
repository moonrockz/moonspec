///|
/// Trait for extracting typed values from step arguments.
/// Implementations convert a StepArg into the target type,
/// raising an Error if the StepValue variant doesn't match.
pub(open) trait FromStepArg {
  from_step_arg(StepArg) -> Self raise Error
}

///|
impl FromStepArg for Int with from_step_arg(arg) {
  match arg.value {
    IntVal(v) => v
    other => raise Failure::Failure("expected IntVal, got \{other}")
  }
}

///|
impl FromStepArg for Double with from_step_arg(arg) {
  match arg.value {
    FloatVal(v) => v
    DoubleVal(v) => v
    other =>
      raise Failure::Failure("expected FloatVal or DoubleVal, got \{other}")
  }
}

///|
impl FromStepArg for Int64 with from_step_arg(arg) {
  match arg.value {
    LongVal(v) => v
    other => raise Failure::Failure("expected LongVal, got \{other}")
  }
}

///|
impl FromStepArg for Byte with from_step_arg(arg) {
  match arg.value {
    ByteVal(v) => v
    other => raise Failure::Failure("expected ByteVal, got \{other}")
  }
}

///|
impl FromStepArg for String with from_step_arg(arg) {
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
impl FromStepArg for BigInt with from_step_arg(arg) {
  match arg.value {
    BigIntegerVal(v) => v
    other => raise Failure::Failure("expected BigIntegerVal, got \{other}")
  }
}

///|
impl FromStepArg for @decimal.Decimal with from_step_arg(arg) {
  match arg.value {
    BigDecimalVal(v) => v
    other => raise Failure::Failure("expected BigDecimalVal, got \{other}")
  }
}

///|
impl FromStepArg for @any.Any with from_step_arg(arg) {
  match arg.value {
    CustomVal(v) => v
    other => raise Failure::Failure("expected CustomVal, got \{other}")
  }
}

///|
impl FromStepArg for DataTable with from_step_arg(arg) {
  match arg.value {
    DataTableVal(v) => v
    other => raise Failure::Failure("expected DataTableVal, got \{other}")
  }
}

///|
impl FromStepArg for DocString with from_step_arg(arg) {
  match arg.value {
    DocStringVal(v) => v
    other => raise Failure::Failure("expected DocStringVal, got \{other}")
  }
}
