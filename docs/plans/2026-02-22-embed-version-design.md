# Embed moon.mod.json Version in CLI

**Date:** 2026-02-22

## Problem

Version string `"0.2.0"` is hardcoded in 5 places. When bumping versions, all must be updated manually.

## Design

Use MoonBit's `:embed` pre-build command to embed `moon.mod.json` into the CLI binary at build time, then parse the version from it.

### Changes

1. **`src/cmd/main/moon.pkg`** — Add pre-build embed step for `moon.mod.json` with variable name `moon_mod_json`.

2. **`src/cmd/main/cli.mbt`** — Replace `let version = "0.2.0"` with a function that parses the version from the embedded JSON string.

3. **Delete** unused `*_version()` functions from `src/core/lib.mbt`, `src/runner/lib.mbt`, `src/format/lib.mbt`, `src/codegen/codegen.mbt`.

4. **Update `cmd_version()`** to use the parsed version.

### Result

Version is defined in exactly one place (`moon.mod.json`) and automatically embedded at build time.
