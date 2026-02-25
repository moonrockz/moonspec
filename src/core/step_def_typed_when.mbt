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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
] StepDef::when5(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
] StepDef::when5_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
] StepDef::when6(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
] StepDef::when6_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
] StepDef::when7(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
] StepDef::when7_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
] StepDef::when8(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
] StepDef::when8_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
] StepDef::when9(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
] StepDef::when9_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
] StepDef::when10(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
] StepDef::when10_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
] StepDef::when11(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
] StepDef::when11_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
] StepDef::when12(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
] StepDef::when12_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
] StepDef::when13(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
] StepDef::when13_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
] StepDef::when14(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
] StepDef::when14_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
] StepDef::when15(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
] StepDef::when15_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
] StepDef::when16(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
] StepDef::when16_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
] StepDef::when17(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
] StepDef::when17_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
] StepDef::when18(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
] StepDef::when18_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
] StepDef::when19(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
] StepDef::when19_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
] StepDef::when20(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
] StepDef::when20_ctx(
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

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
  U : FromStepArg,
] StepDef::when21(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
  U : FromStepArg,
] StepDef::when21_ctx(
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
      handler(
        a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, ctx,
      )
    }),
    source,
    id: None,
  }
}

///|
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
  U : FromStepArg,
  V : FromStepArg,
] StepDef::when22(
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
pub fn[
  A : FromStepArg,
  B : FromStepArg,
  C : FromStepArg,
  D : FromStepArg,
  E : FromStepArg,
  F : FromStepArg,
  G : FromStepArg,
  H : FromStepArg,
  I : FromStepArg,
  J : FromStepArg,
  K : FromStepArg,
  L : FromStepArg,
  M : FromStepArg,
  N : FromStepArg,
  O : FromStepArg,
  P : FromStepArg,
  Q : FromStepArg,
  R : FromStepArg,
  S : FromStepArg,
  T : FromStepArg,
  U : FromStepArg,
  V : FromStepArg,
] StepDef::when22_ctx(
  pattern : String,
  handler : (
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    Ctx,
  ) -> Unit raise Error,
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
      handler(
        a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, ctx,
      )
    }),
    source,
    id: None,
  }
}
