# this feature is not implemented yet
# ticket 2901 needs to be working before this
Feature: User Intake Legal Agreement
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
    And I check "user_intake_no_caregiver_1"
    And I check "user_intake_no_caregiver_2"
    And I check "user_intake_no_caregiver_3"
    # These checkbox steps are required for ruby 1.8.6 bug fix

  Scenario: Submit to reach legal agreement page
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "Submit"
    Then page content should have "successfully created, HALO SUBSCRIBER AGREEMENT"

  Scenario Outline: Only senior or subscriber can see the option to sign the legal agreement
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I press "Submit"
    And I logout
    And I am authenticated as "<user>" of last user intake
    And I view the last user intake
    Then I <status> see "I Agree Terms and Conditions"
    
    Examples:
      | user       | status     |
      | senior     | should     |
      | subscriber | should     |

  Scenario: Users other than senior or subscriber cannot accept the legal agreement
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "Submit"
    Then page content should have "HALO SUBSCRIBER AGREEMENT"
    And I should not see "I Agree Terms and Conditions"

  Scenario: Agreement can be printed
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "Submit"
    And I press "Print"
    Then last user intake should have a print stamp

  Scenario: Senior can sign the agreement successfully
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "Submit"
    And I logout
    And I am authenticated as "senior" of last user intake
    And I view the last user intake
    And I check "userintake_agree"
    And I press "I Agree"
    Then last user intake should have an agreement stamp

  Scenario: User reaches user intake page immediately upon activation
  Scenario: Show timestamp with user intake if already submitted
  Scenario: Anyone other than halouser/subscriber can see link in the user intake form, to agreement PDF
  Scenario: Show legal agreement after submitting user intake successfully, unless already agreed earlier
