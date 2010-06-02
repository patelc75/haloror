Feature: Manage triage
  In order to value
  As a role
  I want feature

  Background:
    Given a user "group1-admin" exists with profile
    And the following groups:
      | name   |
      | group1 |
      | group2 |
    And user "group1-admin" has "admin" role for groups "group1, group2"
    And I am authenticated as "group1-admin" with password "12345"
    And user "senior1, senior2" exists with profile
    And user "senior1" has "halouser" role for group "group1"
    And user "senior2" has "halouser" role for group "group2"
    When I visit "/triage"

  Scenario: Group drop down on triage page
    Then page content should have "group1, group2"
    And page content should have "Events, Residents, Name, Alerts, Chart, Battery, Connectivity"

  Scenario: Seniors listed for that group only
    And I should see profile name of "senior1"
    And I should not see profile name of "senior2"

  Scenario: Dismiss interface
    When I follow "Dismiss"
    Then I should see "Dismiss Triage"
    And I should see profile name of "senior1"

  Scenario: Dismiss should remove the user from triage
    When I follow "Dismiss"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    Then page content should have "Events, Residents"
    And I should not see profile name of "senior1"

  Scenario: Selecting filter dropdowns shortlists the users in triage
    When I visit triage for user "group1-admin" showing group "group2"
    Then I should not see profile name of "senior1"
    And I should see profile name of "senior2"
  
  Scenario: View list of users dismissed from triage
    When I follow "Dismiss"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit the triage for user "group1-admin" showing dismissed users for group "group1"
    Then I should see profile name of "senior1"

  Scenario: Dismissed users appear again in triage next day or later
    Given user "senior1" was dismissed yesterday
    When I visit "/triage"
    Then I should see profile name of "senior1"

  Scenario: Recall / Un-dismiss users back to triage
    When I follow "Dismiss"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit the triage for user "group1-admin" showing dismissed users for group "group1"
    And I follow "Recall"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit "/triage"
    Then I should see profile name of "senior1"
    
  Scenario: Dismiss All Greens
    When I follow "Dismiss All Greens"
    Then I should not see any green battery

  Scenario: Correct battey fill and color
  Scenario: Correct connectivity status icon
  Scenario: Correct Alert icon
  
  Scenario: Order by Name
  Scenario: Order by Alert
  Scenario: Order by Battery
  Scenario: Order by Last Updated
  Scenario: Order by Special Status
