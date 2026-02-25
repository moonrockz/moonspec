// ---------------------------------------------------------------------------
// StepDef::given0 / given0_ctx
// ---------------------------------------------------------------------------

///|
pub fn StepDef::given0(
  pattern : String,
  handler : () -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler()
    }),
    source,
    id: None,
  }
}

///|
pub fn StepDef::given0_ctx(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler(ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given1 / given1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] StepDef::given1(
  pattern : String,
  handler : (A) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::given1_ctx(
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given2 / given2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::given2(
  pattern : String,
  handler : (A, B) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::given2_ctx(
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given3 / given3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::given3(
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::given3_ctx(
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given4 / given4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::given4(
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::given4_ctx(
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given5 / given5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::given5(
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::given5_ctx(
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when0 / when0_ctx
// ---------------------------------------------------------------------------

///|
pub fn StepDef::when0(
  pattern : String,
  handler : () -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler()
    }),
    source,
    id: None,
  }
}

///|
pub fn StepDef::when0_ctx(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler(ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when1 / when1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] StepDef::when1(
  pattern : String,
  handler : (A) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::when1_ctx(
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when2 / when2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::when2(
  pattern : String,
  handler : (A, B) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::when2_ctx(
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when3 / when3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::when3(
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::when3_ctx(
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when4 / when4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::when4(
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::when4_ctx(
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when5 / when5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::when5(
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::when5_ctx(
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then0 / then0_ctx
// ---------------------------------------------------------------------------

///|
pub fn StepDef::then0(
  pattern : String,
  handler : () -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler()
    }),
    source,
    id: None,
  }
}

///|
pub fn StepDef::then0_ctx(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler(ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then1 / then1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] StepDef::then1(
  pattern : String,
  handler : (A) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::then1_ctx(
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then2 / then2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::then2(
  pattern : String,
  handler : (A, B) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::then2_ctx(
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then3 / then3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::then3(
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::then3_ctx(
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then4 / then4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::then4(
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::then4_ctx(
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then5 / then5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::then5(
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::then5_ctx(
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step0 / step0_ctx
// ---------------------------------------------------------------------------

///|
pub fn StepDef::step0(
  pattern : String,
  handler : () -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler()
    }),
    source,
    id: None,
  }
}

///|
pub fn StepDef::step0_ctx(
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 0)
      handler(ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step1 / step1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] StepDef::step1(
  pattern : String,
  handler : (A) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg] StepDef::step1_ctx(
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 1)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      handler(a, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step2 / step2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::step2(
  pattern : String,
  handler : (A, B) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg] StepDef::step2_ctx(
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 2)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      handler(a, b, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step3 / step3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::step3(
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] StepDef::step3_ctx(
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 3)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      handler(a, b, c, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step4 / step4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::step4(
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] StepDef::step4_ctx(
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 4)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      handler(a, b, c, d, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step5 / step5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::step5(
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] StepDef::step5_ctx(
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 5)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      handler(a, b, c, d, e, ctx)
    }),
    source,
    id: None,
  }
}
