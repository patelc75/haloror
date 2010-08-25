Feature: User intake additions
  In order to value
  As a role
  I want feature

  Background: Authenticated user
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name       |
      | halo_group |
      | group 1    |
    And the following carriers:
      | name    |
      | verizon |
    And user "test-user" has "super admin" roles
    And I am on new user_intake page
    When I select "halo_group" from "group"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    # These checkbox steps are required for ruby 1.8.6 bug fix
    And I check "user_intake_no_caregiver_1"
    And I check "user_intake_no_caregiver_2"
    And I check "user_intake_no_caregiver_3"
    And the product catalog exists
  
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  @wip
  Scenario: fields visible for senior
    When I create a new user_intake
    Then I should see "Cross St" for "senior_profile"
    And I should not see "Cross St" for "senior_profile"
    And I should see "VoIP (Voice over IP) phone?" for "senior_profile"
    And page content should have "I agree to the terms, you acknowledge that you are, Halo Subscriber Agreement"
  
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Auto enable credit card radio button
    Given the following user intakes:
      | kit_serial_number | submitted_at |
      | 1122334455        |              |
    Then "card" should be enabled for subscriber of user intake "1122334455"
    And "created_by" for user_intake "1122334455" should be assigned
  
  # # What is this supposed to cover?
  # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: User Intake List updates
  #   When I am listing user intakes
  #   Then I should see "Subscription Agreement"
  
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Group dropdown to shortlist user intake list
    Given the following user intakes:
      | kit_serial_number | submitted_at |
      | 1122334455        |              |
    And the following groups:
      | name   |
      | group1 |
    And user intake "1122334455" belongs to group "group1"
    When I am listing user intakes
    And I select "group1" from "Group"
    And I press "user_intake_search"
    Then I should see "1122334455"

  # TODO: What should be covered here?
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Email to safety_care
  #   When I am listing user intakes
  #   And I press "email_safety_care"
  #   And 1 email to "safety_care" with subject "caregiver details" should be sent for delivery
