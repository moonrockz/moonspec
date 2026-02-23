# Ecommerce CLI Example

Standalone CLI runner example showing how to embed the moonspec runner in your
own application binary and wire `PrettyFormatter` output manually.

## What This Example Shows

- **Standalone runner binary**: `async fn main` as the entry point instead of
  `async test` blocks
- **Manual formatter wiring**: Feeding a `RunResult` through `PrettyFormatter`
  to produce human-readable output
- **CLI argument handling**: Accepting feature file paths from command-line
  arguments with fallback defaults
- **Exit code semantics**: Exiting with code 1 when scenarios fail or steps are
  undefined

## Project Structure

```
ecommerce-cli/
├── moon.mod.json
├── features/
│   ├── cart.feature
│   ├── checkout.feature
│   └── inventory.feature
└── src/
    ├── world.mbt          # EcomWorld + World impl
    ├── cart_steps.mbt     # CartSteps: StepLibrary impl
    ├── checkout_steps.mbt # CheckoutSteps: StepLibrary impl
    ├── inventory_steps.mbt# InventorySteps: StepLibrary impl
    └── main.mbt           # CLI entry point
```

## How It Works

### Entry Point

The `main` function is `async` so it can call the async runner directly. It
reads file paths from `@env.args()`, skipping the program name at index 0, and
falls back to the three bundled feature files when no arguments are given:

```moonbit
async fn main {
  let args = @env.args()
  let paths : Array[String] = if args.length() > 1 {
    args[1:].to_array()
  } else {
    default_features
  }
  let features : Array[@moonspec.FeatureSource] = []
  for path in paths {
    features.push(@moonspec.FeatureSource::File(path))
  }
  let result = @moonspec.run(EcomWorld::default, features)
  println(format_result(result))
  if result.summary.failed > 0 || result.summary.undefined > 0 {
    @sys.exit(1)
  }
}
```

### Wiring PrettyFormatter

`PrettyFormatter` is a stateful formatter. You drive it by calling lifecycle
methods on each feature and scenario from the `RunResult`, then call
`on_run_finish` to append the summary line:

```moonbit
fn format_result(result : @moonspec.RunResult) -> String {
  let fmt = @format.PrettyFormatter::new()
  for feature in result.features {
    @format.Formatter::on_feature_start(fmt, feature.name)
    for scenario in feature.scenarios {
      @format.Formatter::on_scenario_finish(fmt, scenario)
    }
  }
  @format.Formatter::on_run_finish(fmt, result)
  fmt.output()
}
```

### Exit Code Semantics

The runner exits with code 1 if any scenario failed or if any steps were
undefined (no matching step definition). A clean run exits with code 0.

## Build and Run

Build the binary (JS or native targets support `async fn main`):

```bash
moon build --target js
```

Run with the bundled feature files (default):

```bash
moon run src --target js
```

Run with explicit feature file paths:

```bash
moon run src --target js -- features/cart.feature features/checkout.feature features/inventory.feature
```

The `--` separates `moon run` flags from the arguments passed to the program.
