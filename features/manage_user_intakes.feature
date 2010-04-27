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
      | user_intake_senior_attributes__profile_attributes_first_name | myfirstname             |
      | user_intake_senior_attributes__profile_attributes_last_name  | mylastname              |
      | user_intake_senior_attributes__profile_attributes_address    | 110, Madison Ave, NY    |
      | user_intake_senior_attributes__profile_attributes_cross_st   | Street 42               |
      | user_intake_senior_attributes__profile_attributes_city       | NY                      |
      | user_intake_senior_attributes__profile_attributes_state      | NY                      |
      | user_intake_senior_attributes__profile_attributes_zipcode    | 12201                   |
      | user_intake_senior_attributes__profile_attributes_home_phone | 1-517-123-4567          |
      | user_intake_senior_attributes__profile_attributes_cell_phone | 1-917-123-4567          |
      | user_intake_senior_attributes__profile_attributes_work_phone | 1-212-123-4567          |
      | user_intake_senior_attributes__profile_attributes_email      | cuc_senior@chirag.name  |
    And I select "verizon" from "user_profile_carrier_id"
    And I select "1 Nov 2000" as the "Date of Birth" date
    And I choose "user_profile_sex_m"
    And I check "no_caregiver_1"
    And I check "no_caregiver_2"
    And I check "no_caregiver_3"
        
  Scenario: Submit new user_intake with billing same as user
    When I check "same_as_user"
    And I uncheck "Add as #1 caregiver"
    And I press "Submit"
    Then profile "myfirstname mylastname" should have "halouser" role
    And profile "myfirstname mylastname" should have "subscriber" role for profile "myfirstname mylastname"
    And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery

  # This has a few HTML element IDs instead of visible text, due to a bug in webrat
  # possible fix:
  #   1. fix webrat ourselves. do you really want to invest time into this?
  #   2. user capybara. requires rails 2.3. is the server compatible? can we shift to apache/mod_rails?
  #   3. keep using HTML element IDs
  #
  Scenario: Submit new user_intake with billing same as #1 caregiver
    When I uncheck "same_as_user"
    And I check "Add as #1 caregiver" 
    And I check "sub_roles_users_option_email_active"
    And I select "Yes" from "sub_roles_users_option_is_keyholder"
    And I fill in the following:
      | subscriber_first_name | subscriberfirstname         |
      | subscriber_last_name  | subscriberlastname          |
      | subscriber_address    | 110, Madison Ave, NY        |
      | subscriber_city       | NY                          |
      | subscriber_state      | NY                          |
      | subscriber_zipcode    | 12201                       |
      | subscriber_home_phone | 1-517-123-4567              |
      | subscriber_work_phone | 1-212-123-4567              |
      | subscriber_email      | cuc_sub_care@chirag.name    |
    And I press "Submit"
    Then profile "myfirstname mylastname" should have "halouser" role
    And profile "subscriberfirstname subscriberlastname" should have "subscriber" role for profile "myfirstname mylastname"
    And profile "subscriberfirstname subscriberlastname" should have "caregiver" role for profile "myfirstname mylastname" with attributes:
     | email_active | true |
     | position     | 1    |
     | is_keyholder | true |
	And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be sent for delivery
	#And email to "cuc_sub_care@chirag.name" with subject "Please read before your installation" should be sent for delivery	