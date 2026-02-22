Feature: Calculator

  Background:
    Given a calculator

  Scenario: Addition
    When I add 5 and 3
    Then the result should be 8

  Scenario: Subtraction
    When I subtract 3 from 10
    Then the result should be 7

  @slow
  Scenario Outline: Multiplication
    When I multiply <a> and <b>
    Then the result should be <result>

    Examples:
      | a  | b  | result |
      | 2  | 3  | 6      |
      | 10 | 5  | 50     |
