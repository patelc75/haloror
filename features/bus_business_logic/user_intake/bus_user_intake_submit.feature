Feature: Business - user intake - submit
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super_admin

  Scenario: User Intake gets next status when submitted on current status
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    When I am listing user intakes
    And I edit the 1st row
    And I press "user_intake_submit"
    Then user intake "12345" has status "Ready for Approval"

  Scenario: Can be edited at any status
    Given I am listing user intakes
    When I edit the 1st row
    Then page source has "user_intake_submit"
    
  Scenario: When edited, goes back to approval status
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    And senior of user intake "12345" has "Ready to Bill" status
    And I edit user intake with kit serial "12345"
    And I press "user_intake_submit"
    Then user intake "12345" has "Ready for Approval" status

  Scenario: Can be "saved" at any status
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    When I edit user intake with kit serial "12345"
    And I press "user_intake_save"
    Then I should see "Successfully saved"
    
  # merged scenarios
  # Scenario: Call center account confirmation date is part of dependencies
  Scenario: While approving, shows all dependencies that are not "green" state
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    And senior of user intake "12345" has "Ready for Approval" status
    And I edit user intake with kit serial "12345"
    Then page content should have "Dependencies:, Call Center Account Confirmation Date"
    
  Scenario: "Submit" button when status pending
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    And the user intake with kit serial "12345" is not submitted
    When I edit user intake with kit serial "12345"
    Then page content has "Submit"

  # scenarios merged
  # Scenario: Warning "Updates will be sent to SafetyCare" displayed on update
  Scenario: "Update" button when already submitted
    Given the following user_intakes:
      | kit_serial_number |
      | 12345             |
    When I edit user intake with kit serial "12345"
    Then page content has "Update"
    
  Scenario: For only direct_to_consumer group, show warning when clicking "Approve" if there is no ship date
    Given a group "direct_to_consumer" exists
    And the following user intakes:
      | kit_serial_number |
      | 12345             |
    And user intake "12345" belongs to group "direct_to_consumer"
    And user intake "12345" does not have the product shipped yet
    And senior of user intake "12345" has "Ready for Approval" status
    When I edit user intake with kit serial "12345"
    Then page content has "Warning:, shipping date"

  Scenario: When the approve button is clicked, disable test mode of user
    Given the following user intakes:
      | kit_serial_number |
      | 12345             |
    And senior of user intake "12345" is in test mode
    And senior of user intake "12345" has "Ready for Approval" status
    When I edit user intake with kit serial "12345"
    And I press "user_intake_submit"
    Then senior of user intake "12345" is not in test mode
