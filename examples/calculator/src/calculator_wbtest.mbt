///|
/// End-to-end test using the Runner API with inline feature content.
/// This demonstrates programmatic test execution with assertions.
async test "calculator: runner API" {
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
  let result = @moonspec.run(CalcWorld::default, [@moonspec.FeatureSource::Text(feature)])
  assert_eq(result.summary.total_scenarios, 4) // 2 regular + 2 outline rows
  assert_eq(result.summary.passed, 4)
  assert_eq(result.summary.failed, 0)
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
  let result = @moonspec.run(CalcWorld::default, [@moonspec.FeatureSource::Text(feature)], tag_expr="@slow")
  assert_eq(result.summary.total_scenarios, 1)
  assert_eq(result.summary.passed, 1)
}
