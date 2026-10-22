Feature: Failure outcomes
  @retry(0)
  Scenario: Failed
    Given fail
    Then pass

  Scenario: Undefined
    Given missing definition
    Then pass

  Scenario: Pending
    Given pending
    Then pass

  @skip
  Scenario: Skipped
    Given fail
