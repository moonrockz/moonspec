@cart
Feature: Shopping Cart

  Scenario: Add a single item to the cart
    Given an empty shopping cart
    When I add "Wireless Mouse" with quantity 1 at price 25
    Then the cart should contain 1 item
    And the cart total should be 25

  @smoke
  Scenario: Add multiple items to the cart
    Given an empty shopping cart
    When I add "Wireless Mouse" with quantity 1 at price 25
    And I add "USB Keyboard" with quantity 2 at price 45
    Then the cart should contain 2 items
    And the cart total should be 115

  Scenario: Remove an item from the cart
    Given an empty shopping cart
    When I add "Wireless Mouse" with quantity 1 at price 25
    And I add "USB Keyboard" with quantity 1 at price 45
    And I remove "Wireless Mouse" from the cart
    Then the cart should contain 1 item
    And the cart total should be 45
