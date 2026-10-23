@shared
Feature: One counter setup on every target
  Scenario: First isolated counter
    Given a fresh counter
    When I increment the counter
    Then the counter is one

  Scenario: Another isolated counter
    Given a fresh counter
    When I increment the counter
    Then the counter is one
