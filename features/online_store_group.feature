Feature: Online store group
  In order to value
  As a role
  I want feature

  Background:
    Given the following groups:
      | name   |
      | group1 |
      | group2 |
    And the product catalog exists
    
  Scenario: Guest will not see any groups
    Given I am guest
    When I go to the online store
    Then the page content should not have "group1, group2"

  Scenario: Authenticated user should only see assigned groups
    Given I am an authenticated user
    And user "demo" has "sales" role for group "group1"
    When I go to the online store
    Then I should see "group1"
    And I should not see "group2"

  Scenario: Order has an associated group when completed by authenticated user
    Given I am an authenticated user
    And user "demo" has "sales" role for group "group1"
    When I go to the online store
    And I select "group1" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"
    And last order should be associated to "group1" group
