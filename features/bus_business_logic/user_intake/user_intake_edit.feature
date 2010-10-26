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
    
  # https://redmine.corp.halomonitor.com/issues/3170
  # # 1. Editing a user intake should work exactly as any other model
  # #    This includes all associated models like senior, subscriber, ... and their profiles
  # # 2. Emails for installation or activation shouldnot be fired when user intake is updated
  # #    These emails trigger when user intake is first created
  Scenario: Editing a user intake should show edit view. Does not trigger emails again
    Given the following user intakes:
      | gateway_serial | submitted_at |
      | 1122334455     |              |
    And Email dispatch queue is empty
    And user intake "1122334455" is not submitted
    And I am listing user intakes
    And I follow "edit_link" in the 1st row
    And I fill in "user_intake_gateway_serial" with "1234567890"
    And I press "user_intake_submit"
    Then I should see "successfully updated"
    And no email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: User Intake locks on Submit
    Given the following user intakes:
      | gateway_serial | submitted_at |
      | 1122334455     |              |
    When user intake "1122334455" is not submitted
    And I am listing user intakes
    And I follow "edit_link" in the 1st row
    And I press "user_intake_submit"
    And I am listing user intakes
    Then the 1st row should not contain "Not Submitted"
