Feature: Admin role
  In order to value
  As a role
  I want feature

  Background:
    Given a user "admin-user" exists with profile
    And a user "caregiver-user" exists with profile
    And a user "senior-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And the following carriers:
      | name    |
      | verizon |
    And user "senior-user" has "halouser" roles for group "group1"
    And user "caregiver-user" has "caregiver" roles for user "senior-user"
    And user "admin-user" has "admin" roles for group "group1"
    And I am authenticated as "admin-user" with password "12345"
    
  Scenario: I can seniors with a link to their Caregivers
    When I follow "Config"
    Then page content should have "Config:, Users table"
    And I should see "Caregivers" link

  Scenario: I can see list of caregivers and link to Non-critical Events
    When I navigate to caregiver page for "senior-user" user
    Then I should see profile name for "senior-user"
    And I should see profile name for "caregiver-user"
    And I should see "Non-critical Alerts" link for caregiver "caregiver-user" of senior "senior-user"
  
  Scenario: I can see Non-critical Alerts for caregivers
    When I navigate to caregiver page for "senior-user" user
    And I follow "Non-critical Alerts"
    Then I should see "Non Critical Alert Type"

  Scenario: Admin of other group cannot see critical alerts of halousers in this group
    Given a user "other-admin" exists with profile
    And the following groups:
      | name   |
      | group1 |
      | group2 |
    And user "other-admin" has "admin" roles for group "group2"
    And I am authenticated as "other-admin" with password "12345"
    When I navigate to caregiver page for "senior-user" user
    Then I should not see profile name for "caregiver-user"
    
  Scenario: I can update Non-critical Alerts for caregivers
    Given I have some alerts available
    When I navigate to caregiver page for "senior-user" user
    And I follow "Non-critical Alerts"
    And I activate email on "non-critical-alert-1" for "senior-user" caregiven by "caregiver-user"
    And I navigate to caregiver page for "senior-user" user
    And I follow "Non-critical Alerts"
    Then I should see email active for "non-critical-alert-1"

  # shorthand: Given I am adding a new caregiver for "senior-user"
  Scenario: Admin can create new caregiver for a new halouser
    When I follow "Config"
    And I follow "Caregivers"
    And I follow "add_caregiver_button"
    And I follow "+ Add new caregiver with no email"
    Then I should not see "Please call tech support 1-888-971-HALO"
    
  Scenario: Add a new caregiver and check result
    Given I am adding a new caregiver for "senior-user"
    When I fill in the following:
      | Username         | halo1-cg1  |
      | Password         | halo1-cg1  |
      | Confirm Password | halo1-cg1  |
      | First Name       | halo1-cg1  |
      | Last Name        | halo1-cg1  |
      | Address          | halo1-cg1  |
      | Cross St         | halo1-cg1  |
      | City             | halo1-cg1  |
      | State            | halo1-cg1  |
      | Zipcode          | 11111      |
      | Home Phone       | 1234567890 |
      | Work Phone       | 1234567890 |
      | Cell Phone       | 1234567890 |
    And I select "verizon" from "profile_carrier_id"
    And I press "submit_caregiver"
    Then page content should have "halo1-cg1 halo1-cg1, Edit Profile"
    And I should see profile name of "senior-user"
