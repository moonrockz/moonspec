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
// StepDef::given6 / given6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::given6(
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::given6_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given7 / given7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::given7(
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::given7_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given8 / given8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::given8(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::given8_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given9 / given9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::given9(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::given9_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i, ctx)
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
// StepDef::when6 / when6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::when6(
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::when6_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when7 / when7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::when7(
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::when7_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when8 / when8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::when8(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::when8_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when9 / when9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::when9(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::when9_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i, ctx)
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
// StepDef::then6 / then6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::then6(
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::then6_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then7 / then7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::then7(
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::then7_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then8 / then8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::then8(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::then8_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then9 / then9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::then9(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::then9_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i, ctx)
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

// ---------------------------------------------------------------------------
// StepDef::step6 / step6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::step6(
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] StepDef::step6_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 6)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      handler(a, b, c, d, e, f, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step7 / step7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::step7(
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] StepDef::step7_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 7)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      handler(a, b, c, d, e, f, g, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step8 / step8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::step8(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] StepDef::step8_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 8)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      handler(a, b, c, d, e, f, g, h, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step9 / step9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::step9(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] StepDef::step9_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 9)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      handler(a, b, c, d, e, f, g, h, i, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given10 / given10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::given10(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::given10_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when10 / when10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::when10(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::when10_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then10 / then10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::then10(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::then10_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step10 / step10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::step10(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] StepDef::step10_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 10)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      handler(a, b, c, d, e, f, g, h, i, j, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given11 / given11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::given11(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::given11_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when11 / when11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::when11(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::when11_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then11 / then11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::then11(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::then11_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step11 / step11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::step11(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] StepDef::step11_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 11)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      handler(a, b, c, d, e, f, g, h, i, j, k, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given12 / given12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::given12(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::given12_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when12 / when12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::when12(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::when12_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then12 / then12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::then12(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::then12_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step12 / step12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::step12(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] StepDef::step12_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 12)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given13 / given13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::given13(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::given13_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when13 / when13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::when13(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::when13_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then13 / then13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::then13(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::then13_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step13 / step13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::step13(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] StepDef::step13_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 13)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given14 / given14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::given14(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::given14_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when14 / when14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::when14(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::when14_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then14 / then14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::then14(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::then14_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step14 / step14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::step14(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] StepDef::step14_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 14)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given15 / given15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::given15(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::given15_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when15 / when15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::when15(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::when15_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then15 / then15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::then15(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::then15_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step15 / step15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::step15(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] StepDef::step15_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 15)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given16 / given16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::given16(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::given16_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when16 / when16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::when16(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::when16_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then16 / then16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::then16(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::then16_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step16 / step16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::step16(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] StepDef::step16_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 16)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given17 / given17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::given17(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::given17_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when17 / when17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::when17(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::when17_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then17 / then17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::then17(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::then17_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step17 / step17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::step17(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] StepDef::step17_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 17)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given18 / given18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::given18(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::given18_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when18 / when18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::when18(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::when18_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then18 / then18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::then18(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::then18_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step18 / step18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::step18(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] StepDef::step18_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 18)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given19 / given19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::given19(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::given19_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when19 / when19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::when19(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::when19_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then19 / then19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::then19(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::then19_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step19 / step19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::step19(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] StepDef::step19_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 19)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given20 / given20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::given20(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::given20_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when20 / when20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::when20(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::when20_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then20 / then20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::then20(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::then20_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step20 / step20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::step20(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] StepDef::step20_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 20)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given21 / given21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::given21(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::given21_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when21 / when21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::when21(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::when21_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then21 / then21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::then21(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::then21_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step21 / step21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::step21(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] StepDef::step21_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 21)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::given22 / given22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::given22(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::given22_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Given,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::when22 / when22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::when22(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::when22_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: When,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::then22 / then22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::then22(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::then22_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Then,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, ctx)
    }),
    source,
    id: None,
  }
}

// ---------------------------------------------------------------------------
// StepDef::step22 / step22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::step22(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v)
    }),
    source,
    id: None,
  }
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] StepDef::step22_ctx(
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
  source? : StepSource,
) -> StepDef {
  {
    keyword: Step,
    pattern,
    handler: StepHandler(fn(ctx) {
      validate_arity(ctx, 22)
      let a : A = FromStepArg::from_step_arg(ctx[0])
      let b : B = FromStepArg::from_step_arg(ctx[1])
      let c : C = FromStepArg::from_step_arg(ctx[2])
      let d : D = FromStepArg::from_step_arg(ctx[3])
      let e : E = FromStepArg::from_step_arg(ctx[4])
      let f : F = FromStepArg::from_step_arg(ctx[5])
      let g : G = FromStepArg::from_step_arg(ctx[6])
      let h : H = FromStepArg::from_step_arg(ctx[7])
      let i : I = FromStepArg::from_step_arg(ctx[8])
      let j : J = FromStepArg::from_step_arg(ctx[9])
      let k : K = FromStepArg::from_step_arg(ctx[10])
      let l : L = FromStepArg::from_step_arg(ctx[11])
      let m : M = FromStepArg::from_step_arg(ctx[12])
      let n : N = FromStepArg::from_step_arg(ctx[13])
      let o : O = FromStepArg::from_step_arg(ctx[14])
      let p : P = FromStepArg::from_step_arg(ctx[15])
      let q : Q = FromStepArg::from_step_arg(ctx[16])
      let r : R = FromStepArg::from_step_arg(ctx[17])
      let s : S = FromStepArg::from_step_arg(ctx[18])
      let t : T = FromStepArg::from_step_arg(ctx[19])
      let u : U = FromStepArg::from_step_arg(ctx[20])
      let v : V = FromStepArg::from_step_arg(ctx[21])
      handler(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, ctx)
    }),
    source,
    id: None,
  }
}
