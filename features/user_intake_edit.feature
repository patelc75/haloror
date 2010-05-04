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
    
  Scenario: Editing a user intake should show edit view
    Given the following user intakes:
      | kit_serial_number |
      | 1122334455        |
    When I edit the 1st user intake
    And I fill in "user_intake_kit_serial_number" with "9876543210123456789"
    And I press "Submit"
    Then I should see "9876543210123456789"
