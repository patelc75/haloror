Feature: Online store user intake
  In order to value
  As a role
  I want feature

  Scenario: User Intake form does not accept Order ID input
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And I am on new user_intake page
    Then I should not see "Order ID"
  
  Scenario Outline: Successful order has associated user intake, Failed does not have it
    Given the following groups:
      | name   |
      | group1 |
      | group2 |
    And the product catalog exists
    And I am an authenticated user
    And user "demo" has "sales" role for group "group1"
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

  Scenario: myHalo user has role for group
    Given the following groups:
      | name   |
      | group1 |
      | group2 |
    And the product catalog exists
    And I am an authenticated user
    And user "demo" has "sales" role for group "group1"
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
    Then I should see "Success"
    And profile "user_first user_last" should have "halouser" role for group "group1"
    And profile "user_first user_last" should have "subscriber" role for profile "user_first user_last"
  
  Scenario: User reaches legal agreement page after successful credit card charge
  