Feature: Filtering and outlines
  Background:
    Given counter is 0

  @keep
  Scenario: Selected
    Given pass

  @drop
  Scenario: Excluded
    Given fail

  @keep @skip
  Scenario: Skip selected
    Given fail

  @keep
  Scenario Outline: Row
    When counter becomes <n>
    Then counter is <n>
    Examples:
      | n |
      | 1 |
      | 2 |
