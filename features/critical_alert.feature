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
    And I do not have any falls, events

  # @wip here will skip only this scenario, unless feature has @wip tag
  Scenario: Simulate a fall with successful delivery to the call center
    When user "test-user" has "halouser" role for group "safety_care"
    And I simulate a "Fall" with delivery to the call center for user login "test-user" with a "valid" "call center account number"
    Then I should have "1" count of "Fall"
    And I should have a "Fall" alert "not pending" to the call center with a "valid" call center delivery timestamp

  Scenario: Simulate a fall for a user with no call center group (eg. "safety_care")
    When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
    Then I should have "1" count of "Fall"
    And I should have a "Fall" alert "not pending" to the call center with a "missing" call center delivery timestamp

  Scenario: Simulate a fall for a user with an invalid call center account number
    When user "test-user" has "halouser" role for group "safety_care"
    And I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
    Then I should have "1" count of "Fall"
    And I should have a "Fall" alert "not pending" to the call center with a "missing" call center delivery timestamp
    And 1 email to "exceptions_critical@halomonitoring.com" with subject "SafetyCareClient.alert::Missing account number!" should be sent for delivery

  Scenario: Simulate a fall for a user with an with invalid profile
    When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "profile"
    Then I should have "1" count of "Fall"
    And I should have a "Fall" alert "not pending" to the call center with a "missing" call center delivery timestamp
    # FIXME: switched off for now. will check later
    # And email to "exceptions_critical@halomonitoring.com" with subject "Missing user profile!" should be sent for delivery

  # Scenario: Simulate a fall with  delivery to the call center with Timeout exception
  #   When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "TCP connection"
  #   Then I should have "1" count of "Fall"
  #   And I should have a "Fall" alert "pending" to the call center


  Scenario: check battery status available and battery plugged
    When Battery status is "available" and "BatteryPlugged" is latest for user login "test-user"
    Then I should have "Battery Plugged" for user "test-user"

  Scenario: check battery status available battery unplugged
    When Battery status is "available" and "BatteryUnplugged" is latest for user login "test-user"
    Then I should have "Battery Unplugged" for user "test-user"

  Scenario: check battery status unavailable and battery plugged
    When Battery status is "unavailable" and "BatteryPlugged" is latest for user login "test-user"
    Then I should have "Battery Plugged" for user "test-user"

  Scenario: check battery status unavailable and battery unplugged
    When Battery status is "unavailable" and "BatteryUnplugged" is latest for user login "test-user"
    Then I should have "Battery Unplugged" for user "test-user"

