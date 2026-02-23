@checkout
Feature: Checkout

  @smoke
  Scenario: Checkout with items in the cart
    Given an empty shopping cart
    When I add "Laptop Stand" with quantity 1 at price 75
    And I add "Monitor Cable" with quantity 2 at price 15
    And I proceed to checkout
    Then the order total should be 105
    And the cart should be empty

  Scenario: Checkout with an empty cart
    Given an empty shopping cart
    When I proceed to checkout
    Then the checkout should be rejected
