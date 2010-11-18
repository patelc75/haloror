Feature: Bus user intake relations
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
  
  Scenario: All new user intakes get audit logged
    Given I am ready to submit a user intake
    When I press "user_intake_submit"
    Then the last user intake should have an audit log

  Scenario: All changes to user intake get audit logged
    Given the following user intakes:
      | gateway_serial |
      | H234567890     |
    When I update gateway serial for user intake "H234567890" to "H234567891"
    Then the last user intake should have a recent audit log

  Scenario: Any change to status gets logged to triage audit log
    Given the following user intakes:
      | gateway_serial |
      | H234567890     |
    When user intake "H234567890" is submitted again
    Then the last user intake should have a recent audit log

  Scenario: Auto increment call center account number for "HM" accounts

  # @priority-low
  # Scenario: Audit list is available for each user intake row
  #   Given the following user intakes:
  #     | gateway_serial |
  #     | H234567890        |
  #     | H234567891    |
  #     | H234567892    |
  #   When I am listing user intakes
  #   And I follow "audit_log" for the 1st row
  #   Then I see "Audit Log" for user intake "11111"

  # @priority-low
  # Scenario: Audit row can be viewed detailed
  #   Given the following user intakes:
  #     | gateway_serial |
  #     | 11111             |
  #   And I am listing audit log for user intake "11111"
  #   And I follow "Details" in the 1st row
  #   Then the page content should have "Detail, 11111"

  # @priority-low
  # Scenario: Audit rows cannot be edited or deleted
  #   Given the following user intakes:
  #     | gateway_serial |
  #     | 11111             |
  #   And I am at audit log for user intake "11111"
  #   Then page content should not have "edit, delete"
