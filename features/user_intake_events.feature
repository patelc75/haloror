Feature: Business - user intake - events and external
  In order to value
  As a role
  I want feature

  Background: Authenticated user
    Given I am an authenticated super admin
    And a group "bestbuy" exists with group admin
    And the following devices:
      | serial_number |
      | H234567890    |
    And the following user intakes:
      | gateway_serial | group_name |
      | H234567890     | bestbuy    |

  # 
  #  Thu Jan 20 20:43:54 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3887
  # Scenario: Email is sent to admin of group, when user gets "installed"
  #   When the senior of user intake "H234567890" gets the device installed
  #   Then an email to "admin_of_bestbuy@test.com" with subject "Kit successfully installed" should be sent for delivery

  Scenario: Call center account number in subject line of email
    When the senior of user intake "H234567890" gets the call center number
    Then an email to "safety_care@myhalomonitor.com" with gateway serial for user intake "H234567890" in subject should be sent for delivery

  # 
  #  Thu Jan 20 20:47:01 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3887
  # Scenario: Email subject contains "Update HM..." when updating
  #   When the gateway serial for user intake "H234567890" is updated to "HM12345678"
  #   Then an email to "safety_care@myhalomonitor.com" with subject "Update HM12345678" should be sent for delivery

  # 
  #  Thu Jan 20 21:01:39 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3887
  # Scenario: Update email only contains "changes made"
  #   When the gateway serial for user intake "H234567890" is updated to "HM12345678"
  #   Then an email to "safety_care@myhalomonitor.com" with body "Changes made" should be sent for delivery
    
  # 
  #  Thu Jan 20 21:02:28 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3887
  # Scenario: When the approve button is clicked and test mode disabled, send email to admin of group
  #   When I edit user intake with gateway serial "H234567890"
  #   And I press "user_intake_submit"
  #   Then an email to "admin_of_bestbuy@test.com" with subject "Approved" should be sent for delivery
