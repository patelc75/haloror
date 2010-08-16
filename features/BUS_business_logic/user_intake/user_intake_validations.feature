Feature: Manage user_intakes
  In order keep the application user friendly
  As an authenticated user
  I want to make user validations without exceptions
  
  Background: Authenticated user
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name       |
      | halo_group |
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
        
  Scenario: Validation errors for senior profile
    When I check "Same as User"
    And I press "Submit"
    Then page content should have "Invalid user intake"
    
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Subscriber is same as user
  #   When I check "Same as User"
  #   And I fill the senior details for user intake form
  #   And I press "Submit"
  #   Then page content should have "successfully created"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Missing Subscriber. Subscriber is not the user.
  #   When I uncheck "Same as User"
  #   And I fill the senior details for user intake form
  #   And I press "Submit"
  #   Then page content should have "Invalid user intake"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Valid Subscriber. Subscriber is not the user. Subscriber is not caregiver.
  #   When I uncheck "Same as User"
  #   And I fill the senior details for user intake form
  #   And I fill the subscriber details for user intake form
  #   And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
  #   And I press "Submit" 
  #   Then page content should have "successfully created" 

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Missing Subscriber/Caregiver. Subscriber is not user. Subscriber is caregiver
  #   When I uncheck "Same as User"
  #   And I check "Add as #1 caregiver"
  #   And I fill the senior details for user intake form
  #   And I press "Submit"
  #   Then page content should have "Invalid user intake"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Valid Subscriber/Caregiver. Subscriber is not user. Subscriber is caregiver
  #   When I uncheck "Same as User"
  #   And I check "Add as #1 caregiver"
  #   And I fill the senior details for user intake form
  #   And I fill the subscriber details for user intake form
  #   And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
  #   And I check "user_intake_mem_caregiver1_options_email_active"
  #   And I select "Yes" from "user_intake_mem_caregiver1_options_is_keyholder"
  #   And I press "Submit"
  #   Then page content should have "successfully created"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Valid Subscriber. Subscriber is not user/caregiver. Invalid Caregiver 1.
  #   When I uncheck "Same as User"
  #   And I uncheck "Add as #1 caregiver"
  #   And I fill the senior details for user intake form
  #   And I fill the subscriber details for user intake form
  #   And I check "user_intake_mem_caregiver1_options_email_active"
  #   And I select "Yes" from "user_intake_mem_caregiver1_options_is_keyholder"
  #   And I uncheck "user_intake_no_caregiver_1"
  #   And I press "Submit"
  #   Then page content should have "Invalid user intake"

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Valid user. Valid Subscriber. Valid Caregiver 1. User, Subscriber, Caregiver are separate.
  #   When I uncheck "Same as User"
  #   And I uncheck "Add as #1 caregiver"
  #   And I fill the senior details for user intake form
  #   And I fill the subscriber details for user intake form
  #   And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
  #   And I check "user_intake_mem_caregiver1_options_email_active"
  #   And I select "Yes" from "user_intake_mem_caregiver1_options_is_keyholder"
  #   And I uncheck "user_intake_no_caregiver_1"
  #   And I fill the caregiver1 details for user intake form
  #   And I select "verizon" from "user_intake_caregiver1_attributes__profile_attributes_carrier_id"
  #   And I press "Submit"
  #   And debug
  #   Then page content should have "successfully created"
