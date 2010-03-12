# @wip will tell cucumber to skip this feature
@wip
Feature: Critical Alert
  In order to process a fall, panic, or gw_alarm_button from the gateway
  As a system user
  I want verify the delivery of the critical alert

  Background:
    Given an exisitng user with id as "44"
    And an existing device with id as "965"
  	And an existing group with id as "965"
  
  # @wip here will skip only this scenario, unless feature has @wip tag
  Scenario: Simulate a fall with successful delivery to the call center
    When I simulate a "Fall" with delivery "success" to the call center for a user with id as "44"
    Then I should have "1" count of "fall"
  	And I should have a "Fall" alert "not pending" to the call center

  Scenario: Simulate a fall with failed delivery to the call center
    When I simulate a "fall"with delivery "failure" to the call center for a user with id as "44"
    Then I should have "1" count of "fall"
  	And I should have a "Fall" alert "pending" to the call center
