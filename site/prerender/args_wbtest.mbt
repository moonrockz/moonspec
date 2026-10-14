///|
test "parse_args reads every flag" {
  let args = parse_args([
    "prerender", "--content", "../release", "--channel", "next", "--site-root", "/moonspec/",
    "--release-version", "v0.11.0", "--ref", "abc", "--out", "dist/next",
  ])
  assert_eq(
    args,
    Ok({
      content: "../release",
      channel: Next,
      site_root: "/moonspec/",
      release_version: "v0.11.0",
      git_ref: "abc",
      out: "dist/next",
    }),
  )
}

///|
test "parse_args rejects unknown flags and bad channels" {
  assert_true(parse_args(["prerender", "--bogus", "x"]) is Err(_))
  assert_true(parse_args(["prerender", "--channel", "beta"]) is Err(_))
}

///|
test "config_of derives bases from the site root" {
  let args = parse_args([
    "prerender", "--channel", "next", "--site-root", "/moonspec",
  ]).unwrap()
  let c = config_of(args)
  assert_eq(c.base, "/moonspec/next/")
  assert_eq(c.release_base, "/moonspec/")
  assert_eq(c.version, "next")
}

///|
test "page_path places each route in its own directory" {
  assert_eq(page_path(Landing), "index.html")
  assert_eq(page_path(Doc("configuration")), "docs/configuration/index.html")
  assert_eq(page_path(Migration("v0.11.0")), "migrations/v0.11.0/index.html")
}
