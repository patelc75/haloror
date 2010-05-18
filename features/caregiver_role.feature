Feature: Caregiver role
  In order to value
  As a role
  I want feature

  Background:
    Given a user "caregiver-user" exists with profile
    And a user "senior-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And user "senior-user" has "halouser" roles for group "group1"
    And user "caregiver-user" has "caregiver" role for user "senior-user"
    And I am authenticated as "caregiver-user" with password "12345"
    
  Scenario: I can see list of caregivers and link to their profile
    When I see list of caregivers for "caregiver-user"
    Then I should see profile name for "caregiver-user"

  Scenario: I can see link to non-critical alerts
    When I see list of caregivers for "caregiver-user"
    Then I should see "Non-critical Alerts" link for caregiver "caregiver-user" of senior "senior-user"
