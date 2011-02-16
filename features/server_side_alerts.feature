Feature: Server Side Alerts
  In order GatewayOfflineAlert, then DeviceUnavilableAlert and StrapOffAlert
  As a system user
  I want verify the delivery of the server side alerts

  Background:
    Given a user "test-user" exists with profile
    And a device exists with the following attributes:
      | serial_number | 1234567890 |
    And a group exists with the following attributes:
      | name | halo |
    And a group exists with the following attributes:
      | name       | safety_care |
      | sales_type | call_center |
    And user "test-user" has "halouser" role for group "halo"
    And there are no gateway_offline_alerts, mgmt_queries

   Scenario: Simulate a StrapOffAlert for a user
     When I simulate a "Strap Fastened" with the timestamp "7.hours.ago" and device_id "145"
     Then I "device_strap_status" device_id "145" should be "1"
     Then I should have "1" count of "StrapOffAlert" 


@wip
  Scenario: Simulate a GatewayOfflineAlert for a user
    When I simulate a "MgmtQuery" with the timestamp "7.hours.ago" and device_id "145"
    Then I should have "1" count of "DeviceLatestQuery"
    Then I should have "1" count of "GatewayOfflineAlert" 
    
    
