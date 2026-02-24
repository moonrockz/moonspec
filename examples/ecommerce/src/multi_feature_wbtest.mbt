///|
/// Run all three feature files together, proving multi-feature support.
async test "ecommerce: all features via run_or_fail" {
  @moonspec.run_or_fail(
    EcomWorld::default,
    @moonspec.RunOptions::new([
      @moonspec.FeatureSource::File("features/cart.feature"),
      @moonspec.FeatureSource::File("features/checkout.feature"),
      @moonspec.FeatureSource::File("features/inventory.feature"),
    ]),
  )
  |> ignore
}

///|
/// Cross-feature tag filtering: run only scenarios tagged @smoke.
/// Cart has 1, checkout has 1, inventory has 1 = 3 total @smoke scenarios.
async test "ecommerce: cross-feature @smoke tag filtering" {
  let options = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
    @moonspec.FeatureSource::File("features/inventory.feature"),
  ])
  options.tag_expr("@smoke")
  let result = @moonspec.run(EcomWorld::default, options)
  assert_eq(result.summary.total_scenarios, 3)
  assert_eq(result.summary.passed, 3)
}

///|
/// Tag exclusion: run all scenarios except those in the inventory feature.
/// Cart has 3, checkout has 2 = 5 scenarios when excluding @inventory.
async test "ecommerce: tag exclusion not @inventory" {
  let options = @moonspec.RunOptions::new([
    @moonspec.FeatureSource::File("features/cart.feature"),
    @moonspec.FeatureSource::File("features/checkout.feature"),
    @moonspec.FeatureSource::File("features/inventory.feature"),
  ])
  options.tag_expr("not @inventory")
  let result = @moonspec.run(EcomWorld::default, options)
  assert_eq(result.summary.total_scenarios, 5)
  assert_eq(result.summary.passed, 5)
}
