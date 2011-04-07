@L1 @intake @billing @store
Feature: Config roles and groups
  In order to value
  As a role
  I want feature

  Background:
    Given a user "demo" exists with profile
    And I am authenticated as "demo" with password "12345"
    And the following groups:
      | name     |
      | group1   |
      | newgroup |
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
    And I follow links "Config > Roles"
    And I select id and name of "user1" from "superadmin_user_id"
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
    Then page content <status> have "Assign Roles, Remove Role"
    
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
  
  Scenario: Config > Roles > change group of halouser > User Intake and Order group gets re-assigned
    Given the product catalog exists
    And I am an authenticated super admin
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I place an online order for "reseller" group
    And I switch senior of last order to become "halouser" of "newgroup"
    Then last user intake should have group "newgroup"
    And last order should have group "newgroup"
    