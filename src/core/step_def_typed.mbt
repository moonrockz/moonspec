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
