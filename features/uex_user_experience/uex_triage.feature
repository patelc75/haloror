Feature: User experience - triage
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super_admin
    And a group "bestbuy" exists

  Scenario: Audit column visible
    When I go to the triage page
    Then page source has xpath "//th[@id='audit_column']"

  Scenario: Successfully charged cards link back to User Intake Overview/Summary
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    And credit card is charged in user intake "12345"
    And user intake "12345" belongs to group "bestbuy"
    And senior of user intake "12345" has low battery
    When I go to the triage page
    And I select "bestbuy" from "Group"
    And I press "Apply selected filters"
    And debug
    Then page has a link to user intake "12345"
