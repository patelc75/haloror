Feature: Online store group coupons
  In order to value
  As a role
  I want feature

  Background:
    Given the product catalog exists
    
  Scenario: If user is not logged in, then pick the direct_to_consumer "default" coupon code
    When I go to the online store
    Then I should see "Direct to consumer"

  Scenario Outline: A public user can only redeem coupons available to DTC group
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<code>"
    And I press "Continue"
    Then I should see "Please verify your order"
    And page source should have xpath "//input[@value='<code>']"

    Examples:
      | code               |
      | 99TRIAL            |
      | DIRECT_TO_CONSUMER |

  # This scenario is included in the following
  # Scenario: Incorrect coupon codes will apply default applicable coupon codes
  Scenario Outline: A public user cannot redeem random coupons
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<code>"
    And I press "Continue"
    Then page content should have "This coupon is invalid. Regular pricing is applied."
    
    Examples:
      | code    |
      | BESTBUY |
      | OFF99   |
      
  Scenario: A logged in user (market link, bestbuy, ...) CAN redeem coupons available in their group
    Given I am an authenticated user
    And user "demo" has "admin" role for group "bestbuy"
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "BESTBUY"
    And I press "Continue"
    Then I should see "Please verify your order"
    And page source should have xpath "//input[@value='BESTBUY']"

  # TODO: not fully working yet. Needs a fix.
  Scenario: A logged in user (market link, bestbuy, ...) CAN NOT redeem coupons of OTHER groups
    Given I am an authenticated user
    And user "demo" has "admin" role for group "bestbuy"
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "DIRECT_TO_CONSUMER"
    And I press "Continue"
    Then page content should have "This coupon is invalid. Regular pricing is applied."
  