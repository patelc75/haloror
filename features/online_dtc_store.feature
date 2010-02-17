# https://redmine.corp.halomonitor.com/issues/show/2558
#
Feature: Online (D)irect (T)o (C)ustomer store
  In order sell Halo products online to direct customer
  As an administrator
  I want to provide a public online store to direct customers

  Background:
    Given I am guest
    When I go to the online store

  Scenario: Direct to customer online store visible to public
    Then page content should have "myHalo Complete, myHalo Clip, Pick a product, Billing and Shipping"
  
    Scenario: Same as shipping copies shipping data to billing
      When I fill the shipping details
      And I fill the credit card details
      And I check "Same as shipping"
      And I press "Continue"
      And I press "Place Order"
      Then page content should have "Thank you"
      And profile "shipping f name shipping l name" should have "halouser" role
      And profile "shipping f name shipping l name" should have "subscriber" role for "shipping f name shipping l name"

  # Scenario: Choice for HaloComplete
  #   When I choose "myHalo Complete"
  #   Then page has the following content visible:
  #     """
  #     $439.00
  #     Recurring monthly charge of $59.00/mo
  #     """

  # Scenario: Choice for HaloClip
  #   When I choose "myHalo Clip"
  #   Then page has the following content visible:
  #     """
  #     $409.00
  #     Recurring monthly charge of $49.00/mo
  #     """

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

  # Scenario: Not same as shipping has separate shipping and billing data
  #   When I fill the shipping details
  #   And I fill the billing details
  #   And I fill the credit card details
  #   And I uncheck "Same as shipping"
  #   And I press "Continue"
  #   And I press "Place Order"
  #   Then I should see "Thank you"
  #   And profile "shipping f name shipping l name" should have "halouser" role
  #   And profile "ship f name ship l name" should have "subscriber" role for "shipping f name shipping l name"

  # Scenario: One time and subscription charges
  #   When I fill the shipping details
  #   And I fill the billing details
  #   And I fill the credit card details
  #   And I press "Continue"
  #   And I press "Place Order"
  #   Then I should see either of the following:
  #     """
  #     Thank you for placing the order with us
  #     You order has failed for the following reason
  #     """

  # Scenario Outline: Passed and failed credit card, with log entry
  #   When I fill the shipping details
  #   And I fill the billing details
  #   And I fill in "123" for "CSC"
  #   And I fill in "Credit card" with "<card>"
  #   And I press "Continue"
  #   And I press "Place Order"
  #   Then I should see "<result>"
  #     
  #   Examples: pass and failed card
  #     | card             | result  |
  #     | 4111111111111111 | Success |
  #     | 1234567812345678 | Failure |


  # sample data to fill for myhalo user. similar for billing details
  #   for billing: ship/shipp becomes bill
  #
  # When I fill in the following:
  # | ship_first_name | shipping f name  |
  # | ship_last_name  | shipping l name  |
  # | ship_address    | shipping address |
  # | ship_city       | shipping city    |
  # | ship_zip        | shipping zip     |
  # | ship_phone      | shipping phone   |
  # | ship_email      | shipping email   |
  # | Card number     | 4111111111111111 |
  # | CSC             | 123              |
  # | Comments        | Some comments    |
  # And I uncheck "Same as shipping"
  # And I select "Alabama" from the "ship_state"
  # And I select "Iowa" from the "bill_state"
  # And I choose "myHalo Complete"
