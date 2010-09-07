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

  # TODO
  # user intake bug. took quite some time and still not fixed.
  #
  # Scenario: Successfully charged cards link back to User Intake Overview/Summary
  #   Given I am ready to submit a user intake
  #   And I select "bestbuy" from "Group"
  #   And I press "user_intake_submit"
  #   And user "ui-test-user" has "admin" role for group "bestbuy"
  #   And senior of user intake "12345" has low battery
  #   When I go to the triage page
  #   And I select "bestbuy" from "Group"
  #   And I press "Apply selected filters"
  #   And debug
  #   Then page has a link to user intake "12345"
