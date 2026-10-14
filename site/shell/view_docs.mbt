///|
fn sidebar(m : Model) -> Html {
  let base = m.config.base
  let link_for = (page : @content.Page) => {
    @html.a(
      class=class_if("ms-side-link", "ms-side-current", page.route == m.route),
      href=@route.href(base, page.route),
      page.title,
    )
  }
  let guides = m.manifest.pages.filter(p => p.group == Guides).map(link_for)
  let migrations = m.manifest.pages
    .filter(p => p.group == Migrations)
    .map(link_for)
  @html.aside(
    class=class_if("ms-sidebar", "ms-sidebar-open", m.menu_open),
    [
      @html.p(class="ms-side-group", "Guide"),
      ..guides,
      @html.p(class="ms-side-group", "Migration"),
      ..migrations,
      @html.p(class="ms-side-group", "Reference"),
      @html.a(
        class="ms-side-link",
        href=@data.api_docs_url,
        "API on mooncakes.io ↗",
      ),
      @html.a(
        class="ms-side-link",
        href=@data.github_repo + "/releases",
        "Releases ↗",
      ),
    ],
  )
}

///|
fn toc_links(doc : @markdown.Document) -> Array[Html] {
  doc.toc.map(e => {
    @html.a(
      class=if e.level == 3 { "ms-toc-link ms-toc-l3" } else { "ms-toc-link" },
      href="#" + e.id,
      e.text,
    )
  })
}

///|
fn next_banner(m : Model) -> Html {
  match m.config.channel {
    Release => @html.nothing
    Next =>
      @html.div(class="ms-banner", [
        @html.text("You are reading the docs for main (unreleased). "),
        @html.a(
          href=@route.href(m.config.release_base, m.route),
          "Go to the \{m.config.release_version} docs.",
        ),
      ])
  }
}

///|
fn prev_next(m : Model, page : @content.Page) -> Html {
  let base = m.config.base
  let (prev, next) = m.manifest.neighbors(page.route)
  @html.div(class="ms-prevnext", [
    match prev {
      Some(p) =>
        @html.a(
          class="ms-prev",
          href=@route.href(base, p.route),
          "← " + p.title,
        )
      None => @html.span("")
    },
    match next {
      Some(n) =>
        @html.a(
          class="ms-next",
          href=@route.href(base, n.route),
          n.title + " →",
        )
      None => @html.span("")
    },
  ])
}

///|
fn docs_view(m : Model, page : @content.Page) -> Html {
  let base = m.config.base
  let source_url = @data.github_repo +
    "/blob/" +
    m.config.git_ref +
    "/" +
    page.source
  let (body, toc) = match m.page {
    Ready(doc) => (md_view(base, doc.blocks), toc_links(doc))
    Loading => (@html.p(class="ms-loading", "Loading…"), [])
    PageFailed =>
      (
        @html.div(class="ms-error", [
          @html.p("This page could not be loaded."),
          @html.a(href=source_url, "Read it on GitHub ↗"),
        ]),
        [],
      )
    NoContent => (@html.nothing, [])
  }
  @html.div(class="ms-docs", [
    sidebar(m),
    @html.article(class="ms-article", [
      next_banner(m),
      @html.div(class="ms-crumbs", [
        @html.a(href=@route.href(base, Doc(@route.default_doc_slug)), "Docs"),
        @html.text(" / " + page.title),
      ]),
      if toc.is_empty() {
        @html.nothing
      } else {
        @html.details(
          class="ms-toc-mobile",
          [@html.summary("On this page"), ..toc],
        )
      },
      body,
      prev_next(m, page),
      @html.a(
        class="ms-edit",
        href=@data.github_repo + "/edit/main/" + page.source,
        "Edit this page on GitHub ↗",
      ),
    ]),
    @html.aside(
      class="ms-toc",
      [@html.p(class="ms-toc-title", "On this page"), ..toc],
    ),
  ])
}
