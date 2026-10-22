Feature: Retry and World isolation
  @retry(1)
  Scenario: Tag retry
    Given fail once in a fresh world

  Scenario: Global retry
    Given fail once in a fresh world

  @retry(1)
  Scenario: Exhausted
    Given fail

  Scenario: Mutate world
    Given counter is 0
    When counter becomes 42
    Then counter is 42

  Scenario: Fresh world
    Then counter is 0
