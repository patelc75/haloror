Feature: Online store group
  In order to value
  As a role
  I want feature

  Scenario: Guest will see all groups
    Given I am guest
    And the following groups:
      | name    |
      | group1 |
      | group2 |
    And the product catalog exists
    When I go to the online store
    Then the page content should have "group1, group2"

  Scenario: Authenticated user should only see assigned groups
    Given I am an authenticated user
    And the following groups:
      | name    |
      | group1 |
      | group2 |
    And user "demo" has "sales" role for group "group1"
    And the product catalog exists
    When I go to the online store
    Then I should see "group1"
    And I should not see "group2"
