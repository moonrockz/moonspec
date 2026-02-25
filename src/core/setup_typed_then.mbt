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
