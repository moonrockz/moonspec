///|
extern "js" fn read_site_data() -> String =
  #|() => document.querySelector('meta[name="ms-data"]')?.getAttribute('content') ?? ''

///|
fn main {
  let json = read_site_data()
  match @data.SiteData::decode(json) {
    Some(data) => @rabbita.new(() => @shell.component(data, json)).hydrate()
    None => abort("moonspec site: invalid ms-data")
  }
}
