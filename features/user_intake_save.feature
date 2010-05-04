Feature: Save User Intake
  In order allow users to save user intake and edit it later
  As a 
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

  Scenario: New > Save. senior profile blank
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I press "Save"
    Then page content should have "successfully created"

  Scenario: New > Save. user profile ok. subscriber not user. subscriber profile blank
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I press "Save"
    Then page content should have "successfully created"

  Scenario: New > Save. user profile ok. subscriber profile ok. different caregiver1 with blank profile
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I uncheck "Add as #1 Caregiver"
    And I uncheck "No Caregiver #1"
    And I press "Save"
    Then page content should have "successfully created"
