Feature: Hooks and attachments
  Scenario: Attached
    Given attach evidence
    Then pass

  @retry(0)
  Scenario: Hook failure
    Given fail
    Then pass
