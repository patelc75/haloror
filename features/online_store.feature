# https://redmine.corp.halomonitor.com/issues/show/2558
#
@L1 @store
Feature: Online (D)irect (T)o (C)ustomer store
  In order sell Halo products online to direct customer
  As an administrator
  I want to provide a public online store to direct customers

  Background:
    Given I am guest
    And the product catalog exists
    And there are no payment gateway responses
    And there are no emails
    When I go to the online store

  Scenario: Direct to customer online store visible to public
    Then page content should have "myHalo Complete, myHalo Clip, Pick a product, Billing and Shipping"
  
  # https://redmine.corp.halomonitor.com/issues/3170
  # Wed Aug 25 01:27:32 IST 2010 : Subscriptions are not charged anymore at the time of purchase
  @4291
  Scenario: Same as shipping copies shipping data to billing
    When I choose "product_complete"
    And I choose "S_22_28_inches"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"
    And the payment gateway response should have 1 log
    And 1 email to "cuc_ship@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery
    And product size for last order should be "S 22-28 inches"
    And product size for last user intake should be "S 22-28 inches"

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Not same as shipping has separate shipping and billing data
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Thank you"
    And the payment gateway response should have 1 log
    And billing and shipping addresses should not be same
    And last user intake should have separate senior and subscriber
    And subscriber of last user intake is also the caregiver
    And 1 email to "cuc_ship@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: Success and Failure for credit cards
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill in "<cvv>" for "CVV"
    And I fill in "Card number" with "<card>"
    And I select "<type>" from "order_card_type"
    And I select "January" from "order_card_expiry_2i"
    And I select "2015" from "order_card_expiry_1i"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "<result>"
    
    Examples: pass and failed cards
      | card             | cvv  | type             | result  |
      | 1234567812345678 | 111  | VISA             | Failure |
      | 4111111111111111 | 111  | VISA             | Success |
      | 4012888888881881 | 111  | VISA             | Success |
      | 4007000000027    | 111  | VISA             | Success |
      | 4012888818888    | 111  | VISA             | Success |
      | 370000000000002  | 1111 | American Express | Success |
      | 378282246310005  | 1111 | American Express | Success |
      | 371449635398431  | 1111 | American Express | Success |
      | 6011000000000012 | 111  | Discover         | Success |
      | 6011000990139424 | 111  | Discover         | Success |
      | 5424000000000015 | 111  | MasterCard       | Success |
      | 5555555555554444 | 111  | MasterCard       | Success |
      | 5105105105105100 | 111  | MasterCard       | Success |
      | 1234567812345678 | 123  | VISA             | Failure |
      | 4111111111111111 | 123  | VISA             | Success |
      | 4012888888881881 | 123  | VISA             | Success |
      | 4007000000027    | 123  | VISA             | Success |
      | 4012888818888    | 123  | VISA             | Success |
      | 370000000000002  | 1234 | American Express | Success |
      | 378282246310005  | 1234 | American Express | Success |
      | 371449635398431  | 1234 | American Express | Success |
      | 6011000000000012 | 123  | Discover         | Success |
      | 6011000990139424 | 123  | Discover         | Success |
      | 5424000000000015 | 123  | MasterCard       | Success |
      | 5555555555554444 | 123  | MasterCard       | Success |
      | 5105105105105100 | 123  | MasterCard       | Success |
      # | 4222222222222    | 111  | VISA             | Failure |
      # | 4222222222222    | 123  | VISA             | Failure |
      # | 6011111111111117 | 111  | Discover         | Success |
      # | 6011111111111117 | 123  | Discover         | Success |

  Scenario: Invalid card should log one payment gateway failure
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_card_number" with "1234567890123456"
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Failure"
    And the payment gateway response should have 1 logs
    And 1 email to "payment_gateway@halomonitoring.com" with subject "Credit Card transaction failed or declined" should be sent for delivery

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Valid card, invalid data should have 2 log entries
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_ship_first_name" with "123"
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"
    And the payment gateway response should have 1 log

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Upfront (one time) and recurring amounts
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"
    And the payment gateway should have log for 314 USD
    # And the payment gateway should have log for 59 USD

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Signup Installation and Order Summary emails delivery
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"
    # skipped for 1.6.0: And 1 email to "cuc_ship@chirag.name" with subject "Please read before your installation" should be sent for delivery
    And 1 email to "senior_signup@halomonitoring.com" with subject "Order Summary" should be sent for delivery

  Scenario: product selection and same_as_shipping remembred in session
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I follow "back_link"
    Then the "myHalo Complete" checkbox should be checked
    And the "Same as shipping info" checkbox should be checked

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: product selection remembered from "order again"
    When I choose "<selected>"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I fill in "order_card_number" with "4111111111111111"
    And I select "MasterCard" from "order_card_type"
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    And I follow "order_again"
    Then the "<recalled>" checkbox should be checked
    
    Examples:
      | selected         | recalled        |
      | product_complete | myHalo Complete |
      | product_clip     | myHalo Clip     |
      
    # To cause the payment gateway to respond with a specific response
    # code, send a transaction with the Visa error test credit card
    # number (x_card_num) 4222222222222 and an amount (x_amount) equal
    # to the response code you want the payment gateway to return.
    # 
    # For example, if a transaction is sent in Test Mode with the
    # credit card number 4222222222222 and an amount of 12 dollars,
    # the payment gateway will respond with response code 12,
    # "Authorization Code is required but is not present."
    #
    # this is not working with authorize.net as mentioned
    #
  Scenario: Duplicate order. Do not attempt recurring when one_time fails
    When I choose "product_complete"
    And I fill the test user for online store
    And I fill the credit card details for online store
    And I fill in "Card number" with "4222222222222"
    And I fill in "Coupon Code" with "DECLINED"
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    And I go to the online store
    And I choose "product_complete"
    And I fill the test user for online store
    And I fill the credit card details for online store
    And I fill in "Card number" with "4222222222222"
    And I fill in "Coupon Code" with "DECLINED"
    And I check "order_bill_address_same"
    And I erase the payment gateway response log
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Failure"
    And the payment gateway should have log for 53 USD
    And the payment gateway should not have log for 59 USD

  Scenario: Credit card is not charged at the time of online order
  
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Caregivers are already activated from online store
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then caregivers of last order should not be activated
    # https://spreadsheets.google.com/ccc?key=0Amq6Nxcn9fTPdHlkWFVNZnphZWxtdGtYQW0wczRtdFE&hl=en#gid=20

  Scenario: Coupon code values get copied into order
    Given I am an authenticated super admin
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I fill in "Coupon Code" with "reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    Then last order should have coupon code values copied
    
  Scenario Outline: Shipping options
    Given the following shipping_options:
      | description            | price |
      | UPS Overnight shipping | 60    |
      | UPS 2 day shipping     | 28    |
      | UPS Ground Shipping    | 16    |
    And "default" coupon_code for "direct_to_consumer" group has <_ship> shipping
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I choose "UPS 2 day shipping"
    And I press "Continue"
    Then page content should have "UPS 2 day shipping"
    When I press "Place Order"
    Then page content should have "Thank you for your order"
    And the payment gateway response should have 1 log
    And 1 email to "cuc_ship@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery
    And shipping values get copied from <_where> for last order
    
    Examples:
      | _ship | _where          |
      | 0     | shipping option |
      | 9     | coupon code     |

  Scenario: Separate order items for every charge
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you for your order"
    And order items for each charge should be created separately for last order
    And upfront charge for last order should include dealer install fee charges

  @now
  Scenario Outline: Apply coupon code without submitting the order
    When I choose "product_complete"
    And I choose "S_22_28_inches"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I fill in "Coupon Code" with "99TRIAL"
    And I press "<button>"
    Then I should see "<text>"
    And the "Coupon Code" field should contain "99TRIAL"
    
    Examples:
      | button   | text                     |
      | Apply    | Pick a product           |
      | Continue | Please verify your order |
