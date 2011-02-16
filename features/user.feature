Feature: User status
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
    And a user "test-user" exists with profile
    
  Scenario Outline: User can have specific statuses
    Then I <action> change the status of user "test-user" to "<status>"
    
    Examples:
      | action | status             |
      | can    |                    |
      | can    | Ready for Approval |
      | can    | Ready to Install   |
      | can    | Ready to Bill      |
      | can    | Installed          |
      | can    | Test Mode          |
      | can    | Install Overdue    |
      | cannot | Anything else      |
      | cannot | Pending            |
    
  Scenario: User has pending status when created
    When I am ready to submit a user intake
    And I press "user_intake_submit"
    Then I should see "successfully"
    And the senior of user intake "1122334455" should have "Ready for Approval" status

  Scenario: Add separate column in users table for test mode to indicate that user is in test mode
    Then user "test-user" should have attribute "test_mode"

  Scenario: Keep status in users table (existing status column) and not the user_intakes table
    Given the following user intakes:
      | gateway_serial |
      | H234567890     |
    Then user intake "H234567890" should not have a status attribute
    And senior of user intake "H234567890" should have a status attribute

  Scenario: Super admin can change password for any config > user
    When I am changing the password for "test-user"
    And I fill in the following:
     | New Password        | abc123 |
     | Retype New Password | abc123 |
    And I press "update"
    Then I should see "Password Changed"
    Given I am authenticated as "test-user" with password "abc123"
    Then page content should have "Welcome, test-user"
    