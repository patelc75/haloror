Feature: Bus user intake states
  In order to value
  As a role
  I want feature

  Background:
    Given the following user_intakes:
      | kit_serial_number | id  |
      | 12345             | 123 |
    
  # status: grey
  # reason: default state. test mode "ON"
  # action:
  # triage:
  Scenario: User Intake - Not yet submitted
    Then senior of last user intake should have "" status
    And action button for user intake "12345" should be colored grey
  
  # status: yellow
  # reason: 60 hours before desired installation date
  # action: email to admin
  # triage: caution
  Scenario Outline: User Intake - Caution - Not yet submitted
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And I should not see senior of user intake "12345" in triage
    And action button for user intake "12345" should be colored yellow
    
    Examples:
      | hours_away |
      | 49         |
      | 60         |
  
  # status: red
  # reason: 48 hours before desired installation date
  # action: email to admin
  # triage: abnormal
  Scenario: User Intake - Abnormal - Not yet submitted
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red
    
    Examples:
      | hours_away |
      | 24         |
      | 48         |
    
  # status: grey
  # reason: submitted
  # action: send email to safety care. user intake read-only (except super_admin)
  # triage: abnormal
  Scenario: User Intake - Ready for approval
    Given I am ready to submit a user intake
    And I press "user_intake_submit"
    Then an email to safety care should be sent for delivery
    And last user intake should be read only
    And I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored grey
  
  # status: yellow
  # reason: 8 hours before desired installation date
  # action:
  # triage: caution
  Scenario: User Intake - Caution - Ready for approval
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored yellow

    Examples:
      | hours_away |
      | 8          |
      | 6          |
    
  # status: red
  # reason: 4 hours before desired installation date
  # action: 
  # triage: abnormal
  Scenario: User Intake - Abnormal - Ready for approval
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red

    Examples:
      | hours_away |
      | 4          |
      | 1          |
  
  # status: grey
  # reason: clicked Approve button
  # action: disable test mode. email to admin
  # triage: 
  Scenario: User Intake - Ready for Install
    Given user intake "12345" status is "Ready for Approval"
    And I am editing user intake "12345"
    When I press "Approve"
    Then action button for user intake "12345" should be colored grey
    And an email to admin of user intake "12345" should be sent for delivery
    
  # status: yellow
  # reason: 1 day after, desired installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: caution
  Scenario: User Intake - Caution - Ready for Install
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored yellow
    
  # status: red
  # reason: 2 days after, desirec installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: abnormal
  Scenario: User Intake - Abnormal - Ready for Install
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red
  
  # status: grey
  # reason: panic button test after desired installation date. not in test mode.
  # action: 
  # triage: 
  Scenario: User Intake - Ready to bill
    And action button for user intake "12345" should be colored grey
    
  # status: yellow
  # reason: 1 day old "Ready to bill"
  # action: 
  # triage: caution
  Scenario: User Intake - Caution - Ready to bill
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored yellow
    
  # status: red
  # reason: 7 days old "Ready to bill"
  # action: 
  # triage: abnormal
  Scenario: User Intake - Abnormal - Ready to bill
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red
    
  # status: green
  # reason: bill_monthly = true OR credit card transaction successful
  # action: email to admin, halouser, caregivers
  # triage: 
  Scenario: User Intake - Installed
    And action button for user intake "12345" should be colored green
  
  # status: grey
  # reason: clicked "discontinue service" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: caution (RMA desired discontinue service date: not reached yet)
  Scenario: User Intake - Caution - Suspended
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored grey

  # status: grey
  # reason: clicked "discontinue service" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: abnormal (RMA desired discontinue service date: reached already)
  Scenario: User Intake - Abnormal - Suspended
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored grey
    
  # status: grey
  # reason: clicked "Discontinue billing" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: caution (RMA desired cancel date: not reached yet)
  Scenario: User Intake - Caution - Cancelled
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored grey
    
  # status: grey
  # reason: clicked "Discontinue billing" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: abnormal (RMA desired cancel date: reached already)
  Scenario: User Intake - Abnormal - Cancelled
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored grey
    