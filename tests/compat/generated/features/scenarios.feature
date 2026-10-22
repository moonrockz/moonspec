Feature: Generated scenarios
  Background:
    Given a working fixture

  Scenario: Regular
    When the value is 1
    Then the value is positive

  Scenario Outline: Outline
    When the value is <value>
    Then the value is positive
    Examples:
      | value |
      | 2     |
      | 3     |

  @skip
  Scenario: Opt in
    When the value is 4
    Then the value is positive
