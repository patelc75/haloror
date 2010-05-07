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
    And user "test-user" has "super_admin, caregiver" roles
    
  # 1. Editing a user intake should work exactly as any other model
  #    This includes all associated models like senior, subscriber, ... and their profiles
  # 2. Emails for installation or activation shouldnot be fired when user intake is updated
  #    These emails trigger when user intake is first created
  Scenario: Editing a user intake should show edit view. Does not trigger emails again
    Given the following user intakes:
      | kit_serial_number |
      | 1122334455        |
    And Email dispatch queue is empty
    When I edit the 1st user intake
    And I fill in "user_intake_kit_serial_number" with "9876543210123456789"
    And I press "Submit"
    Then I should see "9876543210123456789"
    And no email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery

  Scenario: User Intake locks on Submit
    Given the following user intakes:
      | kit_serial_number |
      | 1122334455        |
    When I edit the 1st user intake
    And I press "Submit"
    And I am listing user intakes
    Then the 1st row should contain "Show"
