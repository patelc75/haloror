# 
#  Fri Feb 18 02:53:43 IST 2011, ramonrails
#   * TODO: can be refactored to use step from server_side_alerts_steps.rb for auth_key, file_name and path by convention
# 
#  Fri Feb 18 01:01:10 IST 2011, ramonrails
#   * If "Has check failed" error comes up, auth_key can be updated by
#   *  Digest::SHA256.hexdigest( <timestamp_from_xml> + <device.serial_number>)
@L1 @critical @bundle @management @flex
Feature: POST XML to simulate gateway
  In order to value
  As a role
  I want feature

  Background: Posting XML to controller should create appropriate records
    Given user "test-user, senior1" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "super admin" roles
    And user "senior1" has "halouser" role for group "group1"
    And the following devices:
      | serial_number |
      | H123456789    |
      | H567053101    |
    And there are no vitals, dial_up_alerts
  
  # IMPORTANT
  #   * key *must* be any of the following *only*
  #       "file name" or "file_name"
  #       "path"
  #       "auth key" or "auth_key"
  #   * path must be the full path including any /trailing/slashes/ if any
  #   * "there is no data for vitals" can have "vitals" as comma separated values
  #       Example: "vitals, panics, events, falls"
  #   * only specify the file name, for example "vital.xml"
  #       path for this file is assumed at Rails.root/specs/data/curl/
  Scenario: POST to vitals
    When I simulate a "Vital" event with the following attributes:
      | user | senior1 |
    Then user "senior1" should have data for vitals
    # "vitals" can be described as comma separated strings that can be sent to the user object as a method
    # example: Then user "senior1" should have vitals, id, name, panics

  # https://redmine.corp.halomonitor.com/issues/3528
  Scenario: dial_up_alert
    When I simulate a "dial up alert" event with the following attributes:
      | device | H567053101 |
      | user   | senior1    |
    Then device "H567053101" should have data for dial_up_alerts

  # 
  #  Wed Feb 23 03:10:12 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4168
  #   * POST the cURL twice and check single row with 'current' and 'new'
  Scenario: Mgmt Response (Info and Firmware Upgrade)
    When I simulate a "mgmt response" event with the following attributes:
      | cmd_type         | info       |
      | device           | H567053101 |
      | serial_num       | H567053101 |
      | user             | senior1    |
      | software_version | 00.00r35   |
    And I simulate a "mgmt response" event with the following attributes:
      | cmd_type         | info       |
      | device           | H567053101 |
      | serial_num       | H567053101 |
      | user             | senior1    |
      | software_version | 00.00r35   |
    Then device "H567053101" should have only one current and new software version

  Scenario: Alert Bundle
    When I simulate a "alert bundle" event with the following attributes:
      | device | H567053101    |
      | user   | senior1       |
      | path   | /alert_bundle |
    Then user "senior1" should have data for panic, gw alarm button

  @now @4282
  Scenario Outline: Flex Chart
    Given Fall event was recorded <count> times for "senior1" in the last 15 minutes
    When I simulate a "ChartQuery" event with the following attributes:
      | user       | senior1                                                        |
      | path       | /flex/chart                                                    |
      | startdate  | `15.minutes.ago.utc.strftime( Time::DATE_FORMATS[:date_time])` |
      | parameters | -k --basic -u test-user:12345                                  |
      | num_points | <points>                                                       |
    Then response XML should have xpath "//LastReading/orientation" with a value of 0
    And response XML <check> have xpath "//DataReadings/DataReading/orientation" with a value of <value>

    Examples:
      | count | points | value | check      |
      | 50    | 0      | 1     | should     |
      | 50    | 1      | 50    | should     |
      | 5     | 0      | 1     | should     |
      | 0     | 0      | 0     | should not |
      | 0     | 1      | 0     | should     |
