Feature: Reporting
  In order to value
  As a role
  I want feature

  Background: Authenticated user
    Given a user "test-user" exists with profile
    And user "test-user" has "super admin" roles
    And I am authenticated as "test-user" with password "12345"
    
  Scenario: Reporting > Users
    When I visit "/reporting/users"
    Then page content should have "Users table, Select Group"

  # Scenario: Reporting > Users > Search
  #   When I visit "/reporting/users"
  #   And I fill in "query" with "abc"
  #   And I press "Go"
  #   Then page content should have "ID, Name, Last Vitals POST, Links"

  Scenario: Config > Roles & Groups. Super admin can see all Groups
    When I visit "/user_admin/roles"
    Then page should have a dropdown for "all groups"

  # Scenario: Config > Roles & Groups > Assign Role
  #   Given a user "admin-of-group1" exists with profile
  #   And a user "new-admin-of-group1" exists with profile
  #   And the following groups:
  #     | name   |
  #     | group1 |
  #   And user "admin-of-group1" has "admin" role for group "group1"
  #   And user "new-admin-of-group1" has "halouser" role for group "group1"
  #   When I follow links "Config > Roles"
  #   And I select profile name of "new-admin-of-group1" from "role_user_id"
  #   And I select "admin" from "role_role_name"
  #   And I select "group1" from "role_group_name"
  #   And I press "Assign Role and Group"
  #   Then user "new-admin-of-group1" should have "admin" role for group "group1"
