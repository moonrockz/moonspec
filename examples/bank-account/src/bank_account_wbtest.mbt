///|
/// End-to-end test using the Runner API with inline feature content.
/// Demonstrates PerFeature codegen mode — single test for entire feature.
async test "bank account: all scenarios via run_or_fail" {
  let feature =
    #|Feature: Bank Account
    #|
    #|  Scenario: Deposit increases balance
    #|    Given a bank account with balance 100
    #|    When I deposit 50
    #|    Then the balance should be 150
    #|
    #|  Scenario: Withdrawal decreases balance
    #|    Given a bank account with balance 200
    #|    When I withdraw 75
    #|    Then the balance should be 125
    #|
    #|  Scenario: Insufficient funds
    #|    Given a bank account with balance 50
    #|    When I withdraw 100
    #|    Then the withdrawal should be declined
    #|    And the balance should be 50
  @moonspec.run_or_fail(BankWorld::default, [@moonspec.FeatureSource::Text("test://bank-account", feature)])
  |> ignore
}

///|
/// Verify per-scenario isolation: each scenario gets a fresh BankWorld.
async test "bank account: per-scenario isolation" {
  let feature =
    #|Feature: Isolation Check
    #|
    #|  Scenario: First scenario sets balance
    #|    Given a bank account with balance 999
    #|    When I deposit 1
    #|    Then the balance should be 1000
    #|
    #|  Scenario: Second scenario starts fresh
    #|    Given a bank account with balance 0
    #|    Then the balance should be 0
  @moonspec.run_or_fail(BankWorld::default, [@moonspec.FeatureSource::Text("test://isolation", feature)])
  |> ignore
}
