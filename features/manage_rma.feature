Feature: Manage RMA
  In order to manage RMA tasks
  As a user
  I want list, edit, new for RMA with RMA items

  Background:
    Given a user "demo" exists with profile
    And I am authenticated as "demo" with password "12345"
    And user "demo" has "super_admin" role

  Scenario: New RMA
    Given a user exists with the following attributes:
      | id    | 100       |
      | login | test_user |
    And a group exists with the following attributes:
      | name | mygroup |
    And I am creating an rma
    When I fill in the following:
      | Serial Number        | 1234567890   |
      | Related RMA ID       | 123          |
      | Redmine Issue Ticket | 1234         |
      | RMA Completed Date   | 10 Jan 2010  |
      | Name                 | ship name    |
      | Address              | ship address |
      | City                 | ship city    |
      | State                | ship state   |
      | Zip Code             | 12345        |
      | Notes                | some text    |
    And I select the following:
      | RMA Status     | Waiting on Return |
      | Group          | mygroup           |
      | Service Outage | Yes               |
    And I press "Submit"
    Then page content should have "Show RMA, ship name, ship address, some text"

  Scenario: Edit RMA
    Given the following rmas:
      | serial_number |
      | 1234567890    |
      | 1111111111    |
    When I edit the 2nd rma
    And I fill in "Serial Number" with "54321"
    And I press "Submit"
    Then I should see "54321"

  Scenario: Delete RMA
    Given the following rmas:
      | serial_number |
      | 1234567890    |
      | 1111111111    |
    When I delete the 2nd rma
    Then I should see the following rmas:
      | Serial Number |
      | 1111111111    |
