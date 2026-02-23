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
