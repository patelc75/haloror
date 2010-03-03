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

  Scenario Outline: Success and Failure for credit cards
    When I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill in "<csc>" for "CSC"
    And I fill in "Card number" with "<card>"
    And I select "<type>" from "order_card_type"
    And I select "January" from "order_card_expiry_2i"
    And I select "2015" from "order_card_expiry_1i"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "<result>"
      
    Examples: pass and failed cards
      | card             | csc  | type             | result  |
      | 4222222222222    | 111  | VISA             | Failure |
      | 1234567812345678 | 111  | VISA             | Failure |
      | 4111111111111111 | 111  | VISA             | Success |
      | 4012888888881881 | 111  | VISA             | Success |
      | 4007000000027    | 111  | VISA             | Success |
      | 4012888818888    | 111  | VISA             | Success |
      | 370000000000002  | 1111 | American Express | Success |
      | 378282246310005  | 1111 | American Express | Success |
      | 371449635398431  | 1111 | American Express | Success |
      | 6011000000000012 | 111  | Discover         | Success |
      | 6011111111111117 | 111  | Discover         | Success |
      | 6011000990139424 | 111  | Discover         | Success |
      | 5424000000000015 | 111  | MasterCard       | Success |
      | 5555555555554444 | 111  | MasterCard       | Success |
      | 5105105105105100 | 111  | MasterCard       | Success |
      | 4222222222222    | 123  | VISA             | Failure |
      | 1234567812345678 | 123  | VISA             | Failure |
      | 4111111111111111 | 123  | VISA             | Success |
      | 4012888888881881 | 123  | VISA             | Success |
      | 4007000000027    | 123  | VISA             | Success |
      | 4012888818888    | 123  | VISA             | Success |
      | 370000000000002  | 1234 | American Express | Success |
      | 378282246310005  | 1234 | American Express | Success |
      | 371449635398431  | 1234 | American Express | Success |
      | 6011000000000012 | 123  | Discover         | Success |
      | 6011111111111117 | 123  | Discover         | Success |
      | 6011000990139424 | 123  | Discover         | Success |
      | 5424000000000015 | 123  | MasterCard       | Success |
      | 5555555555554444 | 123  | MasterCard       | Success |
      | 5105105105105100 | 123  | MasterCard       | Success |
