///|
/// Default feature file paths when no CLI arguments are given.
let default_features : Array[String] = [
  "features/cart.feature",
  "features/checkout.feature",
  "features/inventory.feature",
]

///|
/// Feed a run result into a PrettyFormatter and return the formatted output.
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

///|
/// CLI runner for the ecommerce example. Runs feature files through moonspec
/// with PrettyFormatter output and reports pass/fail via exit code.
async fn main {
  let args = @env.args()
  // Skip the program name (args[0])
  let paths : Array[String] = if args.length() > 1 {
    args[1:].to_array()
  } else {
    default_features
  }
  // Build feature sources from file paths
  let features : Array[@moonspec.FeatureSource] = []
  for path in paths {
    features.push(@moonspec.FeatureSource::File(path))
  }
  // Run all features
  let result = @moonspec.run(EcomWorld::default, @moonspec.RunOptions::new(features))
  // Format and print output
  println(format_result(result))
  // Exit with non-zero code on failures or undefined steps
  if result.summary.failed > 0 || result.summary.undefined > 0 {
    @sys.exit(1)
  }
}
