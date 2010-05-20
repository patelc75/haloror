Feature: Caregiver roles
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
    When I navigate to caregiver page for "caregiver-user" user
    Then I should see profile name for "caregiver-user"

  Scenario: I can see link to non-critical alerts
    When I navigate to caregiver page for "caregiver-user" user
    Then I should see "Non-critical Alerts" link for caregiver "caregiver-user" of senior "senior-user"

  Scenario: I can see list of Events for seniors whom I am caregiving
    When I visit the events page for "caregiver-user"
    Then page content should have "All Events, Heartrate, Skin Temp., Body Position"

  Scenario: See non-critical alerts
    When I navigate to caregiver page for "senior-user" user
    And I follow "Non-critical Alerts"
    Then I should see "Non Critical Alert Type"

  # Scenario: Update non-critical alerts
  #   When I navigate to caregiver page for "senior-user" user
  #   And I follow "Non-critical Alerts"
  #   And I follow ""

  Scenario: I am caregiver, not halouser. I login. I can see caregivers of senior
    When I navigate to caregiver page for "caregiver-user" user
    Then I should see section header for caregivers of "senior-user"
    And I should see profile link for all caregivers of "senior-user"

  Scenario: I am caregiver + halouser. I login. I can see my caregivers
    Given a user "caregiver-of-caregiver" exists with profile
    And user "caregiver-user" has "halouser" role for group "group1"
    And user "caregiver-of-caregiver" has "caregiver" role for user "caregiver-user"
    When I navigate to caregiver page for "caregiver-user" user
    Then I should see section header for caregivers of "caregiver-user"
    And I should see profile link for all caregivers of "caregiver-user"
