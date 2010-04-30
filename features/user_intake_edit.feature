Feature: Edit user intake
  In order to value
  As a role
  I want feature

  Background: Authenticated user with basic data
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name       |
      | halo_group |
    And the following carriers:
      | name    |
      | verizon |
    And user "test-user" has "super admin, caregiver" roles
    # And a few user intakes exist
    
  # Scenario: Load 
  #   Given context
  #   When event
  #   Then outcome
  # 
