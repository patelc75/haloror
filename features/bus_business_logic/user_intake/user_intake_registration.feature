Feature: Manage user_intakes
  In order manage user intakes
  As an administrator
  I want to provide an interface for user signup
  
  Background: Authenticated user
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name       |
      | halo_group |
    And the following carriers:
      | name    |
      | verizon |
    And user "test-user" has "super admin, caregiver" roles
    And I am on new user_intake page
    When I select "halo_group" from "group"
    And I fill in the following:
      | user_intake_senior_attributes__profile_attributes_first_name | myfirstname            |
      | user_intake_senior_attributes__profile_attributes_last_name  | mylastname             |
      | user_intake_senior_attributes__profile_attributes_address    | 110, Madison Ave, NY   |
      | user_intake_senior_attributes__profile_attributes_cross_st   | Street 42              |
      | user_intake_senior_attributes__profile_attributes_city       | NY                     |
      | user_intake_senior_attributes__profile_attributes_state      | NY                     |
      | user_intake_senior_attributes__profile_attributes_zipcode    | 12201                  |
      | user_intake_senior_attributes__profile_attributes_home_phone | 1-517-123-4567         |
      | user_intake_senior_attributes__profile_attributes_cell_phone | 1-917-123-4567         |
      | user_intake_senior_attributes__profile_attributes_work_phone | 1-212-123-4567         |
      | user_intake_senior_attributes_email                          | cuc_senior@chirag.name |
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I choose "user_intake_senior_attributes__profile_attributes_sex_m"
    And I check "user_intake_no_caregiver_1"
    And I check "user_intake_no_caregiver_2"
    And I check "user_intake_no_caregiver_3"
        
  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Submit new user_intake with billing same as user
    When I check "Same as User"
    And I uncheck "Add as #1 caregiver"
    And I press "user_intake_submit"
    Then users of last user intake should have appropriate roles
    And 1 email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery

  # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # # This has a few HTML element IDs instead of visible text, due to a bug in webrat
  # # possible fix:
  # #   1. fix webrat ourselves. do you really want to invest time into this?
  # #   2. use capybara. requires rails 2.3. is the server compatible? can we shift to apache/mod_rails?
  # #   3. keep using HTML element IDs
  # #
  @wip
  Scenario: Submit new user_intake with billing same as #1 caregiver
    When I uncheck "Same as User"
    And I check "Add as #1 caregiver" 
    And I check "user_intake_mem_caregiver1_options_email_active"
    And I select "Yes" from "user_intake_mem_caregiver1_options_is_keyholder"
    And I fill in the following:
      | user_intake_subscriber_attributes__profile_attributes_first_name | subscriberfirstname      |
      | user_intake_subscriber_attributes__profile_attributes_last_name  | subscriberlastname       |
      | user_intake_subscriber_attributes__profile_attributes_address    | 110, Madison Ave, NY     |
      | user_intake_subscriber_attributes__profile_attributes_city       | NY                       |
      | user_intake_subscriber_attributes__profile_attributes_state      | NY                       |
      | user_intake_subscriber_attributes__profile_attributes_zipcode    | 12201                    |
      | user_intake_subscriber_attributes__profile_attributes_home_phone | 1-517-123-4567           |
      | user_intake_subscriber_attributes__profile_attributes_work_phone | 1-212-123-4567           |
      | user_intake_subscriber_attributes_email                          | cuc_sub_care@chirag.name |
    And I press "user_intake_submit"
    Then profile "myfirstname mylastname" should have "halouser" role for group "halo_group"
    And profile "subscriberfirstname subscriberlastname" should have "subscriber" role for profile "myfirstname mylastname"
    And profile "subscriberfirstname subscriberlastname" should have "caregiver" role for profile "myfirstname mylastname" with attributes:
     | email_active | true |
     | position     | 1    |
     | is_keyholder | true |
  # TODO: 1.6.0. skipped for QA release
  # And 1 email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery
