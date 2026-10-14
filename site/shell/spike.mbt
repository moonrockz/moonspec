///|
using @html {type Html, html, head, body, meta, title, script, h1, p, button}

///|
/// Spike data. Task 8 replaces it with `@data.SiteData`.
pub(all) struct SpikeData {
  base : String
  title : String
  body : String
} derive(Eq, Debug, ToJson, FromJson)

///|
pub extend SpikeData with Eq::{equal, not_equal}

///|
pub extend SpikeData with @debug.Debug::{to_repr}

///|
pub extend SpikeData with ToJson::{to_json}

///|
pub extend SpikeData with FromJson::{from_json}

///|
/// The whole document. `json` is the serialized `data`; both the
/// pre-render and the browser pass the same string, so both build the same
/// tree.
pub fn spike_component(data : SpikeData, json : String) -> @rabbita.Val[Html] {
  let (count, emit) = @rabbita.create_pure_state(0, update=(n, _msg : Unit) => {
    n + 1
  })
  count.map(n => {
    html(lang="en", [
      head([
        meta(charset="utf-8"),
        title(data.title),
        meta(name="ms-data", content=json),
        script(src=data.base + "index.js", type_="module", ([] : Array[Html])),
      ]),
      body([
        h1(data.title),
        p(id="spike-body", data.body),
        button(id="spike-btn", on_click=emit(()), "clicks: \{n}"),
      ]),
    ])
  })
}
