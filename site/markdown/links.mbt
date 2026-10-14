///|
pub fn rewrite_link(dest : String, _ctx : LinkContext) -> Target {
  External(dest)
}

///|
pub fn image_src(dest : String, _ctx : LinkContext) -> String {
  dest
}
