# https://redmine.corp.halomonitor.com/issues/2764
Feature: Online store coupons
  In order to get different product prices
  As a user
  I want the coupon codes working with online store

  Background:
    Given I am guest
    And the product catalog exists

  Scenario: Order page - referral link fills coupon code text field
    When I visit "/order/coupon-code-1"
    Then the "Coupon Code" field should contain "coupon-code-1"

  Scenario Outline: Order page - referral link for various coupon codes should show correct deposit, shipping, total, recurring, trial/advance
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

  Scenario: Confirmation page - Filling in valid 99TRIAL shows correct deposit, trial period, total upfront
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "99TRIAL"
    And I press "Continue"
    Then page content should have "99, 1 month trial, 114"

  Scenario: Success page - Filling in 99TRIAL shows correct recurring start date
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "99TRIAL"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you, Success, Billing starts `1.month.from_now.to_s(:day_date)`"

  # Included Scenario: Subscription begins appropriately for regular and coupon purchases
  Scenario Outline: Success Page - Filling in various coupon codes shows recurring start date and upfront charge
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<coupon_code>"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you, Success, <upfront>, Billing starts <date>"
    
    Examples:
      | coupon_code | date                                | upfront |
      |             | `3.months.from_now.to_s(:day_date)` | 441     |
      | 99TRIAL     | `1.month.from_now.to_s(:day_date)`  | 114     |
  
  Scenario Outline: Confirmation page - Invalid or expired coupon code gives error message
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<coupon_code>"
    And I press "Continue"
    Then page content should have "This coupon is <message>. Regular pricing is applied."
    
    Examples:
      | coupon_code | message |
      | ABC         | invalid |
      | EXPIRED     | expired |
      
  Scenario: Order items are created appropriately for selected product and coupon code