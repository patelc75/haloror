Feature: Business - user intake - events and external
  In order to value
  As a role
  I want feature

  Background: Authenticated user
    Given I am an authenticated super admin
    And a group "bestbuy" exists with group admin
    And the following user intakes:
      | gateway_serial | group_name |
      | 1122334455     | bestbuy    |

  Scenario: Email is sent to admin of group, when user gets "installed"
    When the senior of user intake "1122334455" gets the device installed
    Then an email to "admin_of_bestbuy@test.com" with subject "Kit successfully installed" should be sent for delivery

  Scenario: Call center account number in subject line of email
    When the senior of user intake "1122334455" gets the call center number
    Then an email to "safety_care@myhalomonitor.com" with gateway serial for user intake "1122334455" in subject should be sent for delivery

  Scenario: Email subject contains "Update HM..." when updating
    When the gateway serial for user intake "1122334455" is updated to "HM12345678"
    Then an email to "safety_care@myhalomonitor.com" with subject "Update HM12345678" should be sent for delivery

  Scenario: Update email only contains "changes made"
    When the gateway serial for user intake "1122334455" is updated to "HM12345678"
    Then an email to "safety_care@myhalomonitor.com" with body "Changes made" should be sent for delivery
    
  Scenario: When the approve button is clicked and test mode disabled, send email to admin of group
    When I edit user intake with gateway serial "1122334455"
    And I press "user_intake_submit"
    Then an email to "admin_of_bestbuy@test.com" with subject "Approved" should be sent for delivery
