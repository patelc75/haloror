Feature: Bus user intake states
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated user
    And the following user_intakes:
      | kit_serial_number | id  |
      | 12345             | 123 |
    
  # status: gray
  # reason: default state. test mode "ON"
  # action:
  # triage:
  Scenario: User Intake - Not yet submitted
    Then senior of last user intake should have "" status
    And action button for user intake "12345" should be colored gray
  
  # status: yellow
  # reason: 60 hours before desired installation date
  # action: email to admin
  # triage: caution
  Scenario Outline: User Intake - Caution - Not yet submitted
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored yellow
    
    Examples:
      | hours_away |
      | 49         |
      | 60         |
  
  # status: red
  # reason: 48 hours before desired installation date
  # action: email to admin
  # triage: abnormal
  Scenario Outline: User Intake - Abnormal - Not yet submitted
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red
    # And an email to group admins of user intake "12345" should be sent for delivery
    
    Examples:
      | hours_away |
      | 24         |
      | 48         |
    
  # status: gray
  # reason: submitted
  # action: send email to safety care. user intake read-only (except super_admin)
  # triage: 
  Scenario: User Intake - Ready for approval
    Given I am ready to submit a user intake
    And I press "user_intake_submit"
    Then an email to safety care should be sent for delivery
    And last user intake should be read only
    And action button for user intake "12345" should be colored gray
  
  # status: yellow
  # reason: 8 hours before desired installation date
  # action:
  # triage: caution
  Scenario Outline: User Intake - Caution - Ready for approval
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
  Scenario Outline: User Intake - Abnormal - Ready for approval
    Given desired installation date for user intake "12345" is in <hours_away> hours
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red

    Examples:
      | hours_away |
      | 4          |
      | 1          |
  
  # status: gray
  # reason: clicked Approve button
  # action: disable test mode. email to admin
  # triage: 
  Scenario: User Intake - Ready for Install
    Given senior of user intake "12345" has "Ready for Approval" status
    And I am listing user intakes
    And I edit the 1st row
    When I press "Approve"
    Then action button for user intake "12345" should be colored gray
    # And an email to admin of user intake "12345" should be sent for delivery
    #
    # TODO:
    #   skipped for the sake of time for 1.6.0 release
    #   steps similar to these (above) need a pre-condition setup in rspec
    #   these may be working correctly in the code. just the rspec needs a pre-condition setup

  # status: yellow
  # reason: 1 day after, desired installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: caution
  Scenario: User Intake - Caution - Ready for Install
    Given desired installation date for user intake "12345" was 1 days ago
    Then I should see triage status "caution" for senior of user intake "12345"
    # And an email to admin of user intake "12345" should be sent for delivery
    And action button for user intake "12345" should be colored yellow

  # status: yellow
  # reason: 1 day after, desired installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: caution
  Scenario: User Intake - Caution - Ready for Install
    Given monitoring grace period with ship date for user intake "12345" was 1 days ago
    Then I should see triage status "caution" for senior of user intake "12345"
    # And an email to admin of user intake "12345" should be sent for delivery
    And action button for user intake "12345" should be colored yellow

  # status: red
  # reason: 2 days after, desirec installation date OR Group.grace_mon_days + ship_date
  # action: email to admin
  # triage: abnormal
  Scenario: User Intake - Abnormal - Ready for Install
    Given desired installation date or monitoring grace period with ship date for user intake "12345" was 1 days ago
    Then I should see triage status "abnormal" for senior of user intake "12345"
    # And an email to admin of user intake "12345" should be sent for delivery
    And action button for user intake "12345" should be colored red

  # status: gray
  # reason: panic button test after desired installation date. not in test mode.
  # action: 
  # triage: 
  Scenario: User Intake - Ready to bill
    Given the senior of user intake "12345" is not in test mode
    When panic button test data is received for user intake "12345"
    Then action button for user intake "12345" should be colored gray

  # status: yellow
  # reason: 1 day old "Ready to bill"
  # action: 
  # triage: caution
  Scenario Outline: User Intake - Caution - Ready to bill
    Given the user intake "12345" status is "Ready to Bill" since past <days_ago> day
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored yellow

    Examples:
      | days_ago |
      | 1        |
      | 5        |

  # status: red
  # reason: 7 days old "Ready to bill"
  # action: 
  # triage: abnormal
  Scenario Outline: User Intake - Abnormal - Ready to bill
    Given the user intake "12345" status is "Ready to Bill" since past <days_ago> day
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored red

    Examples:
      | days_ago |
      | 7        |
      | 10       |

  # status: green
  # reason: bill_monthly = true OR credit card transaction successful
  # action: email to admin, halouser, caregivers
  # triage: 
  Scenario: User Intake - Installed
    Given bill monthly or credit card value are acceptable for user intake "12345"
    When panic button test data is received for user intake "12345"
    # And an email to admin, halouser and caregivers of user intake "12345" should be sent for delivery
    And action button for user intake "12345" should be colored green

  # status: gray
  # reason: clicked "discontinue service" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: caution (RMA desired discontinue service date: not reached yet)
  Scenario: User Intake - Caution - Suspended
    Given RMA for user intake "12345" discontinues service in 1 day
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored gray
    # And an email to admin, halouser and caregivers of user intake "12345" should be sent for delivery

  # status: gray
  # reason: clicked "discontinue service" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: abnormal (RMA desired discontinue service date: reached already)
  Scenario: User Intake - Abnormal - Suspended
    Given RMA for user intake "12345" discontinues service 1 day ago
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored gray
    
  # status: gray
  # reason: clicked "Discontinue billing" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: caution (RMA desired cancel date: not reached yet)
  Scenario: User Intake - Caution - Cancelled
    Given RMA for user intake "12345" discontinues billing in 1 day
    Then I should see triage status "caution" for senior of user intake "12345"
    And action button for user intake "12345" should be colored gray

  # status: gray
  # reason: clicked "Discontinue billing" button in RMA parent
  # action: email to admin, halouser, caregivers
  # triage: abnormal (RMA desired cancel date: reached already)
  Scenario: User Intake - Abnormal - Cancelled
    Given RMA for user intake "12345" discontinues billing 1 day ago
    Then I should see triage status "abnormal" for senior of user intake "12345"
    And action button for user intake "12345" should be colored gray
    