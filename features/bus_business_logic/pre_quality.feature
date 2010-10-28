Feature: Pre quality
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
    
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
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing online order
    And I select "reseller_group" from "Group"
    And I fill in "Coupon Code" with "reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    Then an email to "cuc_senior@chirag.name" with subject "activation" should be sent for delivery

  Scenario: admin > add a new caregiver with no email
    Given the product catalog exists
    When I create a "reseller" group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing online order
    And I select "reseller_group" from "Group"
    And I fill in "Coupon Code" with "reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    When I visit "/reporting/users/"
    And I follow links "Caregivers > add_caregiver_button > Add new caregiver with no email"
    And I fill in the following:
      | Username         | caregiver1 |
      | Password         | abc123     |
      | Confirm Password | abc123     |
      | First Name       | care_1     |
      | Last Name        | giver_1    |
      | Address          | chicago    |
      | Cross St         | chicago    |
      | City             | chicago    |
      | State            | IL         |
      | Zipcode          | 12345      |
      | Home Phone       | 1234567890 |
      | Work Phone       | 1234567890 |
    And I press "submit_caregiver"
    Then I should see "care_1 giver_1"

  Scenario: halouser > approve subscription agreement
    Given the following groups:
      | name           | sales_type | description                |
      | reseller_group | reseller   | reseller_group description |
    And a user "reseller_admin" exists with profile
    And user "reseller_admin" has "admin" role for group "reseller_group"
    And a user "myhalouser" exists with profile
    And user "myhalouser" has "halouser" role for group "reseller_group"
    And user intake for "myhalouser" exists
    And I am authenticated as "myhalouser" with password "12345"
    When I view the last user intake
    And I check "userintake_agree"
    And I press "Proceed"
    Then I should see "User Intake was successfully updated"

  Scenario: halouser > submit user intake form
