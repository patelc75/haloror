Feature: Pre quality
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
    And only the following carriers:
      | name    |
      | Alltel  |
      | Verizon |
    
  Scenario: super admin > create a group
    When I am ready to create a "reseller" group
    And I press "Save"
    Then a group should exist with name "reseller_group"

  Scenario: super admin > create an admin
    When I create a "reseller" group
    And I am creating admin of "reseller" group
    And I press "subscribe"
    Then I should see "for activation of account"
    And email with activation code of last user should be sent for delivery
    And user "last" should have "admin" role for group "reseller_group"
    # count of emails is ignored here to accommodate within timeline of 1.6.0 release
    # we must check the count also, or, users may get multiple similar emails

  Scenario: Activate an admin
    When I create a "reseller" group
    And I create admin of "reseller" group
    And I logout
    And I am activating the last user as "reseller_admin"
    And I press "subscribe_button"
    Then last user should be activated
    And I should see "reseller_admin"
    
  Scenario: super admin > create an coupon code
    Given the product catalog exists
    When I create a "reseller" group
    And I am ready to create a coupon code for "reseller" group
    And I press "Save"
    Then a coupon code should exist with coupon_code "reseller_coupon"
    
  Scenario: admin > online store has single group
    Given the product catalog exists
    And a group "bogus" exists
    When I create a "reseller" group
    And I create admin of "reseller" group
    And I logout
    And I activate the last user as "reseller_admin"
    And I go to the online store
    Then I should see "reseller_group"
    And I should not see "bogus"

  Scenario: admin > coupon applies correctly
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing an online order for "re_reseller_group" group
    And I fill in "Coupon Code" with "reseller_coupon"
    And I press "Continue"
    Then I should see "$77"
    And I should see "2 months trial"

  Scenario: admin > place order
    Given the product catalog exists
    And the following groups:
      | name              | sales_type |
      | re_reseller_group | reseller   |
    When I create a coupon code for "re_reseller" group
    And I create admin of "re_reseller" group
    And I activate the last user as "re_reseller_admin"
    And I am placing an online order for "re_reseller_group" group
    And I fill in "Coupon Code" with "re_reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    Then 1 email to "cuc_senior@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery
    And 1 email to "cuc_subscriber@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery
    And 1 email to "senior_signup@halomonitoring.com" with subject "Order Summary" should be sent for delivery
    And 1 email to "re_master@halomonitoring.com" with subject "Order Summary" should be sent for delivery
    # smoke testing on sdev is at higher priority than this
    # will come back to this later

  Scenario: admin > add a new caregiver with no email
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I visit "/reporting/users/"
    And I follow links "Caregivers > add_caregiver_button > Add new caregiver with no email"
    And I fill in the following:
      | Username         | caregiver1    |
      | Password         | abc123        |
      | Confirm Password | abc123        |
      | First Name       | cg first name |
      | Last Name        | cg last name  |
      | Address          | chicago       |
      | Cross St         | chicago       |
      | City             | chicago       |
      | State            | IL            |
      | Zipcode          | 12345         |
      | Home Phone       | 1234567890    |
      | Work Phone       | 1234567890    |
    And I press "submit_caregiver"
    Then I should see "cg first name cg last name"

  Scenario: halouser > approve subscription agreement
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I logout
    And I activate the "reseller_senior" senior of last order
    And I check "userintake_agree"
    And I press "Agree"
    Then I should see "Successfully updated"

  Scenario: halouser > submit user intake form
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I am listing user intakes
    And I follow "edit_link"
    And I uncheck "user_intake_subscriber_is_user"
    And I check "user_intake_subscriber_is_caregiver"
    And I uncheck "user_intake_no_caregiver_2"
    And I fill the subscriber details for user intake form
    And I fill the caregiver2 details for user intake form
    And I select "Verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    Then I should see "successfully updated"
    # #
    # # email, text and phone checkboxes
    # # https://redmine.corp.halomonitor.com/issues/3674
    # And caregiver1 of last user intake should have email_active opted
    # And caregiver1 of last user intake should have text_active opted

  # 
  #  Fri Nov 12 00:20:54 IST 2010, ramonrails
  #  release 1.6.0 test cases from Intake + Install States spreadsheet
  #  http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=3
  Scenario: D2 - Enable test mode (opt out of call center + caregivers away)
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    Then senior of last user intake should be in test mode
    And senior of last user intake should be opted out of call center
    And caregivers of last user intake should be away
  
  # (1) Uncheck "Same as User" at the Online Store
  # (2) Verify both halouser and subsriber (and roles) in Config > Users
  # (3) Also, verify SQL - see note
  # (4) Verify call center account number is incremented and
  #     click envelope button and verify email is sent
  # (5) Verify Credit Card/Manual Billing radio button User Intake Form
  Scenario: H4 - Intake + Install States spreadsheet
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    And I uncheck "order_bill_address_same"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Success"
    And billing and shipping addresses should not be same
    And last user intake should have separate senior and subscriber
    And subscriber of last user intake is also the caregiver
    #
    # verify roles in config > users
    When I visit "/reporting/users?group_name=reseller_group"
    Then page content should have "subscriber for, caregiver for"
    #
    # verify call center account number
    Then last user intake should have latest call center account number
    #
    # safety care email
    When I send caregiver details for the last user intake
    Then 1 email to "safety care" should be sent for delivery
    #
    Then the last user intake should have credit card value
    #   * Cannot check javascript action
    # When I edit the last user intake
    # Then the "Card" checkbox should be checked
    # And the "Manual Billing" checkbox should not be checked
    When I logout
    And I activate the last subscriber as "reseller_subscriber"
    Then last subscriber should be activated
    And I should see "reseller_subscriber"
  
  # user intake sheet: H4
  # (3) Activate user, subscriber, and caregiver via email link
  Scenario: Activating admin, senior, subsriber and caregivers
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing an online order for "reseller" group
    And I fill in "Coupon Code" with "reseller_coupon"
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    When I edit the last user intake
    And I uncheck "user_intake_subscriber_is_caregiver"
    And I uncheck "user_intake_no_caregiver_1"
    And I uncheck "user_intake_no_caregiver_2"
    And I uncheck "user_intake_no_caregiver_3"
    And I fill the caregiver1 details for user intake form
    And I fill the caregiver2 details for user intake form
    And I fill the caregiver3 details for user intake form
    And I press "user_intake_submit"
    Then I should see "successfully updated"
    #
    # activate senior
    When I activate the last senior as "reseller_senior"
    Then last senior should be activated
    #
    # activate subscriber
    When I activate the last subscriber as "reseller_subscriber"
    Then last subscriber should be activated
    #
    # activate caregiver1
    When I activate the last caregiver1 as "reseller_caregiver1"
    Then last caregiver1 should be activated
    #
    # activate caregiver2
    When I activate the last caregiver2 as "reseller_caregiver2"
    Then last caregiver2 should be activated
    #
    # activate caregiver3
    When I activate the last caregiver3 as "reseller_caregiver3"
    Then last caregiver3 should be activated
    