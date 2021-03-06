@user_intake
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
    And I press "user_intake_submit"
    Then page content should have "Invalid user intake"

  # https://redmine.corp.halomonitor.com/issues/3497
  Scenario: Submit with validation error, then re-submit
    When I fill in "user_intake_senior_attributes_email" with ""
    And I press "user_intake_submit"
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I press "user_intake_submit"
    Then page content should have "Invalid user intake"
  
  # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # #   * check for demo_mode and vip toggles
  # Scenario: Submit. user profile ok. subscriber = user
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I check "user_intake_subscriber_is_user"
  #   And I check "user_intake_senior_attributes_demo_mode"
  #   And I check "user_intake_senior_attributes_vip"
  #   And I press "user_intake_submit"
  #   Then page content should have "successfully created"
  #   And last user intake should not have caregivers
  #   And senior of last user intake should be in demo mode
  #   And senior of last user intake should be in vip mode

    # skipped for 1.6.0 release
  # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Submit. user profile ok. subscriber not user. subscriber profile blank
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I uncheck "Same as User"
  #   And I press "user_intake_submit"
  #   Then page content should have "Invalid user intake"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Submit. user profile ok. subscriber not user. subscriber profile ok
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    Then page content should have "successfully created"
    And last user intake should have separate senior and subscriber
    And users of last user intake should have appropriate roles
    And users of last user intake should have valid emails
    And 2 users should be associated to last user intake
    
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Submit. user profile ok. subscriber not user. subscriber = caregiver1
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I check "Add as #1 Caregiver"
    And I press "user_intake_submit"
    Then page content should have "successfully created"
    And last user intake should have separate senior and subscriber
    And last user intake should have same subscriber and caregiver1
    And users of last user intake should have appropriate roles
    And users of last user intake should have valid emails
    And 2 users should be associated to last user intake

  # # @priority-low
  # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # #   This saves with a blank caregiver! Need to fix
  # Scenario: Submit. user profile ok. subscriber profile ok. different caregiver1 with blank profile
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I uncheck "Same as User"
  #   And I fill the subscriber details for user intake form
  #   And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
  #   And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
  #   And I uncheck "Add as #1 Caregiver"
  #   And I uncheck "No Caregiver #1"
  #   And I press "user_intake_submit"
  #   Then page content should have "Invalid user intake"
    
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Submit. user profile ok. subscriber profile ok. different caregiver1 with ok profile
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I uncheck "Add as #1 Caregiver"
    And I uncheck "Uncheck to add Caregiver #1"
    And I fill the caregiver1 details for user intake form
    And I fill in "user_intake_caregiver1_attributes_email" with "caregiver1@example.com"
    And I select "verizon" from "user_intake_caregiver1_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    Then page content should have "successfully created"
    
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Submit. user profile ok. subscriber profile ok. different caregiver 1, 2, 3
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I uncheck "Add as #1 Caregiver"
    And I uncheck "Uncheck to add Caregiver #1"
    And I fill the caregiver1 details for user intake form
    And I fill in "user_intake_caregiver1_attributes_email" with "caregiver1@example.com"
    And I select "verizon" from "user_intake_caregiver1_attributes__profile_attributes_carrier_id"
    And I uncheck "Uncheck to add Caregiver #2"
    And I fill the caregiver2 details for user intake form
    And I fill in "user_intake_caregiver2_attributes_email" with "caregiver2@example.com"
    And I select "verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I uncheck "Uncheck to add Caregiver #3"
    And I fill the caregiver3 details for user intake form
    And I fill in "user_intake_caregiver3_attributes_email" with "caregiver3@example.com"
    And I select "verizon" from "user_intake_caregiver3_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    Then page content should have "successfully created"
