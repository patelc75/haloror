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
    And user "test-user" has "super admin, caregiver" roles
    And I am on new user_intake page
    When I select "halo_group" from "group"
    # These checkbox steps are required for ruby 1.8.6 bug fix
    And I check "no_caregiver_1"
    And I check "no_caregiver_2"
    And I check "no_caregiver_3"
        
  Scenario: Validation errors for all fields
    When I press "Submit"
    Then page content should have the following:
    """
    errors prohibited this profile from being saved
    First name can't be blank
    Last name can't be blank
    Address can't be blank
    City can't be blank
    State can't be blank
    Zipcode can't be blank
    Home phone or Cell Phone is required
    Cell phone or Home Phone is required
    """
    
  # Scenario: All valid data. No errors.
  #   When I uncheck "no_caregiver_1"
  #   And I fill in the following:
  #     | user_first_name | myfirstname             |
  #     # | user_last_name  | mylastname              |
  #     # | user_address    | 110, Madison Ave, NY    |
  #     # | user_cross_st   | Street 42               |
  #     # | user_city       | NY                      |
  #     # | user_state      | NY                      |
  #     # | user_zipcode    | 12201                   |
  #     # | user_home_phone | 1-517-123-4567          |
  #     # | user_cell_phone | 1-917-123-4567          |
  #     # | user_work_phone | 1-212-123-4567          |
  #     # | users_email     | cuc_senior@chirag.name  |
  #   # And I select "verizon" from "user_carrier_id"
  #   # And I select "1 Nov 2000" as the "Date of Birth" date
  #   # And I choose "user_sex_m"
  #   Then page content should have "Thank you"
