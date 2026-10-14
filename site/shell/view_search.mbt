///|
fn excerpt_view(segments : Array[@search.Segment]) -> Array[Html] {
  segments.map(s => {
    match s {
      Plain(t) => @html.text(t)
      Hit(t) => @html.mark(t)
    }
  })
}

///|
fn search_view(m : Model, emit : @rabbita.Emit[Msg]) -> Html {
  if !m.search.open {
    return @html.nothing
  }
  let groups = current_results(m)
  let mut position = 0
  let body : Array[Html] = []
  match m.search.index {
    LoadingIndex | NotLoaded =>
      body.push(@html.p(class="ms-search-note", "Loading search…"))
    IndexFailed =>
      body.push(
        @html.p(class="ms-search-note", [
          @html.text("Search is not available. "),
          @html.a(
            href=@route.href(m.config.base, Doc(@route.default_doc_slug)),
            "Open the docs",
          ),
        ]),
      )
    IndexReady(_) =>
      if m.search.query.trim(chars=" ").is_empty() {
        body.push(
          @html.p(
            class="ms-search-note",
            "Type to search the \{m.config.version} docs.",
          ),
        )
      } else if groups.is_empty() {
        body.push(
          @html.p(
            class="ms-search-note",
            "No results for “\{m.search.query}”.",
          ),
        )
      } else {
        for group in groups {
          body.push(@html.p(class="ms-search-group", group.0))
          for hit in group.1 {
            let title = if hit.entry.path.is_empty() {
              hit.entry.page
            } else {
              hit.entry.path.join(" › ")
            }
            body.push(
              @html.a(
                class=class_if(
                  "ms-search-item",
                  "ms-search-selected",
                  position == m.search.selected,
                ),
                href=entry_href(m.config, hit.entry),
                [
                  @html.span(class="ms-search-title", title),
                  @html.span(
                    class="ms-search-excerpt",
                    excerpt_view(hit.excerpt),
                  ),
                ],
              ),
            )
            position = position + 1
          }
        }
      }
  }
  @html.fragment([
    @html.div(
      class="ms-search-backdrop",
      on_click=emit(CloseSearch),
      ([] : Array[Html]),
    ),
    @html.div(
      class="ms-search",
      attrs=@html.Attrs::build().role("dialog").aria_label("Search docs"),
      [
        @html.input(
          id="ms-search-input",
          class="ms-search-input",
          placeholder="Search docs",
          value=m.search.query,
          on_input=emit.map(q => SearchInput(q)),
        ),
        @html.div(class="ms-search-results", body),
        @html.div(class="ms-search-hint", [
          @html.span("↑↓ move"),
          @html.span("↵ open"),
          @html.span("esc close"),
          @html.span(class="ms-search-scope", "Searching \{m.config.version}"),
        ]),
      ],
    ),
  ])
}
