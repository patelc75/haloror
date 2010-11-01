Feature: Bus user intake statuses
  In order to value
  As a role
  I want feature

  * subject and body of emails

  Background:
    Given I am an authenticated user
    And the following user_intakes:
      | gateway_serial | id  |
      | 1234567890     | 123 |
    And the senior of user intake "1234567890" is not in test mode
    
  # status: gray
  # reason: default status. test mode "ON"
  # action:
  # triage:
  # ref   : Intake + Install States google doc : row 2
  Scenario: User Intake - Not yet submitted
    Then senior of last user intake should have "" status
    # TODO: we will worry about colors in 1.7.0
    # And action button for user intake "1234567890" should be colored gray
  
  # status: yellow
  # reason: 60 hours before desired installation date
  # action: email to admin
  # triage: caution
  # ref   : Intake + Install States google doc : row 3
  Scenario Outline: User Intake - Caution - Not yet submitted
    Given desired installation date for user intake "1234567890" is in <hours_away> hours
    And the senior of user intake "1234567890" has "" status
    Then I should see triage status "caution" for senior of user intake "1234567890"
    And action button for user intake "1234567890" should be colored yellow
    
    Examples:
      | hours_away |
      | 49         |
      | 60         |
  
  # status: red
  # reason: 48 hours before desired installation date
  # action: email to admin
  # triage: abnormal
  # ref   : Intake + Install States google doc : row 3
  Scenario Outline: User Intake - Abnormal - Not yet submitted
    Given desired installation date for user intake "1234567890" is in <hours_away> hours
    And the senior of user intake "1234567890" has "" status
    Then I should see triage status "abnormal" for senior of user intake "1234567890"
    And action button for user intake "1234567890" should be colored red
    # And an email to group admins of user intake "1234567890" should be sent for delivery
    
    Examples:
      | hours_away |
      | 24         |
      | 48         |
    
  # status: gray
  # reason: submitted
  # action: send email to safety care, halouser, subscriber, admin. user intake read-only (except super_admin)
  # triage: 
  # ref   : Intake + Install States google doc : row 4
  # email
  # Subject: "Joe Smith's user intake form has been submitted."
  # Body of email: "Joe Smith's user intake form has been submitted. Halo is now in process of approving the form. Once approved, you will be emailed and the myHalo system will be ready to install"
  Scenario: User Intake - Ready for approval
    Given I am ready to submit a user intake
    And there are no emails
    And I press "user_intake_submit"
    Then an email to "safety care" should be sent for delivery
    And last user intake should be read only
    # TODO: we will worry about colors in 1.7.0
    # And action button for user intake "1234567890" should be colored gray
  
  # status: yellow
  # reason: 8 hours before desired installation date
  # action:
  # triage: caution
  # ref   : Intake + Install States google doc : row 5
  Scenario Outline: User Intake - Caution - Ready for approval
    Given desired installation date for user intake "1234567890" is in <hours_away> hours
    And the senior of user intake "1234567890" has "Ready for Approval" status
    Then I should see triage status "caution" for senior of user intake "1234567890"
    And action button for user intake "1234567890" should be colored yellow

    Examples:
      | hours_away |
      | 8          |
      | 6          |
    
  # status: red
  # reason: 4 hours before desired installation date
  # action: 
  # triage: abnormal
  # ref   : Intake + Install States google doc : row 5
  Scenario Outline: User Intake - Abnormal - Ready for approval
    Given desired installation date for user intake "1234567890" is in <hours_away> hours
    And the senior of user intake "1234567890" has "Ready for Approval" status
    Then I should see triage status "abnormal" for senior of user intake "1234567890"
    And action button for user intake "1234567890" should be colored red

    Examples:
      | hours_away |
      | 4          |
      | 1          |
  
  # status: gray
  # reason: clicked Approve button
  # action: opt in to call center. caregivers away. email to admin, subscriber, halouser
  # triage: 
  # ref   : Intake + Install States google doc : row 6
  # email
  # Subject: "Joe Smith's myHalo system is ready to install"
  # Body: "Joe Smith's myHalo system is ready to install. Please follow the instructions in the myHalo box."
  Scenario: User Intake - Ready to Install
    Given senior of user intake "1234567890" has "Ready for Approval" status
    When user intake "1234567890" gets approved
    # Then action button for user intake "1234567890" should be colored gray
    Then senior of user intake "1234567890" should be opted in to call center
    And caregivers should be away for user intake "1234567890"

    # And I am listing user intakes
    # And I follow "edit_link" in the 1st row
    # When I press "Approve"
    # And an email to admin of user intake "1234567890" should be sent for delivery
    # #
    # # TODO:
    # #   skipped for the sake of time for 1.6.0 release
    # #   steps similar to these (above) need a pre-condition setup in rspec
    # #   these may be working correctly in the code. just the rspec needs a pre-condition setup

  # status: yellow
  # reason: 1 day after, desired installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: caution
  # ref   : Intake + Install States google doc : row 7
  Scenario: User Intake - Caution - Ready to Install
    Given desired installation date for user intake "1234567890" was 1 days ago
    And the senior of user intake "1234567890" has "Ready to Install" status
    Then I should see triage status "caution" for senior of user intake "1234567890"
    # And an email to admin of user intake "1234567890" should be sent for delivery
    And action button for user intake "1234567890" should be colored yellow

  # status: red
  # reason: 2 days after, desired installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: abnormal
  # ref   : Intake + Install States google doc : row 7
  Scenario: User Intake - Abnormal - Ready to Install
    Given desired installation date for user intake "1234567890" was 2 days ago
    And the user intake "1234567890" status is "Ready to Install" since past 2 days
    Then I should see triage status "abnormal" for senior of user intake "1234567890"
    # And an email to admin of user intake "1234567890" should be sent for delivery
    And action button for user intake "1234567890" should be colored red

  # status: gray
  # reason: panic button test after desired installation date. not in test mode.
  # action: 
  # triage: 
  # ref   : Intake + Install States google doc : row 8
  # TODO: 1.6.0 panic error
  Scenario: User Intake - Ready to bill
    Given the senior of user intake "1234567890" is not in test mode
    And the user intake "1234567890" status is "Ready to Bill" since past 0 days
    When panic button test data is received for user intake "1234567890"
    # TODO: we will worry about colors in 1.7.0
    # Then action button for user intake "1234567890" should be colored gray

  # error in caution/abnormal state, but skipped for 1.6.0
  # # status: yellow
  # # reason: 1 day old "Ready to bill"
  # # action: 
  # # triage: caution
  # # ref   : Intake + Install States google doc : row 9
  # Scenario Outline: User Intake - Caution - Ready to bill
  #   Given the user intake "1234567890" status is "Ready to Bill" since past <days_ago> days
  #   Then I should see triage status "caution" for senior of user intake "1234567890"
  #   And action button for user intake "1234567890" should be colored yellow
  # 
  #   Examples:
  #     | days_ago |
  #     | 1        |
  #     | 5        |

  # status: red
  # reason: 7 days old "Ready to bill"
  # action: 
  # triage: abnormal
  # ref   : Intake + Install States google doc : row 9
  Scenario Outline: User Intake - Abnormal - Ready to bill
    Given the user intake "1234567890" status is "Ready to Bill" since past <days_ago> days
    Then I should see triage status "abnormal" for senior of user intake "1234567890"
    And action button for user intake "1234567890" should be colored red

    Examples:
      | days_ago |
      | 7        |
      | 10       |

  # TODO: known issue. panic does not trigger after_save event
  # status: green
  # reason: bill_monthly checked OR credit card transaction successful
  # action: email to admin, halouser, caregivers
  # triage: 
  # ref   : Intake + Install States google doc : row 10
  # email
  # Subject: "Joe Smith's myHalo system is officially active"
  # Body: "Joe Smith's myHalo system is officially active. Please log into http://www.myhalomonitor.com to configure your alerts"
  Scenario: User Intake - Installed
    Given bill monthly or credit card value are acceptable for user intake "1234567890"
    And we are on or past the desired installation date for senior of user intake "1234567890"
    And the senior of user intake "1234567890" has "Ready to Install" status
    When panic button test data is received for user intake "1234567890"
    Then the senior of user intake "1234567890" should be "Ready to Bill" status
    And action button for user intake "1234567890" should be colored gray
    And senior of user intake "1234567890" should be opted in to call center
    # And an email to admin, halouser and caregivers of user intake "1234567890" should be sent for delivery

  # current user can see the user intakes of its own groups only
  Scenario: User Intake - Bill
    Given a group "mygroup" exists
    And user "demo" has "admin" role for group "mygroup"
    And user intake "1234567890" belongs to group "mygroup"
    And senior of user intake "1234567890" has profile
    And bill monthly or credit card value are acceptable for user intake "1234567890"
    And we are on or past the desired installation date for senior of user intake "1234567890"
    And the senior of user intake "1234567890" has "Ready to Install" status
    When panic button test data is received for user intake "1234567890"
    And I go to the user intake overview
    And I follow "Ready to Bill"
    And I press "user_intake_submit"
    Then the senior of user intake "1234567890" should be "Installed" status

  # release 1.7.0
  #
  # # status: yellow
  # # reason: clicked "discontinue service" button in RMA parent
  # # action: email to admin, halouser, caregivers
  # # triage: caution (RMA desired discontinue service date: not reached yet)
  # Scenario: User Intake - Caution - Suspended
  #   Given RMA for user intake "1234567890" discontinues service in 1 day
  #   And senior of user intake "1234567890" has "Installed" status
  #   Then I should see triage status "caution" for senior of user intake "1234567890"
  #   And action button for user intake "1234567890" should be colored yellow
  #   # And an email to admin, halouser and caregivers of user intake "1234567890" should be sent for delivery
  # 
  # # status: red
  # # reason: clicked "discontinue service" button in RMA parent
  # # action: email to admin, halouser, caregivers
  # # triage: abnormal (RMA desired discontinue service date: reached already)
  # Scenario: User Intake - Abnormal - Suspended
  #   Given RMA for user intake "1234567890" discontinues service 1 day ago
  #   And senior of user intake "1234567890" has "Installed" status
  #   Then I should see triage status "abnormal" for senior of user intake "1234567890"
  #   And action button for user intake "1234567890" should be colored red
  #   
  # # status: yellow
  # # reason: clicked "Discontinue billing" button in RMA parent
  # # action: email to admin, halouser, caregivers
  # # triage: caution (RMA desired cancel date: not reached yet)
  # Scenario: User Intake - Caution - Cancelled
  #   Given RMA for user intake "1234567890" discontinues billing in 1 day
  #   And senior of user intake "1234567890" has "Installed" status
  #   Then I should see triage status "caution" for senior of user intake "1234567890"
  #   And action button for user intake "1234567890" should be colored yellow
  # 
  # # status: red
  # # reason: clicked "Discontinue billing" button in RMA parent
  # # action: email to admin, halouser, caregivers
  # # triage: abnormal (RMA desired cancel date: reached already)
  # Scenario: User Intake - Abnormal - Cancelled
  #   Given RMA for user intake "1234567890" discontinues billing 1 day ago
  #   And senior of user intake "1234567890" has "Installed" status
  #   Then I should see triage status "abnormal" for senior of user intake "1234567890"
  #   And action button for user intake "1234567890" should be colored red
  #   