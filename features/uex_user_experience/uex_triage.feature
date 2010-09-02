Feature: User experience - triage
  In order to value
  As a role
  I want feature

  Scenario: Audit column visible
    When I go to the triage page
    Then page source should have "audit"

  Scenario: Successfully charged cards link back to User Intake Overview/Summary
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    And credit card is charged in user intake "12345"
    Then triage has a link back to user intake "12345"
