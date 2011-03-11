# @wip will tell cucumber to skip this feature
#@wip
# TODO: Add Panic to critical_alert.feature and make sure it is run every time
@L1 @critical
Feature: Critical Alert
  In order to process a fall, panic, or gw_alarm_button from the gateway
  As a system user
  I want verify the delivery of the critical alert

  #
  #  Sat Feb 26 01:29:13 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4223
  Background:
    Given a user "test-user" exists with profile
    And a user "senior-user" exists with profile
    And a user exists with the following attributes:
      | login      | caregiver-user         |
      | email      | caregiver@cucumber.com |
      And user "caregiver-user" has "1234567890" cell phone
    And a user exists with the following attributes:
      | login      | operator-user          |
      | email      | operator@cucumber.com  |
    And user "operator-user" has "0987654321" cell phone
    And a device exists with the following attributes:
      | serial_number | 1234567890 |
    And the following groups:
      | name        | sales_type  |
      | halo        |             |
      | safety_care | call_center |
      # | cms         | call_center |
    And the following devices:
      | serial_number |
      | H123456789    |
      | H567053101    |
    And critical alerts types exist
    And a carrier exists with the following attributes:
      | name   | cell_carrier    |
      | domain | @cingularme.com |
    And there are no falls, events, emails, alert_options
    And user "test-user" has "halouser" role for group "halo"
    And user "senior-user" has "halouser" role for group "halo"
    And user "operator-user" has "operator" role for group "safety_care"
    And user "caregiver-user" has "caregiver" role for user "senior-user, test-user"
    And user "caregiver-user" has "cell_carrier" carrier
    And user "operator-user" has "cell_carrier" carrier
    And "caregiver-user" is set to receive email for senior "senior-user, test-user"
    And "caregiver-user" is set to receive text for senior "senior-user, test-user"
    And "operator-user" is set to receive email for group "safety_care"
    And "operator-user" is set to receive text for group "safety_care"
    And "caregiver-user" is active caregiver for senior "senior-user, test-user"
    And "operator-user" is active operator for group "safety_care"

  Scenario Outline: Simulate a <event> with successful text and email delivery to the call center
    When user "senior-user" has "halouser" role for group "safety_care"
    And user "test-user" has "halouser" role for group "safety_care"
    And I simulate a "<event>" with delivery to the call center for user login "senior-user" with a "valid" "call center account number"
    Then I should have 1 count of "<event>"
    And I should have a "<event>" alert "not pending" to the call center with a "valid" call center delivery timestamp
    # And user "caregiver-user" has "caregiver" roles for user "senior-user"
    And 1 email to "caregiver@cucumber.com" with keyword "<action>" should be sent for delivery
    And 1 email to "1234567890@cingularme.com" with keyword "<action>" should be sent for delivery
    And 1 email to "operator@cucumber.com" with keyword "<caps>" should be sent for delivery
    And 1 email to "0987654321@cingularme.com" with keyword "<caps>" should be sent for delivery

    Examples:
      | event         | action   | caps  |
      | Fall          | fell     | FALL  |
      | Panic         | panicked | PANIC |
      | GwAlarmButton | cleared  | CLEAR |

  Scenario Outline: Simulate a <event> for a user with no call center group (eg. "safety_care")
    When I simulate a "<event>" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
    Then I should have 1 count of "<event>"
    And I should have a "<event>" alert "not pending" to the call center with a "missing" call center delivery timestamp
    And 1 email to "caregiver@cucumber.com" with keyword "<action>" should be sent for delivery
    And 1 email to "1234567890@cingularme.com" with keyword "<action>" should be sent for delivery
    And no email to "operator@cucumber.com" with keyword "<caps>" should be sent for delivery
    And no email to "0987654321@cingularme.com" with keyword "<caps>" should be sent for delivery

    Examples:
      | event         | action   | caps  |
      | Fall          | fell     | FALL  |
      | Panic         | panicked | PANIC |
      | GwAlarmButton | cleared  | CLEAR |

  # 
  #  Wed Mar  9 03:39:08 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4260
  Scenario Outline: Simulate an alert_bundle with successful text and email delivery to the call center
    When user "senior-user" has "halouser" role for group "safety_care"
    When user "senior-user" has valid call center account
    And system timeout exists with no tolerence
    And I simulate a "alert bundle" event with the following attributes:
      | device           | H567053101      |
      | user             | senior-user     |
      | path             | /alert_bundle   |
      | timestamp        | `2.minutes.ago` |
      | timestamp_server | `1.minute.ago`  |
    And critical alerts are processed by a background job
    Then I should have 1 counts of "Panic"
    And I should have 1 counts of "GwAlarmButton"
    And I should have a "Panic" alert "not pending" to the call center with a "valid" call center delivery timestamp
    And I should have a "GwAlarmButton" alert "not pending" to the call center with a "valid" call center delivery timestamp
    And 1 email to "caregiver@cucumber.com" with keyword "<action>" should be sent for delivery
    And 1 email to "1234567890@cingularme.com" with keyword "<action>" should be sent for delivery
    And 1 email to "operator@cucumber.com" with keyword "<caps>" should be sent for delivery
    And 1 email to "0987654321@cingularme.com" with keyword "<caps>" should be sent for delivery

    Examples:
      | event         | action   | caps  |
      | Panic         | panicked | PANIC |
      | GwAlarmButton | cleared  | CLEAR |

  # https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Simulate a fall for a user with an invalid call center account number
  #   When user "test-user" has "halouser" role for group "safety_care"
  #   And I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "call center account number"
  #   Then I should have 1 count of "Fall"
  #   And I should have a "Fall" alert "not pending" to the call center with a "missing" call center delivery timestamp
  #   And 1 email to "exceptions_critical@halomonitoring.com" with subject "SafetyCareClient.alert::Missing account number!" should be sent for delivery

  # "Missing user profile!" is a common phrase passed on to 2 methods called at CriticalDeviceEventObserver
  # we are noe checking more specific subject
  Scenario: Simulate a fall for a user with an with invalid profile
    When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "profile"
    Then I should have 1 count of "Fall"
    And I should have a "Fall" alert "not pending" to the call center with a "missing" call center delivery timestamp
    And 2 emails to "exceptions_critical@halomonitoring.com" with subject "Missing user profile!" should be sent for delivery
    And 1 email to "exceptions_critical@halomonitoring.com" with subject "call center monitoring failure" should be sent for delivery

  #
  #  Fri Feb  4 00:59:03 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4147
  Scenario: Simulate a panic button press with successful delivery to the call center even if there is an exception caregiver
    Given user "test-user" has 3 caregivers
    And a caregiver of "test-user" can raise exception
    When user "test-user" has "halouser" role for group "safety_care"
    And I simulate a "Panic" with delivery to the call center for user login "test-user" with a "valid" "call center account number"
    Then I should have 1 count of "Panic"
    And I should have a "Panic" alert "not pending" to the call center with a "valid" call center delivery timestamp
    #   * usually only 1 email is sent
    #   * 3 emails due to "caregiver ... can raise exception" and panic sending additional email about "Technical Exception"
    # 
    #  Tue Mar  1 23:28:25 IST 2011, ramonrails
    #   * caregiver gets email every time. event or rufus
    #   * 1 event = 2 emails ( event + rufus )
    And 2 emails to "exceptions_critical@halomonitoring.com" with subject "call center monitoring failure" should be sent for delivery

  # Scenario: Simulate a fall with  delivery to the call center with Timeout exception
  #   When I simulate a "Fall" with delivery to the call center for user login "test-user" with a "invalid" "TCP connection"
  #   Then I should have 1 count of "Fall"
  #   And I should have a "Fall" alert "pending" to the call center

  Scenario Outline: check battery status available and battery plugged
    When Battery status is "<status>" and "<event>" is latest for user login "test-user"
    Then I should have "<message>" for user "test-user"

    Examples:
      | status      | event            | message           |
      | available   | BatteryPlugged   | Battery Plugged   |
      | available   | BatteryUnplugged | Battery Unplugged |
      | unavailable | BatteryPlugged   | Battery Plugged   |
      | unavailable | BatteryUnplugged | Battery Unplugged |