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
    
  # Scenario: Link to Enable or Disable Test Mode
  #   This is now covered within the following
  Scenario Outline: 'Enable/Disable Test Mode' link available for each user
    Given user "demo" has "super admin" role
    And user "halouser1" has "halouser" role for group "<group>"
    When I reload the page
    And I follow links "Config > Users"
    And I select "group1" from "Group"
    Then I should see "//input[@value='<status> Test Mode']" xpath within "halouser1" user row
    
    Examples:
      | group       | status  |
      | group1      | Disable |
      | safety_care | Enable  |
      
  Scenario: Test Mode link for halousers only
    Given user "demo" has "super admin" role
    And a user "caregiver" exists with profile
    And user "halouser1" has "halouser" role for group "safety_care"
    And user "caregiver" has "caregiver" role for user "halouser1"
    When I reload the page
    And I follow links "Config > Users"
    And I select "group1" from "Group"
    Then I should see "//input[@value='Enable Test Mode']" xpath within "halouser1" user row
    And I should not see "Enable Test Mode" within "caregiver" user row
  
  # IMPORTANT: business logic states the following
  #   * Group dropdown will show groups where current_user (demo) is a member
  #   * Config menu link is visible to admin, super_admin, moderator, installer
  #   * Users link on config page is visible to admin, super_admin, moderator
  #   * reporting_controller.users action is allowed to admin, super_admin, operator, installer
  #   * "Test Mode" links are only visible to
  #     ** super_admin
  #     ** admin of the any group where halouser is a member
  Scenario Outline: Test Mode link visible to admin and super admin only
    Given user "demo" has "<role>, moderator, installer" role for group "<group>"
    And user "halouser1" has "halouser" role for group "<group>"
    When I reload the page
    And I follow "Config"
    And I follow "Users"
    And I select "<group>" from "Group"
    Then I <visible> see "//input[@value='<status> Test Mode']" xpath within "halouser1" user row
    
    Examples:
      | role        | group       | status  | visible    |
      | super_admin | group1      | Disable | should     |
      | super_admin | safety_care | Enable  | should     |
      | admin       | group1      | Disable | should     |
      | admin       | safety_care | Enable  | should     |
      | moderator   | group1      | Enable  | should not |
      | moderator   | group1      | Disable | should not |
      | moderator   | safety_care | Enable  | should not |
      | moderator   | safety_care | Disable | should not |
      | halouser    | group1      | Enable  | should not |
      | halouser    | group1      | Disable | should not |
      | halouser    | safety_care | Enable  | should not |
      | halouser    | safety_care | Disable | should not |
      | installer   | group1      | Enable  | should not |
      | installer   | group1      | Disable | should not |
      | installer   | safety_care | Enable  | should not |
      | installer   | safety_care | Disable | should not |

  Scenario: Triage shows Test Mode status
    Given user "demo" has "admin" role for group "group1"
    And user "halouser1" has "halouser" role for group "group1"
    When I reload the page
    And I follow links "Reporting > Triage"
    And I select "group1" from "Group"
    Then I should see "TEST MODE" within "halouser1" user row

  Scenario Outline: Switch between Enable / Disable Test Mode
    Given user "demo" has "super admin" role
    And a user "caregiver" exists with profile
    And user "halouser1" has "halouser" role for group "<group>"
    And user "caregiver" has "caregiver" role for user "halouser1"
    When I reload the page
    And I follow links "Config > Users"
    And I select "group1" from "Group"
    And I press "<action> Test Mode" within "halouser1" user row
    Then I <test_mode_status> see "TEST MODE"
    And user "halouser1" <safety_care_membership> have "halouser" role for group "safety_care"
    
    Examples:
      | group       | action  | test_mode_status | safety_care_membership |
      | safety_care | Enable  | should           | should not             |
      # | group1      | Disable | should not       | should                 |
