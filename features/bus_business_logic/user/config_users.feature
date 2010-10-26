Feature: Config users
  In order to value
  As a role
  I want feature

  Background:
    Given a user "demo" exists with profile
    And the following groups:
      | name        |
      | group1      |
      | safety_care |
    And a user "halouser1" exists with profile
    And I am authenticated as "demo" with password "12345"
    
  # TODO: 1.6.0: UI features skipped for now
  #
  # # Scenario: Link to Enable or Disable Test Mode
  # #   This is now covered within the following
  # Scenario Outline: 'Enable/Disable Test Mode' link available for each user
  #   Given user "demo" has "super admin" role
  #   And user "halouser1" has "halouser" role for group "<group>"
  #   And user "halouser1" <mode> in test mode
  #   When I reload the page
  #   And I follow links "Config > Users"
  #   And I select "group1" from "Group"
  #   Then I should see ".//input[@value='<status> Test Mode']" xpath within "halouser1" user row
  #   
  #   Examples:
  #     | group       | status  | mode   |
  #     | group1      | Disable | is     |
  #     | safety_care | Enable  | is not |
      
  # Mon Oct  4 19:46:55 IST 2010 v1.6.0 PQ
  # TODO:
  #   skipped for now. UI specific checks skipped. Test mode smoke tested and wokring
  #
  # Scenario: Test Mode link for halousers only
  #   Given user "demo" has "super admin" role
  #   And a user "caregiver" exists with profile
  #   And user "halouser1" has "halouser" role for group "safety_care"
  #   And user "caregiver" has "caregiver" role for user "halouser1"
  #   And user "halouser1" is not in test mode
  #   And user "caregiver" is in test mode
  #   When I reload the page
  #   And I follow links "Config > Users"
  #   And I select "group1" from "Group"
  #   And debug
  #   Then I should see ".//input[@value='Enable Test Mode']" xpath within "halouser1" user row
  #   Then I should not see ".//input[@value='Enable Test Mode']" xpath within "caregiver" user row
  
  # IMPORTANT: business logic states the following
  #   * Group dropdown will show groups where current_user (demo) is a member
  #   * Config menu link is visible to admin, super_admin, moderator, installer
  #   * Users link on config page is visible to admin, super_admin, moderator
  #   * reporting_controller.users action is allowed to admin, super_admin, operator, installer
  #   * "Test Mode" links are only visible to
  #     ** super_admin
  #     ** admin of the any group where halouser is a member
  #   * The business logic has changed to check user.test_mode instead of safety_care group membership, ...
  Scenario Outline: Test Mode link visible to admin and super admin only
    Given user "demo" has "<role>, moderator, installer" role for group "<group>"
    And user "halouser1" has "halouser" role for group "<group>"
    And user "halouser1" <mode> in test mode
    When I reload the page
    And I follow "Config"
    And I follow "users_all"
    And I select "<group>" from "Group"
    Then I <visible> see ".//input[@value='<status> Test Mode']" xpath within "halouser1" user row
    
    Examples:
      | role        | group       | status  | visible    | mode   |
      | admin       | group1      | Disable | should     | is     |
      | admin       | safety_care | Disable | should     | is     |
      | moderator   | group1      | Enable  | should not | is not |
      | moderator   | group1      | Enable  | should not | is not |
      | moderator   | safety_care | Enable  | should not | is not |
      | moderator   | safety_care | Enable  | should not | is not |
      | halouser    | group1      | Enable  | should not | is not |
      | halouser    | group1      | Enable  | should not | is not |
      | halouser    | safety_care | Enable  | should not | is not |
      | halouser    | safety_care | Enable  | should not | is not |
      | installer   | group1      | Enable  | should not | is not |
      | installer   | group1      | Enable  | should not | is not |
      | installer   | safety_care | Enable  | should not | is not |
      | installer   | safety_care | Enable  | should not | is not |
      # | super_admin | group1      | Disable | should     | is     |
      # | super_admin | safety_care | Disable | should     | is     |
      #
      # v1.6.0 UI specific checks skipped for now

  Scenario: Triage shows Test Mode status
    Given user "demo" has "admin" role for group "group1"
    And user "halouser1" has "halouser" role for group "group1"
    When I reload the page
    And I follow links "Reporting > Triage"
    And I select "group1" from "Group"
    And I press "Apply selected filters"
    Then I should see "Test Mode" within "halouser1" user row

  # TODO: 1.6.0.: UI features skipped
  #
  # Scenario Outline: Switch between Enable / Disable Test Mode
  #   Given user "demo" has "super admin" role
  #   And a user "caregiver" exists with profile
  #   And user "halouser1" has "halouser" role for group "group1, <group>"
  #   And user "caregiver" has "caregiver" role for user "halouser1"
  #   And user "halouser1" is not in test mode
  #   When I reload the page
  #   And I follow links "Config > Users"
  #   And I select "group1" from "Group"
  #   And debug
  #   And I press "<action> Test Mode" within "halouser1" user row
  #   Then I <test_mode_status> see "Test Mode"
  #   And user "halouser1" <safety_care_membership> have "halouser" role for group "safety_care"
  #   
  #   Examples:
  #     | group       | action  | test_mode_status | safety_care_membership |
  #     | safety_care | Enable  | should           | should not             |
  #     | group1      | Disable | should not       | should                 |
