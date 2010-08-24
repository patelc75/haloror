# https://redmine.corp.halomonitor.com/issues/2764
Feature: Online store coupons
  In order to get different product prices
  As a user
  I want the coupon codes working with online store

  Background:
    Given I am guest
    And the product catalog exists

  Scenario Outline: Order page - referral link fills coupon code text field
    When I visit "/order/<coupon>"
    Then the "Coupon Code" field should contain "<coupon>"
    
    Examples:
      | coupon            |
      | coupon-code-1     |
      | abc               |
      | 12345             |
      # | QUALITY-1.5.0-RC3 |

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

  # # Wed Aug 25 03:16:11 IST 2010
  # # TODO: how should this cenario look now?
  # # https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Success page - Filling in 99TRIAL shows correct recurring start date
  #   When I go to the online store
  #   And I choose "product_complete"
  #   And I fill the shipping details for online store
  #   And I fill in "order_ship_first_name" with "my-first-name"
  #   And I fill the credit card details for online store
  #   And I check "Same as shipping"
  #   And I fill in "Coupon Code" with "99TRIAL"
  #   And I press "Continue"
  #   And I press "Place Order"
  #   And I follow "Skip for later"
  #   Then page content should have "Thank you, Success, Billing starts `1.month.from_now.to_s(:day_date)`"
  #   And subscription start date should be 0 and 1 months away for "my-first-name"
  #   # 0 = advance months, 1 = free trial months

  # # Wed Aug 25 03:21:27 IST 2010
  # # WARNING: deprecated feature.
  # #
  # # https://redmine.corp.halomonitor.com/issues/3170
  # # # Included Scenario: Subscription begins appropriately for regular and coupon purchases
  # # # advance and free trial logic
  # # #   <advance> and <free> months will add the values together
  # # #   business logic assumes both values cannot be given at the same time. one of them must be zero.
  # Scenario Outline: Success Page - Filling in various coupon codes shows recurring start date and upfront charge
  #   When I go to the online store
  #   And I choose "product_complete"
  #   And I fill the shipping details for online store
  #   And I fill in "order_ship_first_name" with "my-first-name"
  #   And I fill the credit card details for online store
  #   And I check "Same as shipping"
  #   And I fill in "Coupon Code" with "<coupon_code>"
  #   And I press "Continue"
  #   And I press "Place Order"
  #   And I follow "Skip for later"
  #   Then page content should have "Thank you, Success, <upfront>, Billing starts <date>"
  #   And subscription start date should be <advance> and <free> months away for "my-first-name"
  #   
  #   Examples:
  #     | coupon_code | date                                | upfront | free | advance |
  #     | 99TRIAL     | `1.month.from_now.to_s(:day_date)`  | 114     | 1    | 0       |
  #     |             | `3.months.from_now.to_s(:day_date)` | 441     | 0    | 3       |
  
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
