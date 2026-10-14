Feature: Todo List

  Scenario: Add a todo item
    Given a todo list
    When I add a todo "Buy groceries"
    Then I should have 1 todos

  Scenario: Complete a todo item
    Given a todo list
    When I add a todo "Write tests"
    And I complete todo "Write tests"
    Then todo "Write tests" should be completed

  Scenario: Remove a todo item
    Given a todo list
    When I add a todo "Read book"
    And I add a todo "Cook dinner"
    And I remove todo "Read book"
    Then I should have 1 todos

  Scenario: Count pending todos
    Given I have 2 completed and 3 pending todos
    Then the pending count should be 3

  Scenario: Start from a table of todos
    Given these todos
      | title     | done |
      | Shop      | yes  |
      | Cook      | no   |
      | Clean     | no   |
    Then the pending count should be 2

  Scenario: Name a todo after the scenario
    Given a todo list
    When I add a todo "Plan" for this scenario
    Then todo "Plan (Name a todo after the scenario)" should exist

  Scenario: Named list with todos
    Given a todo list named "Home"
      | title |
      | Shop  |
      | Cook  |
    Then I should have 2 todos
    And todo "Home: Cook" should exist

  Scenario: Named list without todos
    Given a todo list named "Work"
    Then I should have 0 todos
