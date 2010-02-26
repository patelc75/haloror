# https://redmine.corp.halomonitor.com/issues/show/2558
#
Feature: Online (D)irect (T)o (C)ustomer store
  In order sell Halo products online to direct customer
  As an administrator
  I want to provide a public online store to direct customers

  Background:
    Given I am guest
    And the product catalog exists
    When I go to the online store

  Scenario: Direct to customer online store visible to public
    Then page content should have "myHalo Complete, myHalo Clip, Pick a product, Billing and Shipping"
  
  Scenario: Same as shipping copies shipping data to billing
    When I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "Thank you"

  Scenario: Not same as shipping has separate shipping and billing data
    When I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I uncheck "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Thank you"
    And profile "ship first name ship last name" should have "halouser" role
    And profile "bill first name bill last name" should have "subscriber" role for "ship first name ship last name"

  Scenario Outline: Passed and failed credit card, with log entry
    When I fill the shipping details
    And I fill the billing details
    And I fill in "111" for "CSC"
    And I fill in "Credit card" with "<card>"
    And I select "<type>" from the "order_card_type"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "<result>"
      
    Examples: pass and failed card
      | card             | result  | type             |
      | 4111111111111111 | Success | VISA             |
      | 4012888888881881 | Success | VISA             |
      | 1234567812345678 | Failure | VISA             |
      | 370000000000002  | Success | American Express |
      | 378282246310005  | Success | American Express |
      | 371449635398431  | Success | American Express |
      | 6011000000000012 | Success | Discover         |
      | 6011111111111117 | Success | Discover         |
      | 6011000990139424 | Success | Discover         |
      | 5424000000000015 | Success | MasterCard       |
      | 5555555555554444 | Success | MasterCard       |
      | 5105105105105100 | Success | MasterCard       |
      | 4222222222222    | Failure | VISA             |


  # # Scenario Outline covers multiple scenarios that have little variation
  # # Examples: is the keyword to define variations
  # #   keeps steps DRY
  # #
  # Scenario Outline: Confirmation view, back button
  #   When I fill the shipping details
  #   And I fill the billing details
  #   And I fill the credit card details
  #   And I press "Continue"
  #   And I press "<button>"
  #   Then I <action> edit the following:
  #     | ship_first_name |
  #     | ship_last_name  |
  #     | ship_address    |
  #     | ship_city       |
  #     | ship_zip        |
  #     | ship_phone      |
  #     | ship_email      |
  #     | Card number     |
  #     | CSC             |
  #     | Comments        |
  #     | bill_first_name |
  #     | bill_last_name  |
  #     | bill_address    |
  #     | bill_city       |
  #     | bill_zip        |
  #     | bill_phone      |
  #     | bill_email      |
  #   And I <action> select the following:
  #     | expiration_month |
  #     | expiration_year  |
  #     | card_type        |
  #   And page content should have "<content>"
  # 
  #   Examples: Edit, read only views
  #     | button | action | content                                                        |
  #     |        | cannot | Place Order, Back, Order Summary, Billing and Shipping Summary |
  #     | Back   | can    | Continue, Pick a product                                       |
