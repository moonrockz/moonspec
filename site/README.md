# moonspec site

The landing page and docs site at <https://moonrockz.github.io/moonspec/>,
built with [rabbita](https://github.com/moonbit-community/rabbita).

The docs pages are rendered from `docs/guide/*.md` and `docs/migrations/*.md`.
Nothing under `docs/plans/` is published. Design: `docs/plans/2026-10-13-site-design.md`.

## Commands

```bash
moon install moonbit-community/warren@0.4.5   # once
mise run site:dev     # build at base / and serve on http://localhost:8080
mise run site:check   # unit tests, build release + next, link check
```

`mise run site:build -- --content <repo dir> --channel release|next --site-root /moonspec/ --release-version vX.Y.Z --ref <git ref> --out <dir>`
builds one version. The Pages workflow builds the latest `v*` tag at `/moonspec/`
and `main` at `/moonspec/next/`.

## Packages

| Package | Job |
|---|---|
| `route` | Route ADT, base paths |
| `content` | page manifest (publish allowlist, sidebar order) |
| `highlight` | code token scanner |
| `markdown` | cmark AST to document IR, heading ids, TOC, link rewriting |
| `search` | search entries, query, excerpts |
| `data` | site configuration and page data (JSON in `<meta name="ms-data">`) |
| `shell` | the rabbita component: model, update, views |
| `app` | browser entry: hydrates the pre-rendered page |
| `prerender` | native: renders every route, writes content copies and the search index |
| `linkcheck` | native: checks links, routes and the search index of a build |
