Feature: Admin role
  In order to value
  As a role
  I want feature

  Background:
    Given a user "admin-user" exists with profile
    And a user "other-admin" exists with profile
    And a user "caregiver-user" exists with profile
    And a user "senior-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
      | group2 |
    And user "senior-user" has "halouser" roles for group "group1"
    And user "caregiver-user" has "caregiver" roles for user "senior-user"
    And user "admin-user" has "admin" roles for group "group1"
    And user "other-admin" has "admin" roles for group "group2"
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
    Given I am authenticated as "other-admin" with password "12345"
    When I navigate to caregiver page for "senior-user" user
    Then I should not see profile name for "caregiver-user"
    
