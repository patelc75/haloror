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
      | 0123456789    |
      | 2567053101    |
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
    When I post the following for user "senior1":
      | file name | vital.xml                                                        |
      | path      | /vitals                                                          |
      | auth_key  | 9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024 |
    Then user "senior1" should have data for vitals
    # "vitals" can be described as comma separated strings that can be sent to the user object as a method
    # example: Then user "senior1" should have vitals, id, name, panics

  # https://redmine.corp.halomonitor.com/issues/3528
  Scenario: dial_up_alert should save correctly
    When I post the following for user "senior1":
      | file name | dial_up_alert.xml                                                |
      | path      | /dial_up_alerts                                                  |
      | auth_key  | f784568fc099809aece4b53444a1dc2e13db5406dbacff2ae04104ff98c5f167 |
      | device    | 2567053101                                                       |
    Then device "2567053101" should have data for dial_up_alerts
    