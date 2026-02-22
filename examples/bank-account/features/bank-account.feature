Feature: Bank Account

  Scenario: Deposit increases balance
    Given a bank account with balance 100
    When I deposit 50
    Then the balance should be 150

  Scenario: Withdrawal decreases balance
    Given a bank account with balance 200
    When I withdraw 75
    Then the balance should be 125

  Scenario: Insufficient funds
    Given a bank account with balance 50
    When I withdraw 100
    Then the withdrawal should be declined
    And the balance should be 50
