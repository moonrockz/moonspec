# Embed moon.mod.json Version — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Derive the CLI version from the embedded `moon.mod.json` instead of hardcoded strings.

**Architecture:** MoonBit's `:embed` pre-build command embeds `moon.mod.json` as a string constant. A helper function parses the version field from the JSON at runtime. All per-package `*_version()` functions are removed.

**Tech Stack:** MoonBit `:embed`, `@json.parse` (builtin)

---

### Task 1: Add pre-build embed to CLI package

**Files:**
- Modify: `src/cmd/main/moon.pkg`

**Step 1: Add pre-build section to moon.pkg**

The `moon.pkg` file uses a non-JSON format. Add the pre-build config:

```
import {
  "moonrockz/moonspec/codegen",
  "moonrockz/moonspec/config",
  "moonrockz/moonspec/scanner",
  "moonrockz/gherkin",
  "TheWaWaR/clap",
  "moonbitlang/x/fs",
  "moonbitlang/x/sys",
  "moonbitlang/core/env",
}

options(
  "is-main": true,
)

pre-build [
  {
    "input": "../../../moon.mod.json",
    "output": "moon_mod_resource.mbt",
    "command": ":embed -i $input -o $output --text --name moon_mod_json"
  }
]
```

**Step 2: Build to verify embed works**

Run: `moon build --target native 2>&1`
Expected: Build succeeds. File `src/cmd/main/moon_mod_resource.mbt` is generated containing `let moon_mod_json : String`.

**Step 3: Commit**

```
git add src/cmd/main/moon.pkg
git commit -m "build: add pre-build embed of moon.mod.json in CLI package"
```

---

### Task 2: Replace hardcoded version with parsed embedded JSON

**Files:**
- Modify: `src/cmd/main/cli.mbt`

**Step 1: Replace `let version = "0.2.0"` with a version-parsing function**

In `src/cmd/main/cli.mbt`, replace line 2:

```moonbit
let version = "0.2.0"
```

with:

```moonbit
fn get_version() -> String {
  let json = @json.parse(moon_mod_json) catch { _ => return "unknown" }
  match json {
    Object(obj) =>
      match obj.get("version") {
        Some(String(v)) => v
        _ => "unknown"
      }
    _ => "unknown"
  }
}
```

**Step 2: Update cmd_version() to use get_version()**

In `src/cmd/main/cli_commands.mbt`, change:

```moonbit
fn cmd_version() -> Unit {
  println("moonspec \{version}")
}
```

to:

```moonbit
fn cmd_version() -> Unit {
  println("moonspec \{get_version()}")
}
```

**Step 3: Build and verify**

Run: `moon build --target native 2>&1 && ./target/native/release/build/cmd/main/main.exe version`
Expected: `moonspec 0.2.0`

**Step 4: Commit**

```
git add src/cmd/main/cli.mbt src/cmd/main/cli_commands.mbt
git commit -m "feat: derive CLI version from embedded moon.mod.json"
```

---

### Task 3: Remove unused per-package version functions

**Files:**
- Modify: `src/core/lib.mbt` — delete `core_version()` function
- Modify: `src/runner/lib.mbt` — delete `runner_version()` function
- Modify: `src/format/lib.mbt` — delete `format_version()` function
- Modify: `src/codegen/codegen.mbt` — delete `codegen_version()` function

**Step 1: Remove version functions**

`src/core/lib.mbt` — delete lines 3-5 (`pub fn core_version`), keep the doc comment on line 1-2.

`src/runner/lib.mbt` — delete lines 3-5 (`pub fn runner_version`), keep the doc comment.

`src/format/lib.mbt` — delete lines 3-5 (`pub fn format_version`), keep the doc comment.

`src/codegen/codegen.mbt` — delete lines 3-5 (`pub fn codegen_version`), keep the doc comment.

**Step 2: Build and verify**

Run: `moon check 2>&1`
Expected: No errors (warnings OK). No code references these functions.

Run: `moon build --target native 2>&1 && ./target/native/release/build/cmd/main/main.exe version`
Expected: `moonspec 0.2.0`

**Step 3: Commit**

```
git add src/core/lib.mbt src/runner/lib.mbt src/format/lib.mbt src/codegen/codegen.mbt
git commit -m "refactor: remove unused per-package version functions"
```

---

### Task 4: Add moon_mod_resource.mbt to .gitignore

**Files:**
- Modify: `.gitignore` (or create if needed)

**Step 1: Add generated file to .gitignore**

Add this line to `.gitignore`:

```
src/cmd/main/moon_mod_resource.mbt
```

This file is generated at build time and should not be tracked.

**Step 2: Remove from git tracking if already tracked**

Run: `git rm --cached src/cmd/main/moon_mod_resource.mbt 2>/dev/null; true`

**Step 3: Commit**

```
git add .gitignore
git commit -m "build: gitignore generated moon_mod_resource.mbt"
```
