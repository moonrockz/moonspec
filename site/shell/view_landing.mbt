///|
let hero_feature : String =
  #|Feature: Calculator
  #|  Scenario: Addition
  #|    Given a calculator
  #|    When I add 2 and 3
  #|    Then the result should be 5

///|
let hero_step : String =
  #|#moonspec.when("I add {int} and {int}")
  #|fn when_add(world : CalcWorld, a : Int, b : Int) -> Unit {
  #|  world.result = a + b
  #|}

///|
let install_cli : String =
  #|# 1. Add the library
  #|moon add moonrockz/moonspec
  #|moon add moonbitlang/async
  #|# 2. Install the CLI
  #|moon install moonrockz/moonspec/cmd/moonspec
  #|# 3. Generate and run
  #|moonspec gen steps
  #|moonspec gen build features/*.feature -w CalcWorld --apply
  #|moon test --target js

///|
let install_moonx : String =
  #|# 1. Add the library
  #|moon add moonrockz/moonspec
  #|moon add moonbitlang/async
  #|# 2. Nothing to install: moonx runs the CLI from mooncakes.io
  #|# 3. Generate and run
  #|moonx moonrockz/moonspec/cmd/moonspec@latest gen steps
  #|moonx moonrockz/moonspec/cmd/moonspec@latest gen build features/*.feature -w CalcWorld --apply --moonx
  #|moon test --target js

///|
let tiles : Array[(String, String)] = [
  (
    "Native moon test", "One test per scenario: filter with -f, list with --outline, skip with tags. Next adds sync tests on Wasm-GC.",
  ),
  (
    "Typed steps", "Cucumber Expressions decoded to Int, String, DataTable or your own types.",
  ),
  (
    "Codegen CLI", "gen steps and gen build keep tests in step with your .feature files.",
  ),
  (
    "Hooks & attachments", "Before and after the run, each case and each step. Text, bytes and URLs.",
  ),
  (
    "Reports", "Pretty console output, Cucumber Messages (NDJSON) and JUnit XML.",
  ),
  ("Tags, retries, dry-run", "@smoke and not @slow, @retry(3), @skip."),
]

///|
fn tab_attrs(selected : Bool) -> @html.Attrs {
  @html.Attrs::build()
  .role("tab")
  .aria_selected(if selected { "true" } else { "false" })
}

///|
fn landing_view(m : Model, emit : @rabbita.Emit[Msg]) -> Html {
  let base = m.config.base
  let tab = m.install_tab
  @html.div(class="ms-landing", [
    @html.section(class="ms-hero", [
      @html.div(class="ms-hero-text", [
        @html.p(class="ms-eyebrow", "BDD test framework for MoonBit"),
        @html.h1([
          @html.text("Specs in "),
          @html.em("Gherkin"),
          @html.text(". Tests with "),
          @html.em("moon test"),
          @html.text("."),
        ]),
        @html.p(
          class="ms-lead",
          "Parse .feature files, match steps with Cucumber Expressions, and run each scenario as a native moon test test. The next docs describe unreleased root sync APIs and the optional async facade.",
        ),
        @html.div(class="ms-cta", [
          @html.a(
            class="ms-btn ms-btn-primary",
            href=@route.href(base, Doc(@route.default_doc_slug)),
            "Get started",
          ),
          @html.a(class="ms-btn", href="#why", "Why moonspec?"),
        ]),
      ]),
      @html.div(class="ms-hero-code", [
        code_view("gherkin", hero_feature),
        code_view("moonbit", hero_step),
      ]),
    ]),
    @html.section(id="why", class="ms-why", [
      @html.p(class="ms-eyebrow", "Why moonspec"),
      @html.div(
        class="ms-tiles",
        tiles.map(t => @html.div(class="ms-tile", [@html.h3(t.0), @html.p(t.1)])),
      ),
    ]),
    @html.section(class="ms-start", [
      @html.p(class="ms-eyebrow", "Get started in 3 steps"),
      @html.div(class="ms-tabs", attrs=@html.Attrs::build().role("tablist"), [
        @html.button(
          class=class_if("ms-tab", "ms-tab-active", tab == Installed),
          attrs=tab_attrs(tab == Installed),
          on_click=emit(SelectTab(Installed)),
          "Installed CLI",
        ),
        @html.button(
          class=class_if("ms-tab", "ms-tab-active", tab == Moonx),
          attrs=tab_attrs(tab == Moonx),
          on_click=emit(SelectTab(Moonx)),
          "moonx (no install)",
        ),
      ]),
      code_view(
        "bash",
        if tab == Installed {
          install_cli
        } else {
          install_moonx
        },
      ),
    ]),
  ])
}
