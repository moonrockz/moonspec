# Configuration Reference

moonspec supports configuration through config files, runtime options, and CLI flags. These layers compose: config files set project defaults, CLI flags override them for one-off runs, and `RunOptions` controls runtime behavior programmatically.

---

## Config File (`moonspec.json5` / `moonspec.json`)

moonspec auto-discovers config files in the current working directory:

| File              | Role     | Format |
|-------------------|----------|--------|
| `moonspec.json`   | Base     | JSON5  |
| `moonspec.json5`  | Override | JSON5  |

Both files are parsed as JSON5, which means you can use comments, trailing commas, and unquoted keys.

When both files exist, `moonspec.json` serves as the base configuration and `moonspec.json5` provides overrides using merge semantics (see [Merge Behavior](#merge-behavior) below). When only one file exists, it is used as-is.

To bypass auto-discovery entirely, pass an explicit path with the `--config` flag:

```bash
moonspec gen tests --config path/to/custom.json5 features/*.feature
```

### Config Fields

```json5
{
  // World type name for codegen (e.g. "CalcWorld")
  "world": "CalcWorld",

  // Codegen mode: "per-scenario" (default) or "per-feature"
  "mode": "per-scenario",

  // Skip tags: Gherkin tags that cause scenarios to be skipped
  // Default: ["@skip", "@ignore"] (handled by RunOptions at runtime)
  "skip_tags": ["@skip", "@ignore", "@wip"],

  // Steps codegen configuration for `moonspec gen steps`
  "steps": {
    "output": "generated",
    "exclude": ["lib/*", "vendor/*"]
  }
}
```

#### `world` (string)

The World type name used during code generation. This is the struct that holds scenario state and is passed to every step handler.

Required for `moonspec gen tests`. Can be set here or via the `--world` CLI flag.

#### `mode` (string | object)

Controls how test functions are generated from Gherkin features. Two values are supported:

- **`"per-scenario"`** (default) -- generates one `test` block per scenario. Each scenario runs independently with its own World instance.
- **`"per-feature"`** -- generates one `test` block per feature file. All scenarios in the feature share a single test entry point.

The `mode` field also accepts a per-file map for mixed-mode projects:

```json5
{
  "mode": {
    "features/checkout.feature": "per-feature",
    "features/search.feature": "per-scenario",
    "*": "per-scenario"  // fallback for all other files
  }
}
```

The `"*"` key acts as a fallback. If a feature file path is not listed and no `"*"` key exists, the default `"per-scenario"` mode is used.

#### `skip_tags` (array of strings)

Gherkin tags that cause scenarios to be skipped during execution. Scenarios tagged with any of these tags are skipped without executing steps or hooks.

Tags may include a reason using the `@skip("reason")` syntax. The reason is extracted and attached to the skip status in results.

When omitted from config, the runtime default is `["@skip", "@ignore"]`.

#### `steps` (object)

Configuration for the `moonspec gen steps` command.

| Field     | Type            | Default       | Description                                           |
|-----------|-----------------|---------------|-------------------------------------------------------|
| `output`  | string          | `"generated"` | Output strategy for generated step registration files |
| `exclude` | array of string | (none)        | Glob patterns for files to exclude from scanning      |

The `output` field accepts:

- **`"generated"`** -- writes generated files to a `generated/` directory.
- **`"alongside"`** -- writes generated files next to the source files.
- **`"per-package"`** -- writes one file per MoonBit package.
- **Custom path** -- any other string is treated as a directory path.

### Example: Minimal Config

```json5
{
  "world": "CalcWorld"
}
```

### Example: Full Config

```json5
{
  "world": "EcomWorld",
  "mode": {
    "features/checkout.feature": "per-feature",
    "*": "per-scenario"
  },
  "skip_tags": ["@skip", "@ignore", "@wip"],
  "steps": {
    "output": "alongside",
    "exclude": ["vendor/*"]
  }
}
```

---

## RunOptions (Runtime Configuration)

`RunOptions` controls how the runner executes features at runtime. It is created in your test code and passed to the runner.

```moonbit
let opts = RunOptions::new(features)
opts.parallel(true)
opts.max_concurrent(8)
opts.retries(2)
opts.tag_expr("@smoke and not @slow")
opts.skip_tags(["@skip", "@ignore", "@wip"])
opts.dry_run(false)
```

### Builder Methods

#### `parallel(value : Bool)`

Enable or disable parallel scenario execution. Default: `false`.

When enabled, scenarios run concurrently up to the `max_concurrent` limit. Each scenario still gets its own World instance.

#### `max_concurrent(value : Int)`

Set the maximum number of scenarios that can run concurrently during parallel execution. Default: `4`.

Only takes effect when `parallel` is `true`.

#### `retries(value : Int)`

Set the global retry count for failed scenarios. Default: `0`.

When a scenario fails, it is re-executed up to `value` additional times. A fresh World instance is created for each attempt. Only the final attempt's result counts toward the run summary.

Per-scenario `@retry(N)` tags override this global setting. Negative values are clamped to `0`.

#### `tag_expr(value : String)`

Set a boolean tag expression to filter which scenarios run. Default: `""` (no filter).

Supports boolean operators:

```
"@smoke and not @slow"
"@checkout or @cart"
"not @wip"
```

#### `scenario_name(value : String)`

Filter scenarios by name. Default: `""` (no filter).

Only scenarios whose name contains the given string will run.

#### `dry_run(value : Bool)`

Enable or disable dry-run mode. Default: `false`.

When enabled, steps are matched against definitions but handlers are not executed. All hooks are skipped. Matched steps report as `Skipped("dry run")` and undefined steps remain `Undefined`. Useful for validating step wiring without side effects.

#### `skip_tags(tags : Array[String])`

Set the tags that cause scenarios to be skipped. Default: `["@skip", "@ignore"]`.

Replaces the entire skip tag list. Scenarios with any of these tags are skipped without executing steps or hooks.

#### `add_sink(sink : &MessageSink)`

Add a message sink for envelope output. Sinks receive structured messages as the run progresses. Multiple sinks can be added.

---

## CLI Flags

CLI flags override the corresponding config file fields for the current invocation.

### `moonspec gen tests`

| Flag              | Short | Overrides Config | Description                                   |
|-------------------|-------|------------------|-----------------------------------------------|
| `--world`         | `-w`  | `world`          | World type name (e.g. `CalcWorld`)            |
| `--mode`          | `-m`  | `mode`           | Codegen mode: `per-scenario` or `per-feature` |
| `--config`        | `-c`  | (all)            | Explicit config file path                     |
| `--output-dir`    | `-o`  | --               | Output directory for generated test files     |

When `--world` or `--mode` is provided, the CLI value takes precedence over the config file value. When `--config` is provided, auto-discovery is bypassed entirely and only the specified file is loaded.

Note: `--mode` on the CLI applies uniformly to all files in that invocation. To use per-file mode mapping, configure it in the config file instead.

### `moonspec gen steps`

| Flag              | Short | Description                            |
|-------------------|-------|----------------------------------------|
| `--config`        | `-c`  | Explicit config file path              |
| `--dir`           | `-d`  | Directory to scan for step definitions |

### `moonspec check`

The `check` subcommand accepts positional `.feature` file arguments and does not use config file settings.

---

## Precedence Order

Configuration values are resolved with the following precedence (highest wins):

1. **CLI flags** -- `--world`, `--mode`, etc.
2. **Override config** -- `moonspec.json5` (during auto-discovery)
3. **Base config** -- `moonspec.json` (during auto-discovery)
4. **Built-in defaults** -- `mode: "per-scenario"`, `skip_tags: ["@skip", "@ignore"]`, etc.

When `--config` is used, steps 2 and 3 are replaced by the single specified file.

---

## Merge Behavior

When both `moonspec.json` and `moonspec.json5` exist, they are merged using **field-level override** semantics:

- Each top-level field in the override config (`moonspec.json5`) **replaces** the corresponding field in the base config (`moonspec.json`) when present.
- Fields present in the base but absent from the override are **preserved**.
- Fields present in the override but absent from the base are **added**.
- For nested objects like `steps`, the entire object is replaced -- individual sub-fields are not merged independently.
- For array fields like `skip_tags`, the override array replaces the base array entirely (arrays are not concatenated).

### Example

**`moonspec.json`** (base):
```json5
{
  "world": "AppWorld",
  "mode": "per-scenario",
  "skip_tags": ["@skip", "@ignore"]
}
```

**`moonspec.json5`** (override):
```json5
{
  "mode": "per-feature",
  "skip_tags": ["@skip", "@ignore", "@wip"]
}
```

**Resolved config**:
```json5
{
  "world": "AppWorld",           // preserved from base
  "mode": "per-feature",         // replaced by override
  "skip_tags": ["@skip", "@ignore", "@wip"]  // replaced by override
}
```

---

## Schema

A JSON Schema is available at `schemas/moonspec.schema.yaml` in the moonspec repository. Use it for IDE validation and autocompletion in editors that support YAML/JSON schema references.

For VS Code, you can add a reference in your workspace settings:

```json
{
  "json.schemas": [
    {
      "fileMatch": ["moonspec.json", "moonspec.json5"],
      "url": "./schemas/moonspec.schema.yaml"
    }
  ]
}
```
