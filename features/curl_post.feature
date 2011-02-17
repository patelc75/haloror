# 
#  Fri Feb 18 02:53:43 IST 2011, ramonrails
#   * TODO: can be refactored to use step from server_side_alerts_steps.rb for auth_key, file_name and path by convention
# 
#  Fri Feb 18 01:01:10 IST 2011, ramonrails
#   * If "Has check failed" error comes up, auth_key can be updated by
#   *  Digest::SHA256.hexdigest( <timestamp_from_xml> + <device.serial_number>)
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
    When I post the following XML:
      | file name | vital.xml                                                        |
      | path      | /vitals                                                          |
      | auth_key  | 79b07340615c437b2abeba18e8041c4042e7168904728fee9d0676300688142d |
      | user      | senior1                                                          |
    Then user "senior1" should have data for vitals
    # "vitals" can be described as comma separated strings that can be sent to the user object as a method
    # example: Then user "senior1" should have vitals, id, name, panics

  # https://redmine.corp.halomonitor.com/issues/3528
  Scenario: dial_up_alert should save correctly
    When I post the following XML:
      | file name | dial_up_alert.xml                                                |
      | path      | /dial_up_alerts                                                  |
      | auth_key  | fc3f7c38921225f8011e65724aa74bc064d9bbc3851c8b002303a694bb2e79ae |
      | device    | H567053101                                                       |
      | user      | senior1                                                          |
    Then device "H567053101" should have data for dial_up_alerts
    