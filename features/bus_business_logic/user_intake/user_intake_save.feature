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

  # skipped for 1.6.0 release
  # # https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: New > Save. senior profile blank
  #   When I am creating a user intake
  #   And I select "halo_group" from "group"
  #   And I press "Save"
  #   Then page content should have "successfully saved"

  # https://redmine.corp.halomonitor.com/issues/3598
  Scenario: Edit and save a user intake
    Given the following devices:
      | serial_number |
      | 1234567890    |
    Given the following user_intakes:
      | gateway_serial |
      | 1234567890     |
    When I edit the last user intake
    And I press "Save"
    Then I should see "successfully updated"
    And last user intake should have a senior profile

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: New > Save. user profile ok. subscriber profile blank
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I check "user_intake_caregiver1_email"
    And I check "user_intake_caregiver1_text"
    And I press "Save"
    Then page content should have "successfully saved"
    And last user intake should have a senior profile
    #
    #  Fri Nov 12 18:38:03 IST 2010, ramonrails
    #   * user intake states sheet, H4
    # https://redmine.corp.halomonitor.com/issues/3704
    When I edit the last user intake
    Then checkboxes "user_intake_caregiver1_email, user_intake_caregiver1_text" should be checked

  # https://redmine.corp.halomonitor.com/issues/3170
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
    Then page content should have "successfully saved"

  #
  #  Fri Nov 12 18:38:03 IST 2010, ramonrails
  #   * user intake states sheet, H4
  # https://redmine.corp.halomonitor.com/issues/3704
  # http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=3
  Scenario: New > Save. user profile ok. subscriber not user. caregiver2 given
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I fill the senior details for user intake form
    And I fill the subscriber details for user intake form
    And I fill the caregiver2 details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I uncheck "user_intake_no_caregiver_2"
    And I check "user_intake_caregiver1_email"
    And I check "user_intake_caregiver1_text"
    And I check "user_intake_caregiver2_email"
    And I check "user_intake_caregiver2_text"
    And I press "Save"
    Then page content should have "successfully saved"
    And last user intake should have a senior profile
    When I edit the last user intake
    Then checkboxes "user_intake_caregiver1_email, user_intake_caregiver1_text" should be checked
    # And page content should have "caregiver2 first name, caregiver2 last name"
    And caregivers of last user intake should be away
  
  # 
  #  Sat Nov 13 00:43:56 IST 2010, ramonrails
  #   * user intake states sheet, H4
  # https://redmine.corp.halomonitor.com/issues/3704
  # http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=3
  Scenario: Devices are attached appropriately to user intake
    Given the product catalog exists
    And the following devices:
      | serial_number |
      | H200112233    |
      | H500445566    |
    When I create a "reseller" group
    And I am creating a user intake
    And I select "reseller_group" from "group"
    And I fill the senior details for user intake form
    And I fill in the following:
      | Gateway Serial     | H200112233      |
      | Transmitter Serial | H500445566      |
    And I press "Save"
    Then last user intake should have devices attached
    