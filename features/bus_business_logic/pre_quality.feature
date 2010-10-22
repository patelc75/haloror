Feature: Pre quality
  In order to value
  As a role
  I want feature

  Scenario: super admin > create a group
    Given I am an authenticated super admin
    When I am listing groups
    And I follow "New group"
    And I fill in the following:
      |Name| reseller_group |
      |Description | reseller_group|
      |Email | reseller_group@test.com |
    And I select "reseller" from "Sales Type"
    And I press "Save"
    Then a group should exist with name "reseller_group"

  # CHANGED: capybara was required to accomplish this
  #   this is now shifted to non-ajax implementation. no capybara required
  #
  # creating admin. consolidated step added to get ready to submit admin details
  Scenario: super admin > create an admin
    Given I am an authenticated super admin
    And I am ready to create an admin
    And I press "subscribe"
    Then I should see "for activation of account"
    And email with activation code of last user should be sent for delivery
    And user "last" should have "admin" role for group "reseller_group"
    # count of emails is ignored here to accommodate within timeline of 1.6.0 release
    # we must check the count also, or, users may get multiple similar emails

  Scenario: Activate an admin
    Given I am an authenticated super admin
    And I am ready to create an admin
    And I press "subscribe"
    And I logout
    And I am activating the last user
    And I fill in the following:
      | Username         | reseller_admin |
      | Password         | admin          |
      | Confirm Password | admin          |
    And I press "subscribe_button"
    Then last user should be activated
    And I should see "reseller_admin"
    
  # Pre-conditions: the following exist
  #   Group: reseller_group
  #   Admin: reseller_admin with profile, activated
  Scenario: super admin > create an coupon code
    Given I am an authenticated super admin
    And the following groups:
      | name           | sales_type | description                |
      | reseller_group | reseller   | reseller_group description |
    And a user "reseller_admin" exists with profile
    When I go to the home page
    And I follow links "Config > Coupon Codes > New coupon code"
    And I select the following:
      | Group                             | reseller_group            |
      | Device model                      | 12001002-1 -- Chest Strap |
      | device_model_price_expiry_date_1i | 2011                      |
    And I fill in the following:
      | Coupon code       | coupon_160_pq1 |
      | Deposit           | 66             |
      | Shipping          | 6              |
      | Monthly recurring | 77             |
      | Months advance    | 0              |
      | Months trial      | 2              |
    And I press "Save"
    Then a coupon code should exist with coupon_code "coupon_160_pq1"
    
  # smoke tested. we do not want to check trivial steps through cucumber
  Scenario: admin > online store has single group
  
  # Pre-conditions: the following exist
  #   Group:        reseller_group, reseller
  #     * online order will ask for kit serial after "Place Order"
  #     * subscriber sgreement will be presented after kit_serial number
  #   Admin:        reseller_admin with profile, activated
  #   Coupon code:  coupon_160_pq1
  #   current user = reseller_admin
  Scenario: admin > coupon applies correctly
    Given the following groups:
      | name           | sales_type | description                |
      | reseller_group | reseller   | reseller_group description |
    And a device_model_price exists with the following attributes:
      | coupon_code       | coupon_160_pq1    |
      | group_name        | reseller_group    |
      | device_model_type | complete          |
      | expiry_date       | `1.year.from_now` |
      | deposit           | 66                |
      | shipping          | 6                 |
      | monthly_recurring | 77                |
      | months_advance    | 0                 |
      | months_trial      | 2                 |
    And a user "reseller_admin" exists with profile
    And user "reseller_admin" has "admin" role for group "reseller_group"
    And I am authenticated as "reseller_admin" with password "12345"
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I select "reseller_group" from "Group"
    # And I uncheck "This person will be the myHalo user"
    And I uncheck "order_bill_address_same"
    And I fill in "Coupon Code" with "coupon_160_pq1"
    And I press "Continue"
    Then I should see "$72"
    And I should see "2 months trial"

  # Pre-conditions: the following exist
  #   Group:        reseller_group, reseller
  #     * online order will ask for kit serial after "Place Order"
  #     * subscriber sgreement will be presented after kit_serial number
  #   Admin:        reseller_admin with profile, activated
  #   Coupon code:  coupon_160_pq1
  #   current user = reseller_admin
  Scenario: admin > place order
    Given the following groups:
      | name           | sales_type | description                |
      | reseller_group | reseller   | reseller_group description |
    And a device_model_price exists with the following attributes:
      | coupon_code       | coupon_160_pq1    |
      | group_name        | reseller_group    |
      | device_model_type | complete          |
      | expiry_date       | `1.year.from_now` |
      | deposit           | 66                |
      | shipping          | 6                 |
      | monthly_recurring | 77                |
      | months_advance    | 0                 |
      | months_trial      | 2                 |
    And a user "reseller_admin" exists with profile
    And user "reseller_admin" has "admin" role for group "reseller_group"
    And I am authenticated as "reseller_admin" with password "12345"
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I select "reseller_group" from "Group"
    # And I uncheck "This person will be the myHalo user"
    And I uncheck "order_bill_address_same"
    And I fill in "Coupon Code" with "coupon_160_pq1"
    And I press "Continue"
    And I press "Place Order"
    Then an email to "cuc_senior@chirag.name" with subject "activation" should be sent for delivery

  Scenario: admin > add a new caregiver with no email
    Given the following groups:
      | name           | sales_type | description                |
      | reseller_group | reseller   | reseller_group description |
    And a user "reseller_admin" exists with profile
    And user "reseller_admin" has "admin" role for group "reseller_group"
    And a user "myhalouser" exists with profile
    And user "myhalouser" has "halouser" role for group "reseller_group"
    And I am authenticated as "reseller_admin" with password "12345"
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

  # TODO: smoke tested for now. cuke coverage later
  #
  # Scenario: halouser > approve subscription agreement
  #   Given the following groups:
  #     | name           | sales_type | description                |
  #     | reseller_group | reseller   | reseller_group description |
  #   And a user "reseller_admin" exists with profile
  #   And user "reseller_admin" has "admin" role for group "reseller_group"
  #   And a user "myhalouser" exists with profile
  #   And user "myhalouser" has "halouser" role for group "reseller_group"
  #   And user intake for "myhalouser" exists
  #   And I am authenticated as "myhalouser" with password "12345"
  #   When I view the last user intake
  #   And I check "userintake_agree"
  #   And I press "Proceed"
  #   Then I should see "User Intake was successfully updated"
    
  Scenario: halouser > submit user intake form
