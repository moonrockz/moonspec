# moonspec Site: Landing Page and Documentation — Design

- **Date:** 2026-10-13
- **Status:** Approved design; implementation plan to follow
- **Tracking:** bd `moonspec-e1b`

## Purpose

Give moonspec a public website at <https://moonrockz.github.io/moonspec/>.
The site has two parts:

1. A **landing page** that tells MoonBit developers what moonspec is, why to
   use it, and how to start.
2. A **documentation site** that publishes the guides in `docs/guide/` and the
   migration guides in `docs/migrations/`.

The site is built with [rabbita](https://github.com/moonbit-community/rabbita),
the MoonBit web UI framework. moonbitlang.com and the rabbita site also use it.

### Success criteria

- A push to `main` or a new release updates the site with no manual steps.
- The Markdown files in `docs/` stay the single source of truth. The site and
  GitHub never show different text for the same version.
- Every page has a clean URL that returns HTTP 200 and contains the page
  content as HTML before JavaScript runs.
- Readers can search the docs of the version they read.
- A broken internal link fails the build, not production.

## Decisions

| Topic | Decision |
|---|---|
| Docs source | Render the existing Markdown (`docs/guide/*.md`, `docs/migrations/*.md`). `docs/plans/` is never published. |
| API reference | Link to the API docs on mooncakes.io. The site does not generate API docs. |
| Versions | The latest release at `/moonspec/`. `main` at `/moonspec/next/`. |
| Architecture | Rabbita SPA, pre-rendered at build time with `App::render`, hydrated in the browser (approach C). |
| Visual style | The MoonBit/rabbita base tokens with an indigo accent ("moonlight indigo"). |
| Logo | "Avatar lockup": a round crop of the moonrockz logo next to the "moonspec" wordmark. The full moonrockz logo is in the footer. The logo image is not edited. |
| Search | A search index built at build time and searched in the browser by MoonBit code. No external service. |

## Scope

In scope: the landing page, the docs pages, version switching, search, light
and dark themes, the build, the deployment workflow, CI checks.

Out of scope: generated API docs, analytics, a custom domain, docs for versions
older than the latest release, comments, a blog.

## Architecture

### Repository layout

The site is a separate MoonBit module in `site/`. It is not part of the
published `moonrockz/moonspec` package and does not import it.

```
site/
  moon.mod                  # module moonrockz/moonspec-site; preferred_target = "js"
  src/
    route/                  # Route ADT, URL <-> Route, base path (pure)
    content/                # page manifest (pure)
    markdown/               # cmark AST -> rabbita Html, heading ids, TOC, link rewriting (pure)
    search/                 # index builder, tokenizer, query scoring (pure)
    views/                  # nav, landing, docs layout, sidebar, TOC, search modal, footer, 404
    app/                    # js executable: state, routing, content fetch, hydrate
    prerender/              # native executable: renders every route, writes the search index
  public/
    index.html              # HTML shell
    styles.css              # design tokens, light and dark themes
    moonrockz.png           # avatar and footer logo
    favicon.png             # generated from moonrockz.png
mise-tasks/site/
  dev                       # local preview
  build                     # build one version into a directory
  check                     # build both versions and run the link check
.github/workflows/pages.yml # build and deploy
```

Dependencies (pinned):

- `moonbit-community/rabbita@0.16.4`
- `moonbit-community/cmark@0.4.12`
- `moonbit-community/warren@0.4.5` (build tool, installed in CI with `moon install`)
- `Yoorkin/shiki@0.1.0` for code highlighting, if it builds with the current
  toolchain. If it does not build, `markdown/` adds a small highlighter for
  Gherkin, MoonBit and shell.

The `moonrockz/moonspec` package must not ship `site/`. The plan verifies how
to exclude it from `moon publish` (the package already lists `examples/`).

### Rabbita API

Use the current API of rabbita 0.16.4: `create_state` / `create_pure_state`,
`Val::map`, `new(app).mount(...)` / `hydrate()`, `@sub.on_url_changed`,
`@sub.on_url_request`, `@nav.push_url`. Do not use the deprecated `cell`,
`simple_cell` or `static_cell` APIs.

## Routes

```
Route =
  | Landing                      # /
  | Doc(slug)                    # /docs/<slug>
  | Migration(version)           # /migrations/<version>
  | NotFound(path)
```

- `/docs/` opens the first guide (`getting-started`).
- Guide slugs come from the file names: `getting-started`, `step-definitions`,
  `hooks-and-attachments`, `testing-strategies`, `configuration`.
- Migration routes come from the file names in `docs/migrations/`, for
  example `/migrations/v0.11.0`.
- **Base path.** The release build uses `/moonspec/`. The `main` build uses
  `/moonspec/next/`. The build writes the base, the version label and the
  channel (`release` or `next`) as data attributes on the `<html>` element.
  The app reads them at start. `route/` adds and strips the base, so the views
  only see base-free routes.
- **Version picker.** It maps the current route to the same route under the
  other base. If that page does not exist in the other version, it opens the
  docs index.

## Content pipeline

### Manifest

`content/` holds an allowlist of the published pages: slug, title, source
path, sidebar group and order. Only files under `docs/guide/` and
`docs/migrations/` can be in the manifest. The build includes an entry only
when its source file exists in the content tree of that version.

### Markdown rendering

`markdown/` parses with `@cmark.Doc::from_string(heading_auto_ids=true, ...)`
and walks the AST into rabbita `Html`. It does not use `inner_html`.

The same pass:

- Collects h2 and h3 headings with their ids for the "On this page" list.
- Rewrites links:
  - A link to a published `.md` file (relative or absolute in the repo, with
    or without an anchor) becomes a site route.
  - A link to any other repository file becomes a GitHub URL at the commit or
    tag of the build. This includes links into `docs/plans/`.
  - External links stay as they are.
- Marks code blocks with their language for highlighting.

### Sidebar

| Group | Pages |
|---|---|
| Guide | Getting started, Step definitions, Hooks & attachments, Testing strategies, Configuration |
| Migration | One entry per file in `docs/migrations/`, newest first |
| Reference | API on mooncakes.io (external), Releases (external) |

## Pages

### Landing page

From top to bottom:

1. **Nav:** avatar lockup, Docs, Guide, API (mooncakes.io), GitHub, search
   button, version picker, theme toggle.
2. **Hero:** "BDD test framework for MoonBit", the headline "Specs in Gherkin.
   Tests with moon test.", a "Get started" button and a "Why moonspec?"
   button. Beside it, a Gherkin scenario and the matching annotated step
   function.
3. **Why moonspec:** six tiles: native `moon test`, typed steps, codegen CLI,
   hooks and attachments, reports, tags/retries/dry-run.
4. **Get started in 3 steps:** tabs "Installed CLI" and "moonx (no install)",
   each with the add, install-or-run, and generate-and-test commands.
5. **Footer:** the full moonrockz logo, "A moonrockz project", the license,
   mooncakes.io and GitHub links.

The landing content is written as rabbita views. It is not from Markdown.

### Docs page

- Left: the sidebar.
- Center: breadcrumbs, the rendered page, previous/next links, and "Edit this
  page on GitHub" (links to the source file on `main`).
- Right: "On this page" (h2/h3), with the current section marked.
- On `/next/` only, a banner: "You are reading the docs for main
  (unreleased)", with a link to the same page in the release docs.

## Pre-rendering

`prerender/` is a native executable. For each route of a version it:

1. Builds the app with a `ContentSource` that reads Markdown from disk.
2. Calls `App::render(url~)` and writes `dist/<route>/index.html`.
3. Writes `404.html` from the `NotFound` view.

In the browser, `app/` calls `hydrate()` on the pre-rendered page. Later
navigation stays in the SPA. The browser `ContentSource` fetches the Markdown
file that the build copies into `dist/content/`.

`ContentSource` is the only part that differs between native and js. The
views and the Markdown renderer are the same code on both targets.

### Risk and spike

`App::render` is marked experimental. The first task of the plan is a spike:
pre-render one docs route on native, then hydrate it in the browser with
rabbita 0.16.4 and the current toolchain.

If the spike fails, work stops and the result is reported. The fallback is to
skip pre-rendering: copy `index.html` into each route directory and render in
the browser only. The rest of this design does not change.

## Search

### Index

The pre-render step also writes `dist/search-index.json` for its version. It
has one entry per heading section:

```json
{ "route": "/docs/configuration", "anchor": "test_kind-string",
  "page": "Configuration", "path": ["Config Fields", "test_kind (string)"],
  "text": "The kind of test file that moonspec gen tests ..." }
```

The landing page is not indexed. Code blocks are indexed as plain text.

### Query

`search/` is pure MoonBit code:

- Tokenize to lower-case words. Split on punctuation, `_` and `-`.
- Match each query token as a prefix of an indexed token.
- Score with weights: page title > heading > text. Rank entries that match
  all tokens above entries that match some.
- Return the top 20 results, grouped by page, with an excerpt around the first
  match and the matched terms marked.

### UI

- A "Search docs ⌘K" button in the nav. `⌘K`, `Ctrl-K` and `/` open the modal.
- The index loads on the first open.
- `↑`/`↓` move, `Enter` opens `route#anchor`, `Esc` closes.
- The modal searches only the version being read and says so.

## Styling

`public/styles.css` defines design tokens taken from moonbitlang.com and the
rabbita site, with the indigo accent:

| Token | Light | Dark |
|---|---|---|
| `--bg` | `#f9fafb` | `#0f1014` |
| `--surface` | `#ffffff` | `#17181f` |
| `--fg` | `#111827` | `#e5e7eb` |
| `--muted` | `#6b7280` | `#8b93a8` |
| `--border` | `#e5e7eb` | `#26283a` |
| `--accent` | `#4f46e5` | `#a5b4fc` |
| `--accent-2` | `#a5b4fc` | `#c7d2fe` |
| `--code-bg` | `#0d1117` | `#0d0e12` |

- Text font: Manrope (fallback "Avenir Next", "Trebuchet MS", sans-serif).
  Code font: Menlo, Consolas, Monaco, monospace.
- The theme follows `prefers-color-scheme`. The toggle stores the reader's
  choice in `localStorage`.
- The layout works at phone width: the sidebar and the "On this page" list
  collapse into menus.

## Build and deployment

### Local

- `mise run site:dev` runs `warren dev` with `main` content at the base `/`.
- `mise run site:build -- --content <dir> --base <path> --version <label> --channel <release|next> --out <dir>`
  builds one version.
- `mise run site:check` builds the release and next versions into a temporary
  directory and runs the link check.

### Workflow `.github/workflows/pages.yml`

Triggers:

- A push to `main` that changes `docs/**` or `site/**`.
- A published release.
- `workflow_dispatch`.

One job:

1. Check out `main` with full history and tags. The site code always comes
   from `main`, so a site fix goes live without a release.
2. Add a worktree at the latest `v*` tag for the release content.
3. Build the release version (base `/moonspec/`) and the next version (base
   `/moonspec/next/`).
4. Merge the two outputs into one `dist/`. Put the release `404.html` at the
   root.
5. Run the link check.
6. `actions/upload-pages-artifact`, then `actions/deploy-pages`.

The job uses the `github-pages` environment, the permissions `pages: write`
and `id-token: write`, and one concurrency group, so deployments do not
overlap.

GitHub Pages is already set to deploy from GitHub Actions for this repository.

## Error handling

| Case | Behavior |
|---|---|
| Unknown route | The `NotFound` view. GitHub Pages serves `404.html` for unknown paths. |
| Markdown fetch fails in the browser | An error panel with a link to the source file on GitHub. |
| Search index fetch fails | The modal shows "Search is not available" and a link to the docs index. |
| Internal link with no page | The link check fails the build. |
| Route with no HTML file | The link check fails the build. |
| Manifest entry with no source file | The entry is left out of that version (expected for older tags). |

## Testing

- **Unit tests** (`moon test` in `site/`) for the pure packages:
  - `route/`: URL to route and back, base add and strip, the version picker
    mapping.
  - `content/`: the manifest, the allowlist (no `docs/plans/`), missing
    sources.
  - `markdown/`: AST to `Html`, heading ids, TOC, every kind of link rewrite.
  - `search/`: tokenizer, scoring, grouping, excerpts, the index builder.
- **Build check** (`mise run site:check`): every manifest route has an HTML
  file, every internal `href` resolves, every page and heading is in the
  search index.
- **CI:** a new `site` job in `ci.yml` runs the unit tests and `site:check` on
  pull requests. It is added to the `needs` list of `ci-ok`.

## Open items for the plan

1. The `App::render` spike (see "Risk and spike").
2. Whether `Yoorkin/shiki@0.1.0` builds with the current toolchain.
3. How to keep `site/` out of the published `moonrockz/moonspec` package.
4. The favicon: generate it from `moonrockz.png` in the build or commit it.
