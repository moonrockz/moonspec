///|
/// End-to-end test using the Runner API with inline feature content.
/// Demonstrates PerScenario codegen mode — one test per scenario.
async test "calculator: runner API with run_or_fail" {
  let feature =
    #|Feature: Calculator
    #|
    #|  Background:
    #|    Given a calculator
    #|
    #|  Scenario: Addition
    #|    When I add 5 and 3
    #|    Then the result should be 8
    #|
    #|  Scenario: Subtraction
    #|    When I subtract 3 from 10
    #|    Then the result should be 7
    #|
    #|  @slow
    #|  Scenario Outline: Multiplication
    #|    When I multiply <a> and <b>
    #|    Then the result should be <result>
    #|
    #|    Examples:
    #|      | a  | b  | result |
    #|      | 2  | 3  | 6      |
    #|      | 10 | 5  | 50     |
  @moonspec.run_or_fail(CalcWorld::default, @moonspec.RunOptions::new([@moonspec.FeatureSource::Text("test://calculator", feature)]))
}

///|
/// Tag filtering: run only scenarios tagged @slow.
async test "calculator: tag filtering" {
  let feature =
    #|Feature: Calculator
    #|
    #|  Background:
    #|    Given a calculator
    #|
    #|  Scenario: Addition
    #|    When I add 5 and 3
    #|    Then the result should be 8
    #|
    #|  @slow
    #|  Scenario: Slow addition
    #|    When I add 1 and 2
    #|    Then the result should be 3
  let options = @moonspec.RunOptions::new([@moonspec.FeatureSource::Text("test://tag-filter", feature)])
  options.tag_expr("@slow")
  let result = @moonspec.run(CalcWorld::default, options)
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
