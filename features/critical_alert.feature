# @wip will tell cucumber to skip this feature
#@wip
Feature: Critical Alert
  In order to process a fall, panic, or gw_alarm_button from the gateway
  As a system user
  I want verify the delivery of the critical alert

  Background:
	  Given a user "test-user" exists with profile
	  And a device exists with the following attributes:
	    | id | 965 |                                   
		And a group exists with the following attributes:
		  | name       | halo        |
	  And a group exists with the following attributes:
	    | name       | safety_care |
	    | sales_type | call_center |
		And user "test-user" has "halouser" role for group "halo"
  
  # @wip here will skip only this scenario, unless feature has @wip tag
  Scenario: Simulate a fall with successful delivery to the call center
		When user "test-user" has "halouser" role for group "safety_care"
    And I simulate a "Fall" with delivery to the call center for user login "test-user" with a "valid" "call center account number"
    Then I should have "1" count of "Fall"
  	And I should have a "Fall" alert "not pending" to the call center 
 #with "valid" timestamp of the call center delivery

  Scenario: Simulate a fall with no call center group
    When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
    Then I should have "1" count of "Fall"
  	And I should have a "Fall" alert "not pending" to the call center 
 #with "no" timestamp of the call center delivery
  	
  # Scenario: Simulate a fall with delivery to the call center with invalid call center account number
  # 	When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
  #   Then I should have "1" count of "Fall"
  # 	And I should have a "Fall" alert "not pending" to the call center
  # 	And email to "exceptions@halomonitoring.com" with subject "SafetyCareClient.alert::Missing account number!" should be sent for delivery
   
  # Scenario: Simulate a fall with delivery to the call center with invalid profile
  #   When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "profile"
  #   Then I should have "1" count of "Fall"
  # 	And I should have a "Fall" alert "not pending" to the call center 
  # 		And email to "exceptions@halomonitoring.com" with subject "SafetyCareClient.alert::Missing user profile!" should be sent for delivery
                                                                     
	# Scenario: Simulate a fall with  delivery to the call center with Timeout exception
	# 	When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "TCP connection"
	#   Then I should have "1" count of "Fall"
	#   And I should have a "Fall" alert "pending" to the call center  











	

