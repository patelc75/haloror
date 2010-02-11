Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Background: Authenticated user
    Given a user exists with the following attributes:
      | login                 | demo             |
      | password              | 12345            |
      | password_confirmation | 12345            |
      | email                 | demo@example.com |
    And I am authenticated as "test_caregiver" with password "test"
        
  Scenario: Submit new user_intake with billing same as user
    Given the following groups:
      | name       |
      | halo_group |
    And user "test_caregiver" has "super admin" role
    And I am on new user_intake page
    When I select "halo_group" from "Group"
    And I check "same_as_user" 
    And I press "Submit"
    Then user "test_caregiver" should have "halouser" role
    And user "test_caregiver" should have "subscriber" role for the "test_caregiver" user

  # Scenario: Submit new user_intake with billing same as #1 caregiver
  #   Given I am on the new user_intake page
  #   And I "Same As User" is not clicked
  #   When I click "Add as #1 Caregiver"
  #   And I click "Email" 
  #   And I press "Submit"
  #   And I go to call list for user "user"
  #   Then user "user" should have "halouser" role
  #   And user "separateuser" should have "subscriber, caregiver" roles for the "halouser" user
  #   And user "separateuser" should have email toggled for "halouser" user
