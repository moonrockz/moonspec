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
