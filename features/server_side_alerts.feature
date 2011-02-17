Feature: Server Side Alerts
  In order GatewayOfflineAlert, then DeviceUnavilableAlert and StrapOffAlert
  As a system user
  I want verify the delivery of the server side alerts

  Background:
    Given a user "test-user" exists with profile
    And a device exists with the following attributes:
    | serial_number | H234567890 |
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

  Scenario: Simulate a StrapOffAlert for a user
    When I simulate a "Strap Fastened" event with the following attributes:
      | user      | test-user     |
      | timestamp | `7.hours.ago` |
      | device    | H234567890    |
    And background scheduler has detected strap offs
    Then device "H234567890" should state the strap fastened between now and "`7.hours.ago`"
    And I should have "1" count of "StrapOffAlert"

  @wip
  Scenario: Simulate a GatewayOfflineAlert for a user
    When I simulate a "MgmtQuery" with the timestamp "7.hours.ago" and device_id "145"
    Then I should have "1" count of "DeviceLatestQuery"
    And I should have "1" count of "GatewayOfflineAlert" 


