Feature: Critical Alert
  In order to process a fall, panic, or gw_alarm_button from the gateway
  As a system user
  I want verify the delivery of the critical alert

  Background:
    Given a user exists with the following attributes:
      | id | 44 |
    And a device exists with the following attributes:
      | id | 965 |
	And a group exists with the following attributes:
	  | id | 965 |
  
  Scenario: Simulate a fall with successful delivery to the call center
    When I send the "Fall" cURL command
 	And I perform a "success" delivery to the call center for a user with the following attributes:
      | id 	| 44 |
    Then I should have the following counts of data:
      | falls | 1 |
	And I should have a "Fall" alert "not pending" to the call center

  Scenario: Simulate a fall with failed delivery to the call center
    When I send the "Fall" cURL command
 	And I perform a "failure" delivery to the call center for a user with the following attributes:
      | id 	| 44 |
    Then I should have the following counts of data:
      | falls | 1 |
	And I should have a "Fall" alert "pending" to the call center

