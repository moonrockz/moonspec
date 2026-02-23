@inventory
Feature: Inventory

  Scenario: Check stock availability
    Given the inventory has "Wireless Mouse" with stock 50
    When I check stock for "Wireless Mouse"
    Then the item should be in stock
    And the stock level should be 50

  @smoke
  Scenario: Stock decreases after purchase
    Given the inventory has "Wireless Mouse" with stock 50
    And an empty shopping cart
    When I add "Wireless Mouse" with quantity 3 at price 25
    And I proceed to checkout
    Then the stock level for "Wireless Mouse" should be 47
