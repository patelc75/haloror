Feature: Reporting
  In order to value
  As a role
  I want feature

  Background: Authenticated user
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "super admin" roles
    
  Scenario: Reporting > Users
    When I visit "/reporting/users"
    Then page content should have "Users table, Select Group"

  Scenario: Reporting > Users > Search
    When I visit "/reporting/users"
    And I fill in "query" with "abc"
    And I press "Go"
    Then page content should have "ID, Name, Last Login, Links"
    