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
    When I press "Submit"
    When I check "Same as User"
    Then page content should have the following:
    """
    prohibited this user intake from being saved
    First name can't be blank
    Last name can't be blank
    Address can't be blank
    City can't be blank
    State can't be blank
    Zipcode can't be blank
    Home phone or Cell Phone is required
    Cell phone or Home Phone is required
    """
    
  Scenario: Valid user. Subscriber is same as user
    When I check "Same as User"
    And I fill the senior profile details for user intake form
    And I press "Submit"
    Then page content should have "User Intake: Successfully saved"

  Scenario: Valid user. Missing Subscriber. Subscriber is not the user.
    When I uncheck "Same as User"
    And I fill the senior profile details for user intake form
    And I press "Submit"
    Then page content should have "prohibited this"

  Scenario: Valid user. Valid Subscriber. Subscriber is not the user. Subscriber is not caregiver.
    When I uncheck "Same as User"
    And I fill the senior profile details for user intake form
    And I fill the subscriber details for user intake form
    And I select "verizon" from "subscriber_carrier_id"
    And I press "Submit" 
    Then page content should have "User Intake: Successfully saved" 

  Scenario: Valid user. Missing Subscriber/Caregiver. Subscriber is not user. Subscriber is caregiver
    When I uncheck "Same as User"
    And I check "Add as #1 caregiver"
    And I fill the senior profile details for user intake form
    And I press "Submit"
    Then page content should have "prohibited this"

  Scenario: Valid user. Valid Subscriber/Caregiver. Subscriber is not user. Subscriber is caregiver
    When I uncheck "Same as User"
    And I check "Add as #1 caregiver"
    And I fill the senior profile details for user intake form
    And I fill the subscriber details for user intake form
    And I check "sub_roles_users_option_email_active"
    And I select "Yes" from "sub_roles_users_option_is_keyholder"
    And I press "Submit"
    Then page content should have "User Intake: Successfully saved"

  Scenario: Valid user. Valid Subscriber. Subscriber is not user/caregiver. Invalid Caregiver 1.
    When I uncheck "Same as User"
    And I uncheck "Add as #1 caregiver"
    And I fill the senior profile details for user intake form
    And I fill the subscriber details for user intake form
    And I check "sub_roles_users_option_email_active"
    And I select "Yes" from "sub_roles_users_option_is_keyholder"
    And I uncheck "no_caregiver_1"
    And I press "Submit"
    Then page content should have "prohibited this"

  Scenario: Valid user. Valid Subscriber. Valid Caregiver 1. User, Subscriber, Caregiver are separate.
    When I uncheck "Same as User"
    And I uncheck "Add as #1 caregiver"
    And I fill the senior profile details for user intake form
    And I fill the subscriber details for user intake form
    And I check "sub_roles_users_option_email_active"
    And I select "Yes" from "sub_roles_users_option_is_keyholder"
    And I uncheck "no_caregiver_1"
    And I fill the caregiver1 details for user intake form
    And I press "Submit"
    Then page content should have "prohibited this"
