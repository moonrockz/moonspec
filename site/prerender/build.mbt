///|
fn dirname(path : String) -> String {
  match path.rev_find("/") {
    Some(i) => path[:i].to_owned()
    None => "."
  }
}

///|
fn ensure_dir(dir : String) -> Unit {
  if dir == "." || dir == "" || dir == "/" || @fs.path_exists(dir) {
    return
  }
  ensure_dir(dirname(dir))
  @fs.create_dir(dir) catch {
    _ => ()
  }
}

///|
fn write_file(path : String, content : String) -> Unit raise {
  ensure_dir(dirname(path))
  @fs.write_string_to_file(path, content)
}

///|
/// Markdown files under `dir`, as (repository path, text).
fn read_markdown_dir(
  content : String,
  dir : String,
) -> Array[(String, String)] raise {
  let full = content + "/" + dir
  if !@fs.path_exists(full) {
    return []
  }
  let names = @fs.read_dir(full).to_owned()
  names.sort()
  let out : Array[(String, String)] = []
  for name in names {
    if name.has_suffix(".md") {
      out.push((dir + "/" + name, @fs.read_file_to_string(full + "/" + name)))
    }
  }
  out
}

///|
async fn render_page(data : @data.SiteData) -> String {
  let json = data.encode()
  let html = @rabbita.new(() => @shell.component(data, json)).render(
    url="http://localhost" + @route.href(data.config.base, data.route),
  )
  html
}

///|
/// A build without guide pages is a wrong `--content` path, not a site.
fn check_manifest(
  manifest : @content.Manifest,
  content : String,
) -> Result[Unit, String] {
  if manifest.pages.iter().any(p => p.group is Guides) {
    Ok(())
  } else {
    Err("no guide pages found under \{content}/docs/guide")
  }
}

///|
/// Builds one version of the site into `args.out`.
pub async fn build_site(args : Args) -> Unit {
  let config = config_of(args)
  let files = [
    ..read_markdown_dir(args.content, "docs/guide"),
    ..read_markdown_dir(args.content, "docs/migrations"),
  ]
  let manifest = @content.Manifest::build(
    files.map(f => { path: f.0, title: @markdown.title_of(f.1), }),
  )
  match check_manifest(manifest, args.content) {
    Ok(_) => ()
    Err(message) => {
      println("prerender: " + message)
      @sys.exit(1)
    }
  }
  let texts : Map[String, String] = Map([])
  for f in files {
    texts.set(f.0, f.1)
  }
  let entries : Array[@search.Entry] = []
  let routes : Array[String] = [""]
  write_file(
    args.out + "/index.html",
    render_page({
      config,
      pages: manifest.pages,
      route: Landing,
      markdown: None,
    }),
  )
  for page in manifest.pages {
    let text = texts.get(page.source).unwrap_or("")
    write_file(
      args.out + "/" + page_path(page.route),
      render_page({
        config,
        pages: manifest.pages,
        route: page.route,
        markdown: Some(text),
      }),
    )
    write_file(args.out + "/content/" + page.source, text)
    let doc = @markdown.parse(
      text,
      @data.link_context(config, manifest, page.source),
    )
    for e in @search.entries_for(page.title, page.route, doc) {
      entries.push(e)
    }
    routes.push(page.route.to_path())
  }
  // `/docs/` shows the default page; GitHub Pages needs a real file for it.
  let default_route : @route.Route = Doc(@route.default_doc_slug)
  match manifest.find(default_route) {
    Some(page) => {
      write_file(
        args.out + "/docs/index.html",
        render_page({
          config,
          pages: manifest.pages,
          route: default_route,
          markdown: Some(texts.get(page.source).unwrap_or("")),
        }),
      )
      routes.push("docs")
    }
    None => ()
  }
  write_file(
    args.out + "/404.html",
    render_page({
      config,
      pages: manifest.pages,
      route: NotFound("404"),
      markdown: None,
    }),
  )
  write_file(args.out + "/search-index.json", Json(entries).stringify())
  write_file(args.out + "/routes.json", Json(routes).stringify())
  println(
    "Built \{routes.length()} pages for \{config.version} at \{config.base} into \{args.out}",
  )
}
