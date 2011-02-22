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
      # And the following device_models:
      # | part_number | device_type_name |
      # | 12001002-1  | Chest Strap      |
      # And the following device_revisions:
      # | device_model_part_number | revision |
      # | 12001002-1               | v1-1     |
    And a device exists with the following attributes:
       | serial_number           | H134567890 |
       | user_login              | test-user  |
       | access_mode_status_name | ethernet   |
      # | device_revision_number  | v1-1       |
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
      | device    | H134567890 |
    And background scheduler has detected strap offs
    #   * we are adding some extra time to keep the last simulated event within the span window
    Then device "H134567890" should state the strap <event> between now and "`<time_ago> - 1.minute`"
    And I should exactly have <how_many> counts of "StrapOffAlert" and events
    
    Examples:
      | time_ago         | how_many | event    |
      | `7.hours.ago`    | 1        | fastened |
      | `30.minutes.ago` | 1        | fastened |
      | `30.minutes.ago` | 1        | removed  |
      | `7.hours.ago`    | 3        | removed  |

  @wip
  Scenario: Simulate a GatewayOfflineAlert for a user
    When I simulate a "MgmtQuery" with the timestamp "7.hours.ago" and device_id "145"
    Then I should have "1" count of "DeviceLatestQuery"
    And I should have "1" count of "GatewayOfflineAlert" 
