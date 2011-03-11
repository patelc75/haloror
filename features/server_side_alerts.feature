@L1 @critical
Feature: Server Side Alerts
  In order GatewayOfflineAlert, then DeviceUnavilableAlert and StrapOffAlert
  As a system user
  I want verify the delivery of the server side alerts

  Background:
    Given a user "test-user" exists with profile
    And the following device_types:
      | device_type | Chest Strap |
    And the following access_mode_statuses:
      | mode | ethernet |
    And the following devices:
       | serial_number | user_login | access_mode_status_name |
       | H134567890    | test-user  | ethernet                |
       | H122334455    |            | ethernet                |
    And the following groups:
      | name        | sales_type  |
      | halo        |             |
      | safety_care | call_center |
    And user "test-user" has "halouser" role for group "halo"
    And there are no gateway_offline_alerts, mgmt_queries
    And the following system timeouts:
      | mode     | strap_off_timeout_sec |
      | dialup   | 3600                  |
      | ethernet | 3600                  |

  Scenario Outline: Simulate a StrapOffAlert for a user
    When I simulate a "Strap <event>" event with the following attributes:
      | user      | test-user  |
      | timestamp | <time_ago> |
      | device    | <device> |
    And background scheduler has detected strap offs
    #   * we are adding some extra time to keep the last simulated event within the span window
    Then device "<device>" should state the strap <event> between now and "`<time_ago> - 1.minute`"
    And I should exactly have <how_many> counts of "StrapOffAlert" and events
    
    Examples:
      | time_ago         | how_many | event    | device     |
      | `7.hours.ago`    | 1        | fastened | H134567890 |
      | `30.minutes.ago` | 1        | fastened | H134567890 |
      | `30.minutes.ago` | 1        | removed  | H134567890 |
      | `7.hours.ago`    | 3        | removed  | H134567890 |
      #   * no additional events created unless user is mapped to device
      | `7.hours.ago`    | 1        | fastened | H122334455 |
      | `30.minutes.ago` | 1        | fastened | H122334455 |
      | `30.minutes.ago` | 1        | removed  | H122334455 |
      | `7.hours.ago`    | 1        | removed  | H122334455 |

  @wip
  Scenario: Simulate a GatewayOfflineAlert for a user
    When I simulate a "MgmtQuery" with the timestamp "7.hours.ago" and device_id "145"
    Then I should have "1" count of "DeviceLatestQuery"
    And I should have "1" count of "GatewayOfflineAlert" 
