Feature: Config roles and groups
  In order to value
  As a role
  I want feature

  Background:
    Given a user "demo" exists with profile
    And I am authenticated as "demo" with password "12345"
    And the following groups:
      | name   |
      | group1 |
    And user "user1, user2" exists with profile
    And user "user1, user2" have "halouser" role for group "group1"
    
  Scenario: Super Admin can see the section to assign super_admin role
    Given user "demo" has "super_admin" role
    When I reload the page
    And I visit "/user_admin/roles"
    Then page content should have "Assign Super Admin Role"
    And page content should have user names for "user1, user2" within "#assign-super-admin"

  Scenario: Super Admin can assign super_admin role
    Given user "demo" has "super_admin" role
    When I reload the page
    And I visit "/user_admin/roles"
    And I select profile name of "user1" from "superadmin_user_id"
    And I press "Assign Super Admin Role"
    Then user "user1" should have "super_admin" role

  Scenario Outline: Nobody except super_admin can see "Assign Super Admin Role"
    Given user "demo" has "<role>" role for group "group1"
    When I reload the page
    And I visit "/user_admin/roles"
    Then I <status> see "Assign Super Admin Role"
    
    Examples:
      | role        | status     |
      | super admin | should     |
      | moderator   | should not |
      | halouser    | should not |
      | admin       | should not |
      | installer   | should not |
      | dummy role  | should not |
  
  # admin, super admin, moderator, installer
  Scenario Outline: Only specific roles can reach config page
    Given user "demo" has "<role>" role for group "group1"
    When I reload the page
    And I visit "/user_admin/roles"
    Then page content <status> have "Assign Roles, Remove Role, Groups"
    
    Examples:
      | role        | status     |
      | admin       | should     |
      | super admin | should     |
      | moderator   | should     |
      | installer   | should not |
      | dummy role  | should not |
      | halouser    | should not |

  Scenario: Admin will see a list of users from groups where they are admin
  Scenario: Admin will see list of groups where they are admin
  Scenario: Admin can assign roles to users within their group
  Scenario: Admin can remove roles for users within their group
  Scenario: Admin can create new groups
  Scenario: Admin can edit the existing groups where they are admin
  