///|
pub fn target_href(base : String, target : @markdown.Target) -> String {
  match target {
    Internal(route, None) => @route.href(base, route)
    Internal(route, Some(anchor)) => @route.href(base, route) + "#" + anchor
    Anchor(anchor) => "#" + anchor
    External(url) => url
  }
}

///|
fn md_inlines(base : String, xs : Array[@markdown.Inline]) -> Array[Html] {
  xs.map(x => md_inline(base, x))
}

///|
fn md_inline(base : String, x : @markdown.Inline) -> Html {
  match x {
    Text(s) => @html.text(s)
    Code(s) => @html.code(s)
    Emph(xs) => @html.em(md_inlines(base, xs))
    Strong(xs) => @html.strong(md_inlines(base, xs))
    Strike(xs) => @html.del(md_inlines(base, xs))
    Link(target, xs) =>
      @html.a(href=target_href(base, target), md_inlines(base, xs))
    Image(src, alt) => @html.img(src~, alt~)
    LineBreak => @html.br()
  }
}

///|
/// A highlighted code block.
pub fn code_view(lang : String, code : String) -> Html {
  let spans = @highlight.highlight(lang, code).map(t => {
    match t.kind {
      Plain => @html.text(t.text)
      Keyword => @html.span(class="tk-kw", t.text)
      Str => @html.span(class="tk-str", t.text)
      Comment => @html.span(class="tk-com", t.text)
      Number => @html.span(class="tk-num", t.text)
      Tag => @html.span(class="tk-tag", t.text)
    }
  })
  @html.pre(
    class="ms-code",
    attrs=@html.Attrs::build().data_set("lang", lang),
    [@html.code(spans)],
  )
}

///|
fn md_block(base : String, b : @markdown.Block) -> Html {
  match b {
    Heading(level, id, xs) => {
      let attrs = @html.Attrs::build().id(id)
      let kids = [
        ..md_inlines(base, xs),
        @html.a(
          class="ms-anchor",
          href="#" + id,
          attrs=@html.Attrs::build().aria_hidden("true").tabindex(-1),
          "#",
        ),
      ]
      match level {
        1 => @html.h1(attrs~, kids)
        2 => @html.h2(attrs~, kids)
        3 => @html.h3(attrs~, kids)
        4 => @html.h4(attrs~, kids)
        5 => @html.h5(attrs~, kids)
        _ => @html.h6(attrs~, kids)
      }
    }
    Paragraph(xs) => @html.p(md_inlines(base, xs))
    CodeBlock(lang, code) => code_view(lang, code)
    Quote(bs) => @html.blockquote(bs.map(x => md_block(base, x)))
    BulletList(items) =>
      @html.ul(items.map(item => @html.li(item.map(x => md_block(base, x)))))
    OrderedList(start, items) =>
      @html.ol(
        start~,
        items.map(item => @html.li(item.map(x => md_block(base, x)))),
      )
    Table(header, rows) =>
      @html.div(class="ms-table-wrap", [
        @html.table([
          @html.thead([@html.tr(header.map(c => @html.th(md_inlines(base, c))))]),
          @html.tbody(
            rows.map(r => @html.tr(r.map(c => @html.td(md_inlines(base, c))))),
          ),
        ]),
      ])
    Rule => @html.hr()
  }
}

///|
pub fn md_view(base : String, blocks : Array[@markdown.Block]) -> Html {
  @html.div(class="ms-md", blocks.map(b => md_block(base, b)))
}
