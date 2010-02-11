Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Background: Authenticated user
    # Given a user exists with the following attributes:
    #   | login                 | demo             |
    #   | password              | 12345            |
    #   | password_confirmation | 12345            |
    #   | email                 | demo@example.com |
    Given I am authenticated as "test_caregiver" with password "test"
        
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
    And user "test_caregiver" should have "subscriber" role for "test_caregiver" user

  Scenario: Submit new user_intake with billing same as #1 caregiver
    Given I am on new user_intake page
    When I uncheck "Same as User"
    And I uncheck "No Caregiver #1"
    And I check "Email" within "#caregiver_1"
    And I press "Submit"
    And I navigate to caregiver page for "test_caregiver" user
    Then user "test_caregiver" should have "halouser" role
    And user "test_caregiver" should have "subscriber, caregiver" roles for "test_caregiver" user
    And user "test_caregiver" should have email switched on for "test_caregiver" user
