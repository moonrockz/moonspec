///|
pub(all) struct Args {
  content : String
  counterpart_content : String?
  channel : @data.Channel
  site_root : String
  release_version : String
  git_ref : String
  out : String
} derive(Eq, Debug)

///|
fn with_slashes(path : String) -> String {
  let p = if path.has_prefix("/") { path } else { "/" + path }
  if p.has_suffix("/") {
    p
  } else {
    p + "/"
  }
}

///|
/// Parses the command line (`argv[0]` is the program name).
pub fn parse_args(argv : Array[String]) -> Result[Args, String] {
  let mut args : Args = {
    content: ".",
    counterpart_content: None,
    channel: Next,
    site_root: "/moonspec/",
    release_version: "v0.0.0",
    git_ref: "main",
    out: "dist",
  }
  let mut i = 1
  while i < argv.length() {
    guard i + 1 < argv.length() else {
      return Err("missing value for \{argv[i]}")
    }
    let value = argv[i + 1]
    match argv[i] {
      "--content" => args = { ..args, content: value, }
      "--counterpart-content" =>
        args = { ..args, counterpart_content: Some(value), }
      "--channel" =>
        match value {
          "release" => args = { ..args, channel: Release, }
          "next" => args = { ..args, channel: Next, }
          _ => return Err("--channel must be release or next, got \{value}")
        }
      "--site-root" => args = { ..args, site_root: with_slashes(value), }
      "--release-version" => args = { ..args, release_version: value, }
      "--ref" => args = { ..args, git_ref: value, }
      "--out" => args = { ..args, out: value, }
      flag => return Err("unknown flag \{flag}")
    }
    i = i + 2
  }
  Ok(args)
}

///|
pub fn config_of(args : Args) -> @data.SiteConfig {
  let release_base = with_slashes(args.site_root)
  let next_base = release_base + "next/"
  match args.channel {
    Release =>
      {
        base: release_base,
        version: args.release_version,
        channel: Release,
        git_ref: args.git_ref,
        release_base,
        next_base,
        release_version: args.release_version,
      }
    Next =>
      {
        base: next_base,
        version: "next",
        channel: Next,
        git_ref: args.git_ref,
        release_base,
        next_base,
        release_version: args.release_version,
      }
  }
}

///|
/// The output file of a route, relative to the output directory.
pub fn page_path(route : @route.Route) -> String {
  match route.to_path() {
    "" => "index.html"
    path => path + "/index.html"
  }
}
