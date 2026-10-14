///|
/// One searchable section of a page: the text under one h2 or h3 heading.
pub(all) struct Entry {
  route : @route.Route
  /// Heading id, or "" for the text before the first h2.
  anchor : String
  /// Page title.
  page : String
  /// Heading texts, for example ["Config Fields", "test_kind (string)"].
  path : Array[String]
  text : String
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend Entry with Eq::{equal, not_equal}

///|
pub extend Entry with @debug.Debug::{to_repr}

///|
pub extend Entry with ToJson::{to_json}

///|
pub extend Entry with FromJson::{from_json}

///|
priv struct Acc {
  page : String
  route : @route.Route
  out : Array[Entry]
  parts : Array[String]
  mut anchor : String
  mut path : Array[String]
  mut h2 : String
}

///|
fn Acc::flush(self : Acc) -> Unit {
  let text = self.parts.filter(p => p != "").join(" ")
  if text != "" || self.path.length() > 0 {
    self.out.push({
      route: self.route,
      anchor: self.anchor,
      page: self.page,
      path: self.path,
      text,
    })
  }
  self.parts.clear()
}

///|
/// The search entries of one page.
pub fn entries_for(
  page : String,
  route : @route.Route,
  doc : @markdown.Document,
) -> Array[Entry] {
  let acc = Acc::{
    page,
    route,
    out: [],
    parts: [],
    anchor: "",
    path: [],
    h2: "",
  }
  for block in doc.blocks {
    match block {
      Heading(1, _, _) => ()
      Heading(2, id, xs) => {
        acc.flush()
        let text = @markdown.inline_text(xs)
        acc.h2 = text
        acc.anchor = id
        acc.path = [text]
      }
      Heading(3, id, xs) => {
        acc.flush()
        let text = @markdown.inline_text(xs)
        acc.anchor = id
        acc.path = if acc.h2 == "" { [text] } else { [acc.h2, text] }
      }
      other => acc.parts.push(@markdown.block_text(other))
    }
  }
  acc.flush()
  acc.out
}

///|
/// Simple one-to-one lower-casing: ASCII, Latin-1, Greek and Cyrillic.
fn lower_char(c : Char) -> Char {
  let n = c.to_int()
  let m = if (n >= 65 && n <= 90) ||
    (n >= 0xC0 && n <= 0xDE && n != 0xD7) ||
    (n >= 0x391 && n <= 0x3A9) ||
    (n >= 0x410 && n <= 0x42F) {
    n + 32
  } else if n >= 0x400 && n <= 0x40F {
    n + 80
  } else {
    n
  }
  m.unsafe_to_char()
}

///|
fn is_word_char(c : Char) -> Bool {
  (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c.to_int() > 127
}

///|
/// Lower-case words; punctuation, `_` and `-` separate words.
pub fn tokenize(s : String) -> Array[String] {
  let out : Array[String] = []
  let cur : Array[Char] = []
  for c0 in s {
    let c = lower_char(c0)
    if is_word_char(c) {
      cur.push(c)
    } else if cur.length() > 0 {
      out.push(String::from_array(cur))
      cur.clear()
    }
  }
  if cur.length() > 0 {
    out.push(String::from_array(cur))
  }
  out
}

///|
priv struct Prepared {
  entry : Entry
  title : Array[String]
  heading : Array[String]
  text : Array[String]
} derive(Eq, Debug)

///|
/// Entries with their tokens, ready to query.
pub struct Index {
  priv items : Array[Prepared]
} derive(Eq, Debug)

///|
pub extend Index with Eq::{equal, not_equal}

///|
pub extend Index with @debug.Debug::{to_repr}

///|
pub fn Index::new(entries : Array[Entry]) -> Index {
  {
    items: entries.map(e => {
      entry: e,
      title: tokenize(e.page),
      heading: tokenize(e.path.join(" ")),
      text: tokenize(e.text),
    }),
  }
}

///|
pub fn Index::size(self : Index) -> Int32 {
  self.items.length()
}

///|
pub(all) enum Segment {
  Plain(String)
  Hit(String)
} derive(Eq, Debug)

///|
pub extend Segment with Eq::{equal, not_equal}

///|
pub extend Segment with @debug.Debug::{to_repr}

///|
pub(all) struct Match {
  entry : Entry
  score : Int32
  excerpt : Array[Segment]
} derive(Eq, Debug)

///|
pub extend Match with Eq::{equal, not_equal}

///|
pub extend Match with @debug.Debug::{to_repr}

///|
fn has_prefix_token(tokens : Array[String], term : String) -> Bool {
  tokens.iter().any(t => t.has_prefix(term))
}

///|
/// Results for `query`, best first. Weights: page title 8, heading 4,
/// text 1; +100 when every query term matches.
pub fn search(
  index : Index,
  query : String,
  limit~ : Int32 = 20,
) -> Array[Match] {
  let terms = tokenize(query)
  if terms.is_empty() {
    return []
  }
  let scored : Array[(Int32, Int32, Entry)] = []
  for i, p in index.items {
    let mut score = 0
    let mut matched = 0
    for t in terms {
      let w = if has_prefix_token(p.title, t) {
        8
      } else if has_prefix_token(p.heading, t) {
        4
      } else if has_prefix_token(p.text, t) {
        1
      } else {
        0
      }
      if w > 0 {
        score = score + w
        matched = matched + 1
      }
    }
    if score > 0 {
      let total = if matched == terms.length() { score + 100 } else { score }
      scored.push((total, i, p.entry))
    }
  }
  scored.sort_by((a, b) => if a.0 != b.0 { b.0 - a.0 } else { a.1 - b.1 })
  let n = if scored.length() < limit { scored.length() } else { limit }
  let out : Array[Match] = []
  for k = 0; k < n; k = k + 1 {
    let (score, _, entry) = scored[k]
    out.push({ entry, score, excerpt: excerpt(entry.text, terms), })
  }
  out
}

///|
/// Up to about 120 characters of `text` around the first match, with every
/// word that starts with a term marked.
pub fn excerpt(text : String, terms : Array[String]) -> Array[Segment] {
  let chars = text.to_array()
  let lchars = chars.map(lower_char)
  let mut first = -1
  for t in terms {
    let tc = t.to_array()
    for j = 0; j + tc.length() <= lchars.length(); j = j + 1 {
      if lchars[j:j + tc.length()].to_owned() == tc {
        if first < 0 || j < first {
          first = j
        }
        break
      }
    }
  }
  let start = if first <= 30 { 0 } else { first - 30 }
  let end = if start + 120 < chars.length() {
    start + 120
  } else {
    chars.length()
  }
  let out : Array[Segment] = []
  if start > 0 {
    out.push(Plain("…"))
  }
  let plain : Array[Char] = []
  let mut i = start
  while i < end {
    let at_word_start = i == 0 || !is_word_char(lchars[i - 1])
    let mut hit = 0
    if at_word_start {
      for t in terms {
        let tc = t.to_array()
        if i + tc.length() <= lchars.length() &&
          lchars[i:i + tc.length()].to_owned() == tc {
          hit = tc.length()
          break
        }
      }
    }
    if hit > 0 {
      if plain.length() > 0 {
        out.push(Plain(String::from_array(plain)))
        plain.clear()
      }
      out.push(Hit(String::from_array(chars[i:i + hit].to_owned())))
      i = i + hit
    } else {
      plain.push(chars[i])
      i = i + 1
    }
  }
  if plain.length() > 0 {
    out.push(Plain(String::from_array(plain)))
  }
  if end < chars.length() {
    out.push(Plain("…"))
  }
  out
}

///|
/// Matches grouped by page title, in first-seen order.
pub fn group_by_page(matches : Array[Match]) -> Array[(String, Array[Match])] {
  let out : Array[(String, Array[Match])] = []
  for m in matches {
    match find_group(out, m.entry.page) {
      Some(i) => out[i].1.push(m)
      None => out.push((m.entry.page, [m]))
    }
  }
  out
}

///|
fn find_group(groups : Array[(String, Array[Match])], page : String) -> Int32? {
  for i, g in groups {
    if g.0 == page {
      return Some(i)
    }
  }
  None
}
