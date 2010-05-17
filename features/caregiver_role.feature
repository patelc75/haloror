Feature: Caregiver role
  In order to value
  As a role
  I want feature

  Scenario: When logged in as caregiver, see list of caregivers
    Given a user "caregiver-user" exists with profile
    And a user "senior-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And user "senior-user" has "halouser" roles for group "group1"
    And user "caregiver-user" has "caregiver" role for user "senior-user"
    And I am authenticated as "caregiver-user" with password "12345"
    When I see list of caregivers for "caregiver-user"
    Then I should see profile name for "caregiver-user"
