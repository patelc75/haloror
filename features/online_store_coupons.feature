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
    Then the "Coupon Code" field should contain "<replaced>"

    Examples:
      | coupon        | replaced |
      | coupon-code-1 | default  |
      | abc           | default  |
      | 12345         | default  |
      # | QUALITY-1.5.0-RC3 |

  # Sat Sep 18 01:46:00 IST 2010
  # CHANGED. coupon codes are now for groups
  #   For public user (not logged in) "direct_to_consumer" group applies
  #
  Scenario Outline: Order page - referral link for various coupon codes should show correct deposit, shipping, total, recurring, trial/advance
    When I visit "/order/<coupon_code>"
    And I choose "product_<product>"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    Then page content should have "<deposit>, <shipping>, <phrase>, <recurring>"

    Examples:
      | product  | coupon_code | group   | deposit | shipping | months | free | recurring | total | phrase           |
      | clip     | 99TRIAL     | bestbuy | 99      | 15       | 0      | 1    | 49        | 114   | 1 month trial    |
      | complete | 99TRIAL     | bestbuy | 99      | 15       | 0      | 1    | 59        | 114   | 1 month trial    |
      # | complete | BOGUS_CODE  | bestbuy | 249     | 15       | 3      | 0    | 59        | 441   | 3 months advance |
      # | clip     | BOGUS_CODE  | bestbuy | 249     | 15       | 3      | 0    | 49        | 411   | 3 months advance |
      #
      # Wed Oct  6 21:23:47 IST 2010
      # TODO: 1.6.0: This is possible one case with data specific issue. Might be just cucumber.
      #   Pushed for now to quality. Need more investigation
      # QUESTION: can QA please keep an eye on this scenario?

  Scenario Outline: Confirmation page - Filling in valid code shows correct deposit, trial period, total upfront
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I fill in "Coupon Code" with "<coupon>"
    And I press "Continue"
    Then page content should have "<values>"
    
    Examples:
      | coupon | values |
      #   * exact match of coupon_code, group and product
      | 99TRIAL | 99, 1 month trial |
      #   * product, coupon_code match. group does not have such code. snaps to match at 'default' group
      | SNAPBACK | 55 |
      #   * random coupon_code. snaps to 'default/default' coupon code
      | DUMMY | 249 |

  # # Wed Aug 25 03:16:11 IST 2010
  # # TODO: how should this scenario look now?
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

  # 
  #  Thu Nov 25 20:59:46 IST 2010, ramonrails
  #   * Error messages for coupon codes do not show at online store anymore
  # Scenario Outline: Confirmation page - Invalid or expired coupon code gives error message
  #   When I go to the online store
  #   And I choose "product_complete"
  #   And I fill the shipping details for online store
  #   And I fill the credit card details for online store
  #   And I check "order_bill_address_same"
  #   And I fill in "Coupon Code" with "<coupon_code>"
  #   And I press "Continue"
  #   Then page content should have "This coupon is <message>. Regular pricing is applied."
  #   
  #   Examples:
  #     | coupon_code | message |
  #     | ABC         | invalid |
  #     | EXPIRED     | expired |

  Scenario: Order items are created appropriately for selected product and coupon code
