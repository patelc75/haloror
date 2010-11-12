Feature: Business - user intake - submit
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin

  # Scenario: User Intake gets next status when submitted on current status
  #   Given the following user intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   When I am listing user intakes
  #   And I edit the 1st row
  #   And I press "user_intake_submit"
  #   Then user intake "1234567890" has "Ready for Approval" status

  # CHANGED : OBSOLETE
  #
  # Scenario: Can be edited at any status
  #   Given I am listing user intakes
  #   When I edit the 1st row
  #   Then page source should have xpath "//input[@id='user_intake_submit']"
    
  # CHANGED : OBSOLETE
  #
  # Scenario: When edited, goes back to approval status
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   And senior of user intake "1234567890" has "Ready to Bill" status
  #   And I edit user intake with gateway serial "1234567890"
  #   And I press "user_intake_submit"
  #   Then user intake "1234567890" has "Ready to Bill" status

  # # @priority-low
  # #
  # Scenario: Can be "saved" at any status
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   When I edit user intake with gateway serial "1234567890"
  #   And I press "user_intake_save"
  #   Then I should see "Successfully updated"
    
  # PENDING
  # # merged scenarios
  # # Scenario: Call center account confirmation date is part of dependencies
  # Scenario: While approving, shows all dependencies that are not "green" state
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   And senior of user intake "1234567890" has "Ready for Approval" status
  #   And I edit user intake with gateway serial "1234567890"
  #   Then page content should have "Dependencies:, Call Center Account Confirmation Date"
    
  # PENDING
  # Scenario: "Submit" button when status pending
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   And the user intake "1234567890" is not submitted
  #   When I edit user intake with gateway serial "1234567890"
  #   Then page source should have xpath "input[@id='user_intake_submit']"

  # PENDING
  # # scenarios merged
  # # Scenario: Warning "Updates will be sent to SafetyCare" displayed on update
  # # PENDING: "Update"
  # Scenario: "Update" button when already submitted
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | 1234567890             |
  #   When I edit user intake with gateway serial "1234567890"
  #   Then page source should have xpath "input[@id='user_intake_submit']"
    
  Scenario: For only direct_to_consumer group, show warning when clicking "Approve" if there is no ship date
    Given a group "direct_to_consumer" exists
    And the following user intakes:
      | gateway_serial | group_name         | shipped_at |
      | 1234567890     | direct_to_consumer |            |
    And senior of user intake "1234567890" has "Ready for Approval" status
    When I edit user intake with gateway serial "1234567890"
    Then page content should have "Warning, Shipped at"

  Scenario: When the approve button is clicked, partially disable test mode of user
    Given the following user intakes:
      | gateway_serial |
      | 1234567890     |
    And senior of user intake "1234567890" has "Ready for Approval" status
    And I am editing user intake "1234567890"
    When I press "Approve"
    Then senior of user intake "1234567890" is in test mode
    And senior of user intake "1234567890" is halouser of safety care group
    And caregivers of user intake "1234567890" are away

  Scenario: When creating a user intake with device serials, devices are attached once only
    Given the following devices:
      | serial_number |
      | H200000060    |
      | H100000040    |
    And I am ready to submit a user intake
    And I fill in the following:
      | user_intake_gateway_serial     | H200000060 |
      | user_intake_transmitter_serial | H100000040 |
    And I press "Submit"
    Then senior of user intake "H200000060" should have 2 devices
