///|
/// Default feature file paths when no CLI arguments are given.
let default_features : Array[String] = [
  "features/cart.feature",
  "features/checkout.feature",
  "features/inventory.feature",
]

///|
/// CLI runner for the ecommerce example. Runs feature files through moonspec
/// with PrettyFormatter output and reports pass/fail via exit code.
async fn main {
  let args = @env.args()
  // Skip the program name (args[0])
  let paths : Array[String] = if args.length() > 1 {
    args[1:].to_owned()
  } else {
    default_features
  }
  // Build feature sources from file paths
  let features : Array[@moonspec.FeatureSource] = []
  for path in paths {
    features.push(@moonspec.FeatureSource::File(path))
  }
  // Run all features, printing results with PrettyFormatter
  let options = @moonspec.RunOptions(features)
  options.add_formatter(@format.PrettyFormatter::new(), @moonspec.OutputDest::Stdout)
  let result = @moonspec.run(EcomWorld::default, options)
  // Exit with non-zero code on failures or undefined steps
  if result.summary.failed > 0 || result.summary.undefined > 0 {
    @sys.exit(1)
  }
}
