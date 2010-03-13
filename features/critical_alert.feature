# @wip will tell cucumber to skip this feature
#@wip
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
	    | name | safety_care |
  
  # @wip here will skip only this scenario, unless feature has @wip tag
  Scenario: Simulate a fall with successful delivery to the call center
    When I simulate a "Fall" with delivery "success" to the call center for a user with id as "44"
    Then I should have "1" count of "Fall"
  	And I should have a "Fall" alert "not pending" to the call center

  # Scenario: Simulate a fall with failed delivery to the call center
  #   When I simulate a "Fall" with delivery "failure" to the call center for a user with id as "44"
  #   Then I should have "1" count of "fall"
  # 	And I should have a "Fall" alert "pending" to the call center
	
	# TODO: Just raise an exception instead of handling it separately!
  #Scenario: Simulate a fall with failed delivery to the call center with valid call center account number
  #Scenario: Simulate a fall with failed delivery to the call center with invalid call center account number

