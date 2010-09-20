Feature: Pre quality
  In order to value
  As a role
  I want feature

  Scenario: super admin > create a group
    Given I am an authenticated super_admin
    When I go to the home page
    And I follow links "Config > Roles & Groups"
    And I fill in "mygroup_160_pq" for "Group Name"
    And I select "reseller" from "Sales Type"
    And I fill in "mygroup_160_pq description" for "Description"
    And I press "Add Group"
    Then a group should exist with name "mygroup_160_pq"

  # TODO: capybara required to accomplish this
  #
  # creating user and activating
  Scenario: super admin > create an admin
    # Given I am an authenticated super_admin
    # And the following groups:
    #   | name           | sales_type | description                |
    #   | mygroup_160_pq | reseller   | mygroup_160_pq description |
    # When I go to the home page
    # And I follow links "User Signup"
      
  # Pre-conditions: the following exist
  #   Group: mygroup_160_pq
  #   Admin: admin_160_pq1 with profile, activated
  Scenario: super admin > create an coupon code
    Given I am an authenticated super_admin
    And the following groups:
      | name           | sales_type | description                |
      | mygroup_160_pq | reseller   | mygroup_160_pq description |
    And a user "admin_160_pq1" exists with profile
    When I go to the home page
    And I follow links "Config > Coupon Codes > New coupon code"
    And I select the following:
      | Group                             | mygroup_160_pq            |
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
    
  # smoke tested for now
  Scenario: admin > online store has single group

  # Pre-conditions: the following exist
  #   Group:        mygroup_160_pq, reseller
  #     * online order will ask for kit serial after "Place Order"
  #     * subscriber sgreement will be presented after kit_serial number
  #   Admin:        admin_160_pq1 with profile, activated
  #   Coupon code:  coupon_160_pq1
  #   current user = admin_160_pq1
  Scenario: admin > place an order
    Given the following groups:
      | name           | sales_type | description                |
      | mygroup_160_pq | reseller   | mygroup_160_pq description |
    And a device_model_price exists with the following attributes:
      | coupon_code       | coupon_160_pq1    |
      | group_name        | mygroup_160_pq    |
      | device_model_type | complete          |
      | expiry_date       | `1.year.from_now` |
      | deposit           | 66                |
      | shipping          | 6                 |
      | monthly_recurring | 77                |
      | months_advance    | 0                 |
      | months_trial      | 2                 |
    And a user "admin_160_pq1" exists with profile
    And user "admin_160_pq1" has "admin" role for group "mygroup_160_pq"
    And I am authenticated as "admin_160_pq1" with password "12345"
    When I go to the online store
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I select "mygroup_160_pq" from "Group"
    And I uncheck "This person will be the myHalo user"
    And I uncheck "Same as shipping info"
    And I fill in "Coupon Code" with "coupon_160_pq1"
    And I press "Continue"
    Then I should see "$72"
    And I should see "2 months trial"

  Scenario: admin > assign login from email to halouser
  Scenario: admin > add a new caregiver with no email
  Scenario: halouser > approve subscription agreement
  Scenario: halouser > submit user intake form
