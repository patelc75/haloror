Feature: User intake parts
  In order to make sure user intake works completely
  As a user
  I want all individual sections and parts of user intake tested

  Background:
    Given I am an authenticated super admin
    And a group "mygroup" exists
    And the following devices:
      | serial_number |
      | H234567890    |
  
  # Scenario: Test mode checkboxes put all caregivers away
  @user_intake
  Scenario: Test mode checkboxes put senior in test mode, not member of safety_care
    Given the following user intakes:
      | gateway_serial |
      | H234567890     |
    When I bring senior of user intake "H234567890" into test mode
    Then senior of user intake "H234567890" should not be a member of "safety_care" group
    And caregivers should be away for user intake "H234567890"
    And user intake "H234567890" senior should have "test_mode" flag ON

  # Thu Sep 23 23:03:40 IST 2010
  # DEPRECTAED
  #   https://redmine.corp.halomonitor.com/issues/3461#note-18
  #   This scenario is not required
  # Scenario: "Test Mode" checkbox should be checked by default
  #   Given I am creating a user intake
  #   When I select "mygroup" from "user_intake_group_id"
  #   Then "Test Mode" checkbox must be checked
  
  # @priority-low
  # Scenario: Billing date shows as "Desired" billing date
  #   Given I am listing user intakes
  #   Then page content has "Desired Billing Date"

  # FIXME: ui changed? confirm from Chirag
  # Scenario: Verify Manual Billing is checked in the user intake form, then Credit Card column is blank
  #   Given I am ready to submit a user intake
  #   When I choose "Manual Billing"
  #   And I press "user_intake_submit"
  #   Then last user intake should not have credit card value
  #   And last user intake should have bill monthly value

  # @user_intake
  # Scenario: Validation: "Desired Installation Date" must be 48 hours after submitted_at
  #   Given I am ready to submit a user intake
  #   When I press "user_intake_submit"
  #   Then "installation_datetime" for last user intake should be 48 hours after "submitted_at"
    
  # @user_intake
  # Scenario: "Desired Installation Date" should auto-fill to order date + 7.days for direct_to_consumer group
  #   Given a group "direct_to_consumer" exists
  #   And I am ready to submit a user intake
  #   When I select "direct_to_consumer" from "Group"
  #   And I press "user_intake_submit"
  #   Then "installation_datetime" for last user intake should be 7 days after "submitted_at"
