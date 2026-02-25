///|
fn validate_arity(ctx : Ctx, expected : Int) -> Unit raise Error {
  let actual = ctx.args().length()
  if actual != expected {
    raise Failure::Failure("expected \{expected} step args, got \{actual}")
  }
}

// ---------------------------------------------------------------------------
// given0 / given0_ctx
// ---------------------------------------------------------------------------

///|
pub fn Setup::given0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::given0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

// ---------------------------------------------------------------------------
// given1 / given1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] Setup::given1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::given1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

// ---------------------------------------------------------------------------
// given2 / given2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::given2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::given2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

// ---------------------------------------------------------------------------
// given3 / given3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::given3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::given3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

// ---------------------------------------------------------------------------
// given4 / given4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::given4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::given4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

// ---------------------------------------------------------------------------
// given5 / given5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::given5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::given5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// ---------------------------------------------------------------------------
// given6 / given6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::given6(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::given6_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f, ctx)
  })
}

// ---------------------------------------------------------------------------
// given7 / given7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::given7(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::given7_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g, ctx)
  })
}

// ---------------------------------------------------------------------------
// given8 / given8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::given8(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::given8_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given9 / given9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::given9(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::given9_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when0 / when0_ctx
// ---------------------------------------------------------------------------

///|
pub fn Setup::when0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::when0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

// ---------------------------------------------------------------------------
// when1 / when1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] Setup::when1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::when1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

// ---------------------------------------------------------------------------
// when2 / when2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::when2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::when2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

// ---------------------------------------------------------------------------
// when3 / when3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::when3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::when3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

// ---------------------------------------------------------------------------
// when4 / when4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::when4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::when4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

// ---------------------------------------------------------------------------
// when5 / when5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::when5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::when5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// ---------------------------------------------------------------------------
// when6 / when6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::when6(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::when6_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f, ctx)
  })
}

// ---------------------------------------------------------------------------
// when7 / when7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::when7(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::when7_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g, ctx)
  })
}

// ---------------------------------------------------------------------------
// when8 / when8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::when8(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::when8_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when9 / when9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::when9(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::when9_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then0 / then0_ctx
// ---------------------------------------------------------------------------

///|
pub fn Setup::then0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::then0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

// ---------------------------------------------------------------------------
// then1 / then1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] Setup::then1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::then1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

// ---------------------------------------------------------------------------
// then2 / then2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::then2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::then2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

// ---------------------------------------------------------------------------
// then3 / then3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::then3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::then3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

// ---------------------------------------------------------------------------
// then4 / then4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::then4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::then4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

// ---------------------------------------------------------------------------
// then5 / then5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::then5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::then5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// ---------------------------------------------------------------------------
// then6 / then6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::then6(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::then6_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f, ctx)
  })
}

// ---------------------------------------------------------------------------
// then7 / then7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::then7(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::then7_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g, ctx)
  })
}

// ---------------------------------------------------------------------------
// then8 / then8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::then8(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::then8_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then9 / then9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::then9(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::then9_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step0 / step0_ctx
// ---------------------------------------------------------------------------

///|
pub fn Setup::step0(
  self : Setup,
  pattern : String,
  handler : () -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler()
  })
}

///|
pub fn Setup::step0_ctx(
  self : Setup,
  pattern : String,
  handler : (Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 0)
    handler(ctx)
  })
}

// ---------------------------------------------------------------------------
// step1 / step1_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg] Setup::step1(
  self : Setup,
  pattern : String,
  handler : (A) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a)
  })
}

///|
pub fn[A : FromStepArg] Setup::step1_ctx(
  self : Setup,
  pattern : String,
  handler : (A, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 1)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    handler(a, ctx)
  })
}

// ---------------------------------------------------------------------------
// step2 / step2_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::step2(
  self : Setup,
  pattern : String,
  handler : (A, B) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg] Setup::step2_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 2)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    handler(a, b, ctx)
  })
}

// ---------------------------------------------------------------------------
// step3 / step3_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::step3(
  self : Setup,
  pattern : String,
  handler : (A, B, C) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg] Setup::step3_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 3)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    handler(a, b, c, ctx)
  })
}

// ---------------------------------------------------------------------------
// step4 / step4_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::step4(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg] Setup::step4_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 4)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    handler(a, b, c, d, ctx)
  })
}

// ---------------------------------------------------------------------------
// step5 / step5_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::step5(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg] Setup::step5_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 5)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    handler(a, b, c, d, e, ctx)
  })
}

// ---------------------------------------------------------------------------
// step6 / step6_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::step6(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg] Setup::step6_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 6)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    handler(a, b, c, d, e, f, ctx)
  })
}

// ---------------------------------------------------------------------------
// step7 / step7_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::step7(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g)
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg] Setup::step7_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
    validate_arity(ctx, 7)
    let a : A = FromStepArg::from_step_arg(ctx[0])
    let b : B = FromStepArg::from_step_arg(ctx[1])
    let c : C = FromStepArg::from_step_arg(ctx[2])
    let d : D = FromStepArg::from_step_arg(ctx[3])
    let e : E = FromStepArg::from_step_arg(ctx[4])
    let f : F = FromStepArg::from_step_arg(ctx[5])
    let g : G = FromStepArg::from_step_arg(ctx[6])
    handler(a, b, c, d, e, f, g, ctx)
  })
}

// ---------------------------------------------------------------------------
// step8 / step8_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::step8(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg] Setup::step8_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step9 / step9_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::step9(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg] Setup::step9_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given10 / given10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::given10(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::given10_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when10 / when10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::when10(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::when10_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then10 / then10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::then10(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::then10_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step10 / step10_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::step10(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg] Setup::step10_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given11 / given11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::given11(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::given11_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when11 / when11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::when11(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::when11_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then11 / then11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::then11(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::then11_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step11 / step11_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::step11(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg] Setup::step11_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given12 / given12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::given12(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::given12_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when12 / when12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::when12(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::when12_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then12 / then12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::then12(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::then12_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step12 / step12_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::step12(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg] Setup::step12_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given13 / given13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::given13(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::given13_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when13 / when13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::when13(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::when13_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then13 / then13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::then13(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::then13_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step13 / step13_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::step13(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg] Setup::step13_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given14 / given14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::given14(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::given14_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when14 / when14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::when14(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::when14_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then14 / then14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::then14(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::then14_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step14 / step14_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::step14(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg] Setup::step14_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given15 / given15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::given15(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::given15_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when15 / when15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::when15(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::when15_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then15 / then15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::then15(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::then15_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step15 / step15_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::step15(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg] Setup::step15_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given16 / given16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::given16(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::given16_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when16 / when16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::when16(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::when16_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then16 / then16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::then16(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::then16_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step16 / step16_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::step16(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg] Setup::step16_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given17 / given17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::given17(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::given17_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when17 / when17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::when17(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::when17_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then17 / then17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::then17(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::then17_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step17 / step17_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::step17(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg] Setup::step17_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given18 / given18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::given18(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::given18_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when18 / when18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::when18(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::when18_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then18 / then18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::then18(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::then18_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step18 / step18_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::step18(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg] Setup::step18_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given19 / given19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::given19(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::given19_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when19 / when19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::when19(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::when19_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then19 / then19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::then19(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::then19_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step19 / step19_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::step19(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg] Setup::step19_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given20 / given20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::given20(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::given20_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when20 / when20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::when20(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::when20_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then20 / then20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::then20(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::then20_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step20 / step20_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::step20(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg] Setup::step20_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given21 / given21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::given21(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::given21_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when21 / when21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::when21(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::when21_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then21 / then21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::then21(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::then21_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step21 / step21_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::step21(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg] Setup::step21_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// given22 / given22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::given22(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::given22_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
) -> Unit {
  self.given(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// when22 / when22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::when22(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::when22_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
) -> Unit {
  self.when(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// then22 / then22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::then22(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::then22_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
) -> Unit {
  self.then(pattern, fn(ctx) {
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
  })
}

// ---------------------------------------------------------------------------
// step22 / step22_ctx
// ---------------------------------------------------------------------------

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::step22(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}

///|
pub fn[A : FromStepArg, B : FromStepArg, C : FromStepArg, D : FromStepArg, E : FromStepArg, F : FromStepArg, G : FromStepArg, H : FromStepArg, I : FromStepArg, J : FromStepArg, K : FromStepArg, L : FromStepArg, M : FromStepArg, N : FromStepArg, O : FromStepArg, P : FromStepArg, Q : FromStepArg, R : FromStepArg, S : FromStepArg, T : FromStepArg, U : FromStepArg, V : FromStepArg] Setup::step22_ctx(
  self : Setup,
  pattern : String,
  handler : (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, Ctx) -> Unit raise Error,
) -> Unit {
  self.step(pattern, fn(ctx) {
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
  })
}
