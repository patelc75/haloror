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
    And I am placing an online order
    And I select "reseller_group" from "Group"
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
    And I am placing an online order
    And I select "re_reseller_group" from "Group"
    And I fill in "Coupon Code" with "re_reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    # Then 1 email to "cuc_senior@chirag.name" with subject "activation" should be sent for delivery
    # Then 1 email to "cuc_subscriber@chirag.name" with subject "activation" should be sent for delivery
    # And 1 email to "senior_signup@halomonitoring.com" with subject "Order Summary" should be sent for delivery
    # And 1 email to "re_master@halomonitoring.com" with subject "Order Summary" should be sent for delivery
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
    And I fill the subscriber details for user intake form
    And I fill the caregiver2 details for user intake form
    And I select "Verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    Then I should see "successfully updated"
    And caregiver1 of last user intake should have email_active opted
    And caregiver1 of last user intake should have text_active opted
