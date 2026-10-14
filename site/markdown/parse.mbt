///|
priv struct Conv {
  ctx : LinkContext
  defs : Map[String, @cmark.LabelDef]
  ids : Map[String, Int32]
  toc : Array[TocEntry]
  mut title : String?
}

///|
/// Parses Markdown and rewrites its links for the site.
pub fn parse(src : String, ctx : LinkContext) -> Document {
  let doc = @cmark.Doc::from_string(heading_auto_ids=true, strict=false, src)
  let conv = Conv::{ ctx, defs: doc.defs, ids: {}, toc: [], title: None, }
  let blocks = conv.blocks(doc.block)
  { title: conv.title.unwrap_or(""), blocks, toc: conv.toc, }
}

///|
/// Text of the first level-1 heading of `src`, or "".
pub fn title_of(src : String) -> String {
  parse(src, { source: "", resolve: _ => None, repo_url: "", git_ref: "", }).title
}

///|
/// `raw`, or `raw-N` when `raw` was used before on this page (GitHub style).
fn Conv::unique_id(self : Conv, raw : String) -> String {
  match self.ids.get(raw) {
    None => {
      self.ids.set(raw, 1)
      raw
    }
    Some(n) => {
      self.ids.set(raw, n + 1)
      raw + "-" + n.to_string()
    }
  }
}

///|
fn Conv::dest(self : Conv, lnk : @cmark.InlineLink) -> String {
  match lnk.reference {
    Inline({ v: ld, .. }) =>
      match ld.dest {
        Some({ v, .. }) => v
        None => ""
      }
    Ref(_, label, _) =>
      match self.defs.get(label.key) {
        Some(LinkDef({ v: ld, .. })) =>
          match ld.dest {
            Some({ v, .. }) => v
            None => ""
          }
        _ => ""
      }
  }
}

///|
fn Conv::inlines(self : Conv, inline : @cmark.Inline) -> Array[Inline] {
  match inline {
    Inlines({ v: xs, .. }) => {
      let out : Array[Inline] = []
      for x in xs.iter() {
        for y in self.inlines(x) {
          out.push(y)
        }
      }
      out
    }
    Text({ v, .. }) => [Text(v)]
    CodeSpan({ v: cs, .. }) => [Code(cs.code())]
    Emphasis({ v: { inline: il, .. }, .. }) => [Emph(self.inlines(il))]
    StrongEmphasis({ v: { inline: il, .. }, .. }) => [Strong(self.inlines(il))]
    ExtStrikethrough({ v: st, .. }) => [Strike(self.inlines(st.0))]
    ExtMathSpan({ v: ms, .. }) => [Code(ms.tex())]
    Link({ v: lnk, .. }) =>
      match rewrite_link(self.dest(lnk), self.ctx) {
        Blocked => self.inlines(lnk.text)
        target => [Link(target, self.inlines(lnk.text))]
      }
    Image({ v: lnk, .. }) => {
      let alt = inline_text(self.inlines(lnk.text))
      match image_src(self.dest(lnk), self.ctx) {
        "" => [Text(alt)]
        src => [Image(src, alt)]
      }
    }
    Autolink({ v: { link, is_email, }, .. }) => {
      let url = if is_email { "mailto:" + link.v } else { link.v }
      match rewrite_link(url, self.ctx) {
        Blocked => [Text(link.v)]
        target => [Link(target, [Text(link.v)])]
      }
    }
    Break({ v: { ty: Hard, .. }, .. }) => [LineBreak]
    Break({ v: { ty: Soft, .. }, .. }) => [Text(" ")]
    RawHtml(_) => []
  }
}

///|
fn code_language(cb : @cmark.CodeBlock) -> String {
  match cb.info_string {
    Some({ v, .. }) =>
      match @cmark.CodeBlock::language_of_info_string(v) {
        Some((lang, _)) => lang
        None => ""
      }
    None => ""
  }
}

///|
fn code_source(cb : @cmark.CodeBlock) -> String {
  let lines : Array[String] = []
  for n in cb.code.iter() {
    lines.push(n.v)
  }
  while lines.length() > 0 && lines[lines.length() - 1] == "" {
    ignore(lines.pop())
  }
  lines.join("\n")
}

///|
fn Conv::table(self : Conv, tbl : @cmark.Table) -> Block {
  let header : Array[Array[Inline]] = []
  let rows : Array[Array[Array[Inline]]] = []
  for item in tbl.rows.iter() {
    let (row, _) = item
    match row.v {
      Header(cells) =>
        for cell in cells.iter() {
          header.push(self.inlines(cell.0))
        }
      Data(cells) => {
        let out : Array[Array[Inline]] = []
        for cell in cells.iter() {
          out.push(self.inlines(cell.0))
        }
        rows.push(out)
      }
      Sep(_) => ()
    }
  }
  Table(header, rows)
}

///|
fn Conv::blocks(self : Conv, block : @cmark.Block) -> Array[Block] {
  match block {
    Blocks({ v: bs, .. }) => {
      let out : Array[Block] = []
      for b in bs.iter() {
        for x in self.blocks(b) {
          out.push(x)
        }
      }
      out
    }
    Heading({ v: { level, inline, id, .. }, .. }) => {
      let content = self.inlines(inline)
      let text = inline_text(content)
      let raw = match id {
        Some(Auto(s)) | Some(Id(s)) => s
        None => text.to_lower()
      }
      let unique = self.unique_id(raw)
      if level == 1 && self.title is None {
        self.title = Some(text)
      }
      if level == 2 || level == 3 {
        self.toc.push({ level, id: unique, text, })
      }
      [Heading(level, unique, content)]
    }
    Paragraph({ v: { inline, .. }, .. }) => [Paragraph(self.inlines(inline))]
    CodeBlock({ v: cb, .. }) | ExtMathBlock({ v: cb, .. }) =>
      [CodeBlock(code_language(cb), code_source(cb))]
    BlockQuote({ v: { block: inner, .. }, .. }) => [Quote(self.blocks(inner))]
    List({ v: { ty, items, .. }, .. }) => {
      let xs : Array[Array[Block]] = []
      for item in items.iter() {
        xs.push(self.blocks(item.v.block))
      }
      match ty {
        Unordered(_) => [BulletList(xs)]
        Ordered(start, _) => [OrderedList(start, xs)]
      }
    }
    ThematicBreak(_) => [Rule]
    ExtTable({ v: tbl, .. }) => [self.table(tbl)]
    BlankLine(_)
    | HtmlBlock(_)
    | LinkRefDefinition(_)
    | ExtFootnoteDefinition(_) => []
  }
}
