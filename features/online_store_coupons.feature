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

  Scenario Outline: Valid coupon code confirms order with coupon prices
    When I go to the online store
    And I choose "product_<product>"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<coupon_code>"
    And I press "Continue"
    Then page content should have "<deposit>, <shipping>, <months> months, <advance>, <recurring>"
  
    Examples:
      | product  | coupon_code | deposit | shipping | months | free | recurring | advance |
      | complete |             | 249     | 15       | 3      | 0    | 59        | 177     |
      | complete | 99TRIAL     | 249     | 15       | 0      | 1    | 49        | 0       |
      | clip     |             | 99      | 15       | 3      | 0    | 59        | 177     |
      | clip     | 99TRIAL     | 99      | 15       | 0      | 1    | 49        | 0       |

  Scenario: Visiting coupon code URL shows discounted products
    When I visit "/store/99TRIAL"
    Then page content should have "$99, $15, one free month, $59, $49, no advance charges"
    And I should not see "$249"