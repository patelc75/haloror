# https://redmine.corp.halomonitor.com/issues/2764
Feature: Online store coupons
  In order to get different product prices
  As a user
  I want the coupon codes working with online store

  Background:
    Given I am guest
    When I go to the online store
    # And the payment gateway response log is empty
    # And Email dispatch queue is empty

  Scenario: referral link fills coupon code on online store
    When I visit "/order/coupon-code-1"
    Then the "Coupon Code" field should contain "coupon-code-1"

  Scenario Outline: Valid coupon code places order with its prices
    Given the product catalog exists
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I fill in "Coupon Code" with "<coupon_code>"
    And I press "Continue"
    Then page content should have "<deposit>, <shipping>, <months> months, <advance>, <recurring>"
  
    Examples:
      | coupon_code | deposit | shipping | months | recurring | advance |
      |             | 249     | 15       | 3      | 59        | 177     |
      | A1          | 239     | 10       | 2      | 49        | 98      |
