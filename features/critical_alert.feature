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
	    | name | safety_care |
  
  # @wip here will skip only this scenario, unless feature has @wip tag
  Scenario: Simulate a fall with successful delivery to the call center
    When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "valid" "call center account number"
    Then I should have "1" count of "Fall"
  	And I should have a "Fall" alert "not pending" to the call center

	# TODO: Just raise an exception instead of handling it separately!
  Scenario: Simulate a fall with delivery to the call center with invalid call center account number
  	When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"

  Scenario: Simulate a fall with delivery to the call center with invalid profile
		When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "profile"

	Scenario: Simulate a fall with  delivery to the call center with Timeout exception
		When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "TCP connection"
		

	#Try fall with user with no profile and check if crit.save = false
	#Try fall with user with no SC acct # and check if crit.save = true
	#See http://gist.github.com/331033

  #ActiveRecord has its own transaction. So if before_save fails then it will not save. 
  #If you handle the exception in the rescue block, not sure if it will save
  #If profile missing OR safetycare acct # missing THEN do NOT update call_center_pending and timestamp_call_center
  #http://m.onkey.org/2009/8/7/save-save
  #http://robots.thoughtbot.com/post/159807850/save-bang-your-head-active-record-will-drive-you-mad





	

