# this feature is not implemented yet
# ticket 2901 needs to be working before this
@user_intake
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

  # Tue Oct 26 03:39:28 IST 2010
  #   Logic has been changed to show success / failure page after order
  # # WARNING: Code coverage required : https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Submit to reach legal agreement page
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I check "Same as User"
  #   And I press "user_intake_submit"
  #   Then page content should have "successfully created, HALO SUBSCRIBER AGREEMENT"

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: Only senior or subscriber can see the option to sign the legal agreement
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I fill the subscriber details for user intake form
    And I fill in "user_intake_subscriber_attributes_email" with "subscriber@example.com"
    And I select "verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I uncheck "Same as User"
    And I press "user_intake_submit"
    And I logout
    And I activate and login as the senior of last user intake
    And I view the last user intake
    Then I <status> see "I Agree Terms and Conditions"
    
    Examples:
      | user       | status     |
      | senior     | should     |
      | subscriber | should     |

  # Tue Oct 26 03:39:28 IST 2010
  #   Logic has been changed to show success / failure page after order
  # # https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Users other than senior or subscriber cannot accept the legal agreement
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I check "Same as User"
  #   And I press "user_intake_submit"
  #   Then page content should have "HALO SUBSCRIBER AGREEMENT"
  #   And I should not see "I Agree Terms and Conditions"

  # Tue Oct 26 03:39:28 IST 2010
  #   Logic has been changed to show success / failure page after order
  # # https://redmine.corp.halomonitor.com/issues/3170
  # Scenario: Agreement can be printed
  #   When I fill the senior details for user intake form
  #   And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
  #   And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
  #   And I check "Same as User"
  #   And I press "user_intake_submit"
  #   And I press "Print"
  #   Then last user intake should have a print stamp

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Senior can sign the agreement successfully
    When I fill the senior details for user intake form
    And I fill in "user_intake_senior_attributes_email" with "senior@example.com"
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I check "Same as User"
    And I press "user_intake_submit"
    And I logout
    And I am activating the "senior" of last user intake
    And I fill in the following:
      | user_login                 | myhalouser |
      | user_password              | 12345      |
      | user_password_confirmation | 12345      |
    And I press "subscribe_button"
    And I login as "myhalouser" with password "12345"
    And I view the last user intake
    And I check "userintake_agree"
    And I press "user_intake_submit"
    Then last user intake should have an agreement stamp

  # # TODO: skipped for release 1.6.0
  # # https://redmine.corp.halomonitor.com/issues/3170
  # # user reaches the following immediately after activation of account
  # #   user_intake form was not complete => edit user intake form
  # #   user intake was complete but legal agreement not signed yet => legal agreement with option to accept
  # Scenario Outline: User reaches legal agreement or user intake page appropriately upon activation
  #   Given I have a <state> user intake
  #   And I logout
  #   And the "senior" of last user intake is not activated
  #   And I am activating the "senior" of last user intake
  #   When I fill in the following:
  #     | user_login                 | senior-login |
  #     | user_password              | password     |
  #     | user_password_confirmation | password     |
  #   And I press "subscribe_button"
  #   Then I should see "<text>"
  #   
  #   Examples:
  #     | state      | text                           |
  #     | non-agreed | HALO SUBSCRIBER AGREEMENT      |
  #     | saved      | Edit : myHalo User Intake Form |
  
  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Show timestamp with user intake if already submitted
    Given I have a complete user intake
    When I view the last user intake
    Then I should see "Submitted at"

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: Anyone other than halouser/subscriber can see link in the not-yet-legally-agreed user intake form, to agreement PDF
    Given I have a <state> user intake
    And I edit the last user intake
    Then I should see "<text>"
    
    Examples:
      | state      | text                      |
      | saved      | Halo Subscriber Agreement |
      | non-agreed | Halo Subscriber Agreement |
      | complete   | Halo Subscriber Agreement |

  # TODO: Need more scenarios to cover the feature
  Scenario: halouser, subscriber and other roles / edit and show / agreement pages
  
  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Show legal agreement after submitting user intake successfully, unless already agreed earlier
    Given I have a saved user intake
    When I edit the last user intake
    And I press "user_intake_submit"
    Then I should see "successfully updated"
  