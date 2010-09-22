Feature: User cache update
  In order to value
  As a role
  I want feature

  # factories.rb updated to generate emails based on <login>@example.com pattern
  Scenario Outline: Auto update of cache fields in user table
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "super admin" roles
    And the following groups:
      | name   |
      | group1 |
    And a user "senior1" exists with profile
    And user "senior1" has "halouser" role for group "group1"
    And there is no data for emails
    When I get data in <event> for user "senior1"
    Then user "senior1" should have updated cache for <field>
    And no email to "senior1@example.com" with subject "Please read before your installation" should be sent for delivery
    And no email to "senior1@example.com" with subject "Please activate your new myHalo account" should be sent for delivery
    And no email to "senior1@example.com" with subject "Your account has been activated!" should be sent for delivery
    
    Examples:
      | event            | field                    |
      | battery          | last_battery_id          |
      | event            | last_event_id            |
      | vital            | last_vital_id            |
      | triage_audit_log | last_triage_audit_log_id |
      | strap_fastened   | last_strap_fastened_id   |
#      | panic            | last_panic_id            |
# TODO: Thu Sep 16 23:21:31 IST 2010 > need to visit this at the first opportunity
