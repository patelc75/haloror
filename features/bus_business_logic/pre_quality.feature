Feature: Pre quality
  In order to value
  As a role
  I want feature

  Scenario: super admin > create a group
    Given I am an authenticated super_admin
    When I go to the home page
    And I follow links "Config > Roles & Groups"
    And I fill in "mygroup" for "Group Name"
    And I select "reseller" from "Sales Type"
    And I fill in "mygroup description"
    Then debug

  Scenario: super admin > create an admin
  Scenario: super admin > create an coupon code
  Scenario: admin > online store has single group
  Scenario: admin > place an order
  Scenario: admin > assign login from email to halouser
  Scenario: admin > add a new caregiver with no email
  Scenario: halouser > approve subscription agreement
  Scenario: halouser > submit user intake form
