Feature: User cache update
  In order to value
  As a role
  I want feature

  Scenario Outline: Auto update of cache fields in user table
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "super admin" roles
    And the following groups:
      | name   |
      | group1 |
    And a user "senior1" exists with profile
    And user "senior1" has "halouser" role for group "group1"
    When I get data in <event> for user "senior1"
    Then user "senior1" should have updated cache for <field>
    
    Examples:
      | event            | field                    |
      | battery          | last_battery_id          |
      | event            | last_event_id            |
      | vital            | last_vital_id            |
      | triage_audit_log | last_triage_audit_log_id |
      | panic            | last_panic_id            |
      | strap_fastened   | last_strap_fastened_id   |
