///|
extern "js" fn read_site_data() -> String =
  #|() => document.querySelector('meta[name="ms-data"]')?.getAttribute('content') ?? ''

///|
fn main {
  let json = read_site_data()
  let data : @shell.SpikeData = @json.from_json(@json.parse(json)) catch {
    _ => abort("moonspec site: invalid ms-data")
  }
  @rabbita.new(() => @shell.spike_component(data, json)).hydrate()
}
