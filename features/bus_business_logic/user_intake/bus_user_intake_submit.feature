Feature: Business - user intake - submit
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super_admin

  # Scenario: User Intake gets next status when submitted on current status
  #   Given the following user intakes:
  #     | kit_serial_number |
  #     | 12345             |
  #   When I am listing user intakes
  #   And I edit the 1st row
  #   And I press "user_intake_submit"
  #   Then user intake "12345" has "Ready for Approval" status

  Scenario: Can be edited at any status
    Given I am listing user intakes
    When I edit the 1st row
    Then page source should have xpath "//input[@id='user_intake_submit']"
    
  Scenario: When edited, goes back to approval status
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    And senior of user intake "12345" has "Ready to Bill" status
    And I edit user intake with kit serial "12345"
    And I press "user_intake_submit"
    Then user intake "12345" has "Ready to Bill" status

  Scenario: Can be "saved" at any status
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    When I edit user intake with kit serial "12345"
    And I press "user_intake_save"
    Then I should see "Successfully updated"
    
  # PENDING
  # # merged scenarios
  # # Scenario: Call center account confirmation date is part of dependencies
  # Scenario: While approving, shows all dependencies that are not "green" state
  #   Given the following user_intakes:
  #     | kit_serial_number |
  #     | 12345             |
  #   And senior of user intake "12345" has "Ready for Approval" status
  #   And I edit user intake with kit serial "12345"
  #   Then page content should have "Dependencies:, Call Center Account Confirmation Date"
    
  # PENDING
  # Scenario: "Submit" button when status pending
  #   Given the following user_intakes:
  #     | kit_serial_number |
  #     | 12345             |
  #   And the user intake with kit serial "12345" is not submitted
  #   When I edit user intake with kit serial "12345"
  #   Then page source should have xpath "input[@id='user_intake_submit']"

  # PENDING
  # # scenarios merged
  # # Scenario: Warning "Updates will be sent to SafetyCare" displayed on update
  # # PENDING: "Update"
  # Scenario: "Update" button when already submitted
  #   Given the following user_intakes:
  #     | kit_serial_number |
  #     | 12345             |
  #   When I edit user intake with kit serial "12345"
  #   Then page source should have xpath "input[@id='user_intake_submit']"
    
  Scenario: For only direct_to_consumer group, show warning when clicking "Approve" if there is no ship date
    Given a group "direct_to_consumer" exists
    And the following user intakes:
      | kit_serial_number | group_name         | shipped_at |
      | 12345             | direct_to_consumer |            |
    And senior of user intake "12345" has "Ready for Approval" status
    When I edit user intake with kit serial "12345"
    Then page content should have "Warning, Shipped at"

  Scenario: When the approve button is clicked, disable test mode of user
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    And senior of user intake "12345" has "Ready for Approval" status
    When user intake "12345" is submitted again
    Then senior of user intake "12345" is not in test mode
