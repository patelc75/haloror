@user_intake
Feature: Business - user intake - submit
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
    And the following devices:
      | serial_number |
      | H200120023    |

  # Scenario: User Intake gets next status when submitted on current status
  #   Given the following user intakes:
  #     | gateway_serial |
  #     | H200120023             |
  #   When I am listing user intakes
  #   And I edit the 1st row
  #   And I press "user_intake_submit"
  #   Then user intake "H200120023" has "Ready for Approval" status

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
  #     | H200120023             |
  #   And senior of user intake "H200120023" has "Ready to Bill" status
  #   And I edit user intake with gateway serial "H200120023"
  #   And I press "user_intake_submit"
  #   Then user intake "H200120023" has "Ready to Bill" status

  # # @priority-low
  # #
  # Scenario: Can be "saved" at any status
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | H200120023             |
  #   When I edit user intake with gateway serial "H200120023"
  #   And I press "user_intake_save"
  #   Then I should see "Successfully updated"
    
  # PENDING
  # # merged scenarios
  # # Scenario: Call center account confirmation date is part of dependencies
  # Scenario: While approving, shows all dependencies that are not "green" state
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | H200120023             |
  #   And senior of user intake "H200120023" has "Ready for Approval" status
  #   And I edit user intake with gateway serial "H200120023"
  #   Then page content should have "Dependencies:, Call Center Account Confirmation Date"
    
  # PENDING
  # Scenario: "Submit" button when status pending
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | H200120023             |
  #   And the user intake "H200120023" is not submitted
  #   When I edit user intake with gateway serial "H200120023"
  #   Then page source should have xpath "input[@id='user_intake_submit']"

  # PENDING
  # # scenarios merged
  # # Scenario: Warning "Updates will be sent to SafetyCare" displayed on update
  # # PENDING: "Update"
  # Scenario: "Update" button when already submitted
  #   Given the following user_intakes:
  #     | gateway_serial |
  #     | H200120023             |
  #   When I edit user intake with gateway serial "H200120023"
  #   Then page source should have xpath "input[@id='user_intake_submit']"
    
  Scenario: For only direct_to_consumer group, show warning when clicking "Approve" if there is no ship date
    Given a group "direct_to_consumer" exists
    And the following user intakes:
      | gateway_serial | group_name         |
      | H200120023     | direct_to_consumer |
    And senior of user intake "H200120023" has "Ready for Approval" status
    When I edit user intake with gateway serial "H200120023"
    Then page content should have "Warning, Shipped at"

  Scenario: When the approve button is clicked, partially disable test mode of user
    Given the following user intakes:
      | gateway_serial |
      | H200120023     |
    And senior of user intake "H200120023" has "Ready for Approval" status
    And I am editing user intake "H200120023"
    # Login as super_admin, click “Approve” button on user intake form, and verify “Ready to Install” state
    When I press "Approve"
    Then senior of user intake "H200120023" is in test mode
    And senior of user intake "H200120023" is halouser of safety care group
    And caregivers of user intake "H200120023" are away
    And senior of last user intake should have "Ready to Install" state
    # Verify “Opt out of live call center” is un-checked, but caregivers are still away at Config > Users > (pick row) > Caregivers
    And senior of last user intake should not be opted out of call center
    And caregivers of last user intake should be away
    # Press panic button (or cURL if hardware not available) and verify “Ready to Bill” state
    When panic button test data is received for user intake "H200120023"
    And senior of last user intake should have "Ready to Bill" state
    # As super_admin, click the "Bill" button on user intake form and verify “Installed” state
    When I edit the last user intake
    And I press "Bill"
    And senior of last user intake should have "Installed" state
    # Verify 3 transactions (upfront, prorate, recurring) at My Links > Reporting > Online Store Orders
    When I visit "/payment_gateway_responses"
    Then page content should have "purchase, prorate, recurring"
    # Verify caregivers are active at Config > Users > (pick row) > Caregivers
    And caregivers of last user intake should not be away

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
