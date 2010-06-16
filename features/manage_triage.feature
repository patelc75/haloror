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
    When I visit "group1-admin" pending triage for group "group1"

  Scenario: Group drop down on triage page
    Then page content should have "group1, group2"
    And page content should have "Events, Residents, Name, Alerts, Chart, Battery, Connectivity"

  Scenario: Seniors listed for that group only
    And I should see profile name of "senior1"
    And I should not see profile name of "senior2"

  Scenario: Dismiss interface
    When I dismiss "senior1"
    Then I should see "Dismiss Triage"
    And I should see profile name of "senior1"

  Scenario: Dismiss should remove the user from triage
    When I dismiss "senior1"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit "group1-admin" pending triage for group "group1"
    Then page content should have "Events, Residents"
    And I should not see profile name of "senior1"

  Scenario: Selecting filter dropdowns shortlists the users in triage
    When I visit triage for user "group1-admin" showing group "group2"
    Then I should not see profile name of "senior1"
    And I should see profile name of "senior2"
  
  Scenario: View list of users dismissed from triage
    When I dismiss "senior1"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit "group1-admin" dismissed triage for group "group1"
    Then I should see profile name of "senior1"

  Scenario: Dismissed users appear again in triage next day or later
    Given user "senior1" was dismissed yesterday
    When I visit "group1-admin" pending triage for group "group1"
    Then I should see profile name of "senior1"

  Scenario: Recall / Un-dismiss users back to triage
    When I dismiss "senior1"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit "group1-admin" dismissed triage for group "group1"
    And I recall "senior1"
    And I fill in "triage_audit_log_description" with "testing the dismissal"
    And I press "Ok"
    And I visit "group1-admin" pending triage for group "group1"
    Then I should see profile name of "senior1"
    
  Scenario: Dismiss All Greens
    When I follow "Dismiss All Greens"
    Then I should not see any green battery

  Scenario Outline: Correct battery fill and color
    Given battery status for "senior1" is <number> percent
    When I visit "group1-admin" pending triage for group "group1"
    Then I should see <width> wide <color> battery for "senior1"
    
    Examples:
      | number | color  | width |
      | 9      | red    | 10    |
      | 10     | red    | 10    |
      | 20     | red    | 10    |
      | 25     | yellow | 25    |
      | 30     | yellow | 25    |
      | 50     | green  | 50    |
      | 60     | green  | 50    |
      | 75     | green  | 75    |
      | 85     | green  | 75    |
      | 100    | green  | 100   |
      | 110    | green  | 100   |

  Scenario Outline: Correct connectivity status icon
    Given last event for "senior1" is <event>
    When I visit "group1-admin" pending triage for group "group1"
    Then I should see <icon> icon for "senior1"
    
    Examples:
      | event                  | icon                     |
      | BatteryPlugged         | battery_plugged          |
      | DeviceAvailableAlert   | device_available_alert   |
      | DeviceUnavailableAlert | device_unavailable_alert |
      | GatewayOfflineAlert    | gateway_offline_alert    |
      | GatewayOnlineAlert     | gateway_online_alert     |
      | StrapFastened          | strap_fastened           |
      | StrapRemoved           | strap_removed            |

  # assuming all other conditions for the alert status are "normal" since we just created the user data
  # we can change the call_center_account_number to switch the status
  Scenario Outline: Correct Alert icon
    Given call center account number for "senior1" is "<number>"
    And a user intake exists with senior "senior1"
    When I visit "group1-admin" pending triage for group "group1"
    Then I should see <alert> alert for "senior1"
    
    Examples:
      | number     | alert    |
      | 1234567890 | normal   |
      |            | abnormal |
  
  Scenario: Order by Name
  Scenario: Order by Alert
  Scenario: Order by Battery
  Scenario: Order by Last Updated
  Scenario: Order by Special Status
