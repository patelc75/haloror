Feature: Online store user intake
  In order to value
  As a role
  I want feature

  Background:
    Given the following groups:
      | name   |
      | group1 |
      | group2 |
    And the product catalog exists
    And a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "sales" role for group "group1"
    
  Scenario: User Intake form does not accept Order ID input
    And I am on new user_intake page
    Then I should not see "Order ID"
  
  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: Successful order has associated user intake, Failed does not have it
    When I go to the online store
    And I select "group1" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "Card number" with "<card>"
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "<status>"
    And last order should <presence> associated user intake
  
    Examples:
      | card             | presence | status  |
      | 4111111111111111 | have     | Success |
      | 1234567812345678 | not have | Failure |

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: myHalo user has role for group
    When I go to the online store
    And I select "group1" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_ship_first_name" with "user_first"
    And I fill in "order_ship_last_name" with "user_last"
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then profile "user_first user_last" should have "halouser" role for group "group1"
    And profile "user_first user_last" should have "subscriber" role for profile "user_first user_last"
  
  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: User reaches legal agreement page after successful credit card charge
    Given I logout
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_ship_first_name" with "user_first"
    And I fill in "order_ship_last_name" with "user_last"
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "HALO SUBSCRIBER AGREEMENT"

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Skip Subscriber Agreement after a successful order to reach success page
    Given I logout
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_ship_first_name" with "user_first"
    And I fill in "order_ship_last_name" with "user_last"
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    And I follow "Skip for later"
    Then I should see "Success"
    