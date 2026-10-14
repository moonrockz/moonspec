///|
extern "js" fn read_site_data() -> String =
  #|() => document.querySelector('meta[name="ms-data"]')?.getAttribute('content') ?? ''

///|
/// Stops the browser's own handling of the site's shortcuts. Rabbita's
/// key subscription never calls `preventDefault`, so Ctrl-K would still
/// focus the address bar and `/` would open Firefox quick find. Runs in
/// the capture phase on `window`, ahead of the subscription, and changes
/// no DOM.
extern "js" fn install_key_guard() -> Unit =
  #|() => {
  #|  const editable = (t) => !!t && (t.isContentEditable || ['INPUT', 'TEXTAREA', 'SELECT'].includes(t.tagName))
  #|  window.addEventListener('keydown', (e) => {
  #|    const k = e.key
  #|    if ((e.ctrlKey || e.metaKey) && (k === 'k' || k === 'K')) {
  #|      e.preventDefault()
  #|    } else if (k === '/' && !e.ctrlKey && !e.metaKey && !e.altKey) {
  #|      if (editable(e.target)) {
  #|        // Typing a slash: the site must not treat it as a shortcut.
  #|        e.stopImmediatePropagation()
  #|      } else {
  #|        e.preventDefault()
  #|      }
  #|    } else if ((k === 'ArrowUp' || k === 'ArrowDown' || k === 'Enter') && document.querySelector('.ms-search')) {
  #|      e.preventDefault()
  #|    }
  #|  }, true)
  #|}

///|
fn main {
  install_key_guard()
  let json = read_site_data()
  match @data.SiteData::decode(json) {
    Some(data) => @rabbita.new(() => @shell.component(data, json)).hydrate()
    None => abort("moonspec site: invalid ms-data")
  }
}
