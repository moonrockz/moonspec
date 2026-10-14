///|
/// Where a link goes after rewriting.
pub(all) enum Target {
  /// A site page, with an optional anchor.
  Internal(@route.Route, String?)
  /// An anchor on the same page.
  Anchor(String)
  /// Any other URL (including GitHub links for unpublished repository files).
  External(String)
} derive(Eq, Debug)

///|
pub extend Target with Eq::{equal, not_equal}

///|
pub extend Target with @debug.Debug::{to_repr}

///|
pub(all) enum Inline {
  Text(String)
  Code(String)
  Emph(Array[Inline])
  Strong(Array[Inline])
  Strike(Array[Inline])
  Link(Target, Array[Inline])
  /// Source URL and alt text.
  Image(String, String)
  LineBreak
} derive(Eq, Debug)

///|
pub extend Inline with Eq::{equal, not_equal}

///|
pub extend Inline with @debug.Debug::{to_repr}

///|
pub(all) enum Block {
  /// Level, unique id, content.
  Heading(Int32, String, Array[Inline])
  Paragraph(Array[Inline])
  /// Language (may be empty) and code.
  CodeBlock(String, String)
  Quote(Array[Block])
  BulletList(Array[Array[Block]])
  /// Start number and items.
  OrderedList(Int32, Array[Array[Block]])
  /// Header cells and rows of cells.
  Table(Array[Array[Inline]], Array[Array[Array[Inline]]])
  Rule
} derive(Eq, Debug)

///|
pub extend Block with Eq::{equal, not_equal}

///|
pub extend Block with @debug.Debug::{to_repr}

///|
pub(all) struct TocEntry {
  level : Int32
  id : String
  text : String
} derive(Eq, Debug)

///|
pub extend TocEntry with Eq::{equal, not_equal}

///|
pub extend TocEntry with @debug.Debug::{to_repr}

///|
pub(all) struct Document {
  /// Text of the first level-1 heading, or "".
  title : String
  blocks : Array[Block]
  /// Level-2 and level-3 headings.
  toc : Array[TocEntry]
} derive(Eq, Debug)

///|
pub extend Document with Eq::{equal, not_equal}

///|
pub extend Document with @debug.Debug::{to_repr}

///|
/// What link rewriting needs to know about the page being parsed.
pub(all) struct LinkContext {
  /// Repository path of this file, for example `docs/guide/configuration.md`.
  source : String
  /// The route of a published repository file, or `None`.
  resolve : (String) -> @route.Route?
  /// For example `https://github.com/moonrockz/moonspec`.
  repo_url : String
  /// Tag or commit for GitHub links.
  git_ref : String
}

///|
fn write_inlines(buf : StringBuilder, inlines : Array[Inline]) -> Unit {
  for x in inlines {
    match x {
      Text(s) | Code(s) => buf.write_string(s)
      Emph(xs) | Strong(xs) | Strike(xs) | Link(_, xs) => write_inlines(buf, xs)
      Image(_, alt) => buf.write_string(alt)
      LineBreak => buf.write_char(' ')
    }
  }
}

///|
pub fn inline_text(inlines : Array[Inline]) -> String {
  let buf = StringBuilder()
  write_inlines(buf, inlines)
  buf.to_string()
}

///|
/// Plain text of a block, with spaces between parts.
pub fn block_text(block : Block) -> String {
  match block {
    Heading(_, _, xs) | Paragraph(xs) => inline_text(xs)
    CodeBlock(_, code) => code
    Quote(bs) => bs.map(block_text).join(" ")
    BulletList(items) | OrderedList(_, items) =>
      items.map(item => item.map(block_text).join(" ")).join(" ")
    Table(header, rows) => {
      let parts = header.map(inline_text)
      for row in rows {
        for cell in row {
          parts.push(inline_text(cell))
        }
      }
      parts.join(" ")
    }
    Rule => ""
  }
}
