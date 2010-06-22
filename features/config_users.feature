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
    
  Scenario Outline: 'Enable Test Mode' link available for each user
    Given user "demo" has "super admin" role
    And user "halouser1" has "halouser" role for group "<group>"
    When I reload the page
    And I follow links "Config > Users"
    And I select "group1" from "Group"
    Then I should see "<status> Test Mode" within "halouser1" user row
    
    Examples:
      | group       | status  |
      | group1      | Disable |
      | safety_care | Enable  |
    
  Scenario: Link to Enable or Disable Test Mode
  Scenario: Test Mode link for halousers only
  Scenario: Test Mode link visible to admin and super admin only
  Scenario: Triage shows Test Mode status
  