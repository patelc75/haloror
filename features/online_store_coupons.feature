# https://redmine.corp.halomonitor.com/issues/2764
Feature: Online store coupons
  In order to get different product prices
  As a user
  I want the coupon codes working with online store

  Background:
    Given I am guest
    And the product catalog exists

  Scenario: referral link fills coupon code on online store
    When I visit "/order/coupon-code-1"
    Then the "Coupon Code" field should contain "coupon-code-1"

  Scenario Outline: Only a valid coupon code url shows coupon prices
    When I visit "/order/<coupon_code>"
    And I choose "product_<product>"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    Then page content should have "<deposit>, <shipping>, <phrase>, <total>, <recurring>"
  
    Examples:
      | product  | coupon_code | deposit | shipping | months | free | recurring | total | phrase           |
      | complete |             | 249     | 15       | 3      | 0    | 59        | 441   | 3 months advance |
      | complete | BOGUS_CODE  | 249     | 15       | 3      | 0    | 59        | 441   | 3 months advance |
      | complete | 99TRIAL     | 99      | 15       | 0      | 1    | 59        | 114   | 1 month trial    |
      | clip     |             | 249     | 15       | 3      | 0    | 49        | 411   | 3 months advance |
      | clip     | BOGUS_CODE  | 249     | 15       | 3      | 0    | 49        | 411   | 3 months advance |
      | clip     | 99TRIAL     | 99      | 15       | 0      | 1    | 49        | 114   | 1 month trial    |

  Scenario: Valid coupon code in regular order shows coupon prices for confirmation
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "99TRIAL"
    And I press "Continue"
    Then page content should have "99, 1 month trial, 114"

  Scenario: Successful 99TRIAL coupon code begins recurring charge after one month
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "99TRIAL"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you, Success"

  Scenario: Invalid coupon code gives validation alert
  Scenario: Credit card is charged subject to selected product and coupon code
  Scenario: Subscription begins appropriately for regular and coupon purchases
  Scenario: Order items are created appropriately for selected product and coupon code
