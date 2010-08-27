Feature: Bus user intake relations
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super_admin
  
  Scenario: All new user intakes get audit logged
    Given I am ready to submit a user intake
    When I press "user_intake_submit"
    Then the last user intake should have a recent audit log

  Scenario: All changes to user intake get audit logged
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    When I am listing user intakes
    And I edit the 1st user intake
    And I fill in "54321" for "Kit Serial"
    And I press "user_intake_submit"
    Then I last user intake should have a recent audit log

  Scenario: Any change to status gets logged to triage audit log
    Given a user "senior" exists with profile
    And user "senior" status gets changed to "Ready for Approval"
    Then user "senior" has a recent audit log for status "Ready for Approval"

  Scenario: Auto increment call center account number for "HM" accounts

  Scenario: Audit list is available for each user intake row
    Given the following user intakes:
      | kit_serial_number |
      | 11111             |
      | 22222             |
      | 33333             |
    When I am listing user intakes
    And I follow "audit_list" for the 1st user intake
    Then I should see "Audit List" for the user intake "11111"

  Scenario: Audit row can be viewed detailed
    Given the following user intakes:
      | kit_serial_number |
      | 11111             |
    And I am listing audit log for user intake "11111"
    And I follow "Details" for the first row
    Then the page content should have "Detail, 11111"

  Scenario: Audit rows cannot be edited or deleted
    Given the following user intakes:
      | kit_serial_number |
      | 11111             |
    And I am listing audit log for user intake "11111"
    Then page content should not have "edit, delete"
