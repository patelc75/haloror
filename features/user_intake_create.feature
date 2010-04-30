Feature: Create user intake
  In order to value
  As a role
  I want feature

  Background: Authenticated user with basic data
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name       |
      | halo_group |
    And the following carriers:
      | name    |
      | verizon |
    And user "test-user" has "super admin, caregiver" roles
    When I am creating a user intake
    And I select "halo_group" from "group"
    # These checkbox steps are required for ruby 1.8.6 bug fix
    And I check "user_intake_no_caregiver_1"
    And I check "user_intake_no_caregiver_2"
    And I check "user_intake_no_caregiver_3"

  Scenario: Submit. senior profile blank
    And I press "Submit"
    Then page content should have "Invalid user intake"

  Scenario: Submit. user profile ok. subscriber = user
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "Submit"
    Then page content should have "successfully created"

  Scenario: Submit. user profile ok. subscriber not user. subscriber profile blank
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I press "Submit"
    Then page content should have "Invalid user intake"

  Scenario: Submit. user profile ok. subscriber not user. subscriber profile ok
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    When I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I press "Submit"
    Then page content should have "successfully created"

  Scenario: Submit. user profile ok. subscriber not user. subscriber = caregiver1
  Scenario: Submit. user profile ok. subscriber profile ok. different caregiver1 with blank profile
  Scenario: Submit. user profile ok. subscriber profile ok. different caregiver1 with ok profile
  Scenario: Submit. user profile ok. subscriber profile ok. different caregiver 1, 2, 3
