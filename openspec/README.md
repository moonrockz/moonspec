# OpenSpec

## Shared OpenSpec bundle

`html-design` comes from Mission Control's `moonrockz/openspec-ext` bundle.
The schema, templates, licenses and verification script are generated snapshots;
keep repository overrides in `openspec/config.yaml` and `AGENTS.md`.

- Run `mise run openspec:check` to verify the committed file hashes and default schema.
- Run `mise run openspec:setup` to regenerate the six core agent skills with isolated global preferences.
- Run `mise exec -- openspec schema validate html-design` and
  `mise exec -- openspec validate --all --strict` before review.
- New designs are offline `design.html` with inline CSS. Existing changes keep
  their schema metadata and original designs, including Markdown designs.
- OpenSpec requirements and change artifacts are committed project documentation.
  Scratch documents remain local under the existing repository rules.

The extension module awaits publication. Until then, update snapshots from a
Mission Control source checkout with its pinned toolchain:

```shell
mise exec -- moon run apps/openspec-ext/cmd -- install /absolute/path/to/this-repo
```

Run that command from Mission Control, then run this repository's checks. After
release, use `moonx moonrockz/openspec-ext@<published-version>/cmd install .`
with an actual published version. Do not add an unpublished registry dependency.
See [the shared tool guide](https://github.com/moonrockz/mission-control/blob/main/apps/openspec-ext/README.md).
