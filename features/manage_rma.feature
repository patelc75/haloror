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
      | User ID              | 100          |
      | Serial Number        | 1234567890   |
      | Related RMA ID       | 123          |
      | Redmine Issue Ticket | 1234         |
      | RMA Created Date     | 1 Jan 2010   |
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
