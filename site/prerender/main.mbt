///|
async fn main {
  let data : @shell.SpikeData = {
    base: "/",
    title: "Spike",
    body: "Pre-rendered on native: Quote \" < > & </script> done",
  }
  let json = data.to_json().stringify()
  let app = @rabbita.new(() => @shell.spike_component(data, json))
  let html = app.render(url="http://localhost/")
  let doc = if html.has_prefix("<!DOCTYPE") || html.has_prefix("<!doctype") {
    html
  } else {
    "<!DOCTYPE html>\n" + html
  }
  @fs.write_string_to_file("dist/index.html", doc)
}
