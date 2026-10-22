Feature: Portable calculator

  Background:
    Given a calculator

  Scenario: Addition
    When I add 2 and 3
    Then the result should be 5

  Scenario Outline: More additions
    When I add <left> and <right>
    Then the result should be <sum>

    Examples:
      | left | right | sum |
      | 1    | 2     | 3   |
      | 5    | 8     | 13  |
