Feature: Super Admin roles
  In order to value
  As a role
  I want feature
    
  Background:
    Given there are no users
    And a user "super-admin-user" exists with profile
    And a user "senior-user" exists with profile
    And a user "caregiver-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And the following carriers:
      | name    |
      | verizon |
    And user "super-admin-user" has "super_admin" roles
    And user "senior-user" has "halouser" roles for group "group1"
    And user "caregiver-user" has "caregiver" role for user "senior-user"
    And I am authenticated as "super-admin-user" with password "12345"
    
  Scenario: Create caregiver profile
    And I am adding a new caregiver for "senior-user"
    When I fill in the following:
      | Username         | cg1        |
      | Password         | cg1        |
      | Confirm Password | cg1        |
      | First Name       | cg1        |
      | Last Name        | cg1        |
      | Address          | cg1        |
      | Cross St         | cg1        |
      | City             | cg1        |
      | State            | cg1        |
      | Zipcode          | 11111      |
      | Home Phone       | 1234567890 |
      | Work Phone       | 1234567890 |
      | Cell Phone       | 1234567890 |
    And I select "verizon" from "profile_carrier_id"
    And I press "submit_caregiver"
    Then I should see "cg1 cg1"

  # TODO: 1.6.0 (Tue Oct  5 21:07:19 IST 2010)
  #   All UI errors skipped for now
  #
  # Scenario: Config > Users > Caregiver for
  #   When I follow links "Config > Users"
  #   Then I should see "caregiver for" link for user "caregiver-user"
  #   And I should see "Caregivers" link for user "senior-user"

  Scenario: Config > Users > Caregivers
    When I follow "Config"
    And I navigate to caregiver page for "senior-user" user
    Then I should see section header for caregivers of "senior-user"
    And I should see profile link for all caregivers of "senior-user"

  Scenario: Caregivers of caregiver
    When I navigate to caregiver page for "caregiver-user" user
    Then I should see section header for caregivers of "senior-user"
    And I should see profile link for all caregivers of "senior-user"

  # # FIXME: with the introduction of "group" drop down, this scenario requires AJAX runner like capybara
  # #   webrat is not capable of AJAX and "role" step will fail in this scenario
  # Scenario: Create admin user
  #   Given user "super-admin-user" has "admin" roles for group "group1"
  #   And I am creating admin user
  #   And debug
  #   When I select "group1" from "group"
  #   And I select "admin" from "role"
  #   And I fill in the following:
  #     | Email      | admin-test@example.com |
  #     | First Name | admin-first-name       |
  #     | Last Name  | admin-last-name        |
  #     | Address    | admin-address          |
  #     | City       | admin-city             |
  #     | State      | admin-state            |
  #     | Zipcode    | 12345                  |
  #     | Home Phone | 1234567890             |
  #   And I press "subscribe"
  #   Then I should see "Signup Complete!"
  #   And 1 email to "admin-test@example.com" with subject "Please activate your new myHalo account" should be sent for delivery
