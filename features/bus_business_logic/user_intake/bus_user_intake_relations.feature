Feature: Bus user intake relations
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super_admin
  
  Scenario: All new user intakes get audit logged
    Given I am ready to submit a user intake
    When I press "user_intake_submit"
    Then the last user intake has audit log

  Scenario: All changes to user intake get audit logged
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    When I update kit serial for user intake "12345" to "54321"
    Then the last user intake has a recent audit log

  Scenario: Any change to status gets logged to triage audit log
    Given the following user intakes:
      | kit_serial_number |
      | 11111             |
    When user intake "11111" is submitted again
    Then senior of user intake "11111" has a recent audit log for status "Ready for Approval"

  Scenario: Auto increment call center account number for "HM" accounts

  # @priority-low
  # Scenario: Audit list is available for each user intake row
  #   Given the following user intakes:
  #     | kit_serial_number |
  #     | 11111             |
  #     | 22222             |
  #     | 33333             |
  #   When I am listing user intakes
  #   And I follow "audit_log" for the 1st row
  #   Then I see "Audit Log" for user intake "11111"

  # @priority-low
  # Scenario: Audit row can be viewed detailed
  #   Given the following user intakes:
  #     | kit_serial_number |
  #     | 11111             |
  #   And I am listing audit log for user intake "11111"
  #   And I follow "Details" in the 1st row
  #   Then the page content should have "Detail, 11111"

  # @priority-low
  # Scenario: Audit rows cannot be edited or deleted
  #   Given the following user intakes:
  #     | kit_serial_number |
  #     | 11111             |
  #   And I am at audit log for user intake "11111"
  #   Then page content should not have "edit, delete"
