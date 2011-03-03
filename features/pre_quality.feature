Feature: Pre quality
  In order to value
  As a role
  I want feature

  Background:
    # Login as super_admin
    Given I am an authenticated super admin
    And only the following carriers:
      | name    |
      | Alltel  |
      | Verizon |
    
  # Create a new group (eg. ml_group1_5_1-rc1) at My Links > Config > Roles + Groups and add an email addr for the group
  # Create a master group (eg. ml_master) and add an email address for the master group
  Scenario Outline: super admin > create a group
    When I am ready to create a "<name>" reseller group
    And I press "Save"
    Then a group should exist with name "<name>"
    
    Examples:
      | name              | email                |
      | ml_group1_5_1-rc1 | ml_reseller@test.com |
      | ml_master         | ml_master@test.com   |

  # Create an admin (eg. admin1.5.1-rc1) for the new group at My Links > Sign up users with other roles
  Scenario: super admin > create an admin
    When I create a "reseller" reseller group
    And I am creating admin of "reseller" group
    And I fill in "First Name" with "admin1.5.1-rc1"
    And I fill in "Email" with "admin1_5_1_rc1@example.com"
    And I press "subscribe"
    Then I should see "for activation of account"
    And email with activation code of last user should be sent for delivery
    And user "last" should have "admin" role for group "reseller"
    # count of emails is ignored here to accommodate within timeline of 1.6.0 release
    # we must check the count also, or, users may get multiple similar emails

  # Login as admin created in previous section
  # Try clicking activation link in both emails
  Scenario: Activate an admin
    When I create a "reseller" reseller group
    And I create admin of "reseller" group
    And I logout
    And I am activating the last user as "reseller_admin"
    And I press "subscribe_button"
    Then last user should be activated
    And I should see "reseller_admin"
    
  # Create a new coupon code for the new group at My Links > Config > Coupon Codes
  Scenario: super admin > create an coupon code
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I am ready to create a coupon code for "reseller" group
    And I fill in the following:
      | Coupon code       | coupon1.5.1-rc1 |
      | Deposit           | 66              |
      | Shipping          | 6               |
      | Monthly recurring | 77              |
      | Months advance    | 0               |
      | Months trial      | 2               |
    And I press "Save"
    Then a coupon code should exist with coupon_code "coupon1.5.1-rc1"
  
  # Verify group under “Billing and Shipping” block
  Scenario: admin > online store has single group
    Given the product catalog exists
    And a group "bogus" exists
    When I create a "reseller" reseller group
    And I create admin of "reseller" group
    And I logout
    And I activate the last user as "reseller_admin"
    And I go to the online store
    # Verify the group name displays correctly
    Then I should see "reseller"
    # Verify there in “no” link adjacent to the group name for changing the group
    And page content should not have "bogus, switch"
    # Verify that manually forcing “/orders/switch_group” does not allow to switch the group, but snaps back to order page with the same group name visible
    When I am switching the group for online store
    Then I should see "Group: reseller"
    And I should not see "Please select a group"

  Scenario: admin > coupon applies correctly
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I am ready to create a coupon code for "reseller" group
    And I fill in the following:
      | Coupon code       | coupon1.5.1-rc1 |
      | Deposit           | 66              |
      | Shipping          | 6               |
      | Monthly recurring | 77              |
      | Months advance    | 0               |
      | Months trial      | 2               |
    And I press "Save"
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing an online order for "re_reseller" group
    And I fill in "Coupon Code" with "coupon1.5.1-rc1"
    And I press "Continue"
    # Use above coupon code and verify above values are charged to credit card
    Then I should see "$66"
    And I should see "2 months trial"

  # senior different from subscriber
  Scenario Outline: admin > place order : senior <> subscriber
    Given the product catalog exists
    And there are no user intakes
    And the following groups:
      | name        | sales_type | email                |
      | ml_reseller | reseller   | ml_reseller@test.com |
      | ml_master   | reseller   | ml_master@test.com   |
    # coupon code 
    When I am ready to create a coupon code for "ml_reseller" group
    And I fill in the following:
      | Coupon code       | coupon1.5.1-rc1   |
      | Deposit           | <deposit_amount>  |
      | Shipping          | <shipping_amount> |
      | Monthly recurring | 77                |
      | Months advance    | 0                 |
      | Months trial      | 2                 |
    And I press "Save"
    Then a coupon code should exist with coupon_code "coupon1.5.1-rc1"
    #
    When I create admin of "ml_reseller" group
    And I activate the last user as "ml_reseller_admin"
    And I am placing an online order for "ml_reseller" group
    Then I should see "ml_reseller"
    And I should not see "ml_master"
    When I fill in "Coupon Code" with "ml_reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    #   * TODO: verify the count of emails as per business logic
    Then an email to "cuc_ship@chirag.name" with subject "Please activate your new myHalo account" should be sent for delivery
    And an emails to "cuc_bill@chirag.name" with subject "wants you to be their caregiver" should be sent for delivery
    # To senior_signup@halomonitoring.com, group, master group: Subject "[HALO] Order Summary"
    And an email to "senior_signup@halomonitoring.com" with subject "Order Summary" should be sent for delivery
    And an email to "ml_master@test.com" with subject "Order Summary" should be sent for delivery
    And an email to "ml_reseller@test.com" with subject "Order Summary" should be sent for delivery
    And 1 user intake should be available
    # At Config > Users, verify the following 2 users were created
    And senior of last user intake should not be subscriber
    And subscriber of last user intake should be caregiver
    When I edit the last user intake
    Then "user_intake_subscriber_is_user" checkbox should not be checked
    And "user_intake_no_caregiver_1" checkbox should be checked
    And "user_intake_no_caregiver_2" checkbox should be checked
    And "user_intake_no_caregiver_3" checkbox should be checked
    #
    # https://redmine.corp.halomonitor.com/issues/3790
    When I activate the last subscriber as "ml_reseller_subscriber"
    Then senior of last user intake should not be subscriber
    And subscriber of last user intake should be caregiver1
    And subscriber of last user intake should not be caregiver2
    
    Examples:
      | deposit_amount | shipping_amount |
      | 66             | 6               |
      | 0              | 0               |

  # senior == subscriber
  Scenario: admin > place order : senior == subscriber
    Given the product catalog exists
    And there are no user intakes
    And the following groups:
      | name        | sales_type | email                |
      | ml_reseller | reseller   | ml_reseller@test.com |
      | ml_master   | reseller   | ml_master@test.com   |
    When I create a coupon code for "ml_reseller" group
    And I create admin of "ml_reseller" group
    And I activate the last user as "ml_reseller_admin"
    And I am placing an online order for "ml_reseller" group
    And I check "order_bill_address_same"
    Then I should see "ml_reseller"
    And I should not see "ml_master"
    When I fill in "Coupon Code" with "ml_reseller_coupon"
    And I press "Continue"
    And I press "Place Order"
    And 1 user intake should be available
    # Verify only 1 user halouser was added in Config > Users. Verify no extra users were created.
    And senior of last user intake should be subscriber
    And last user intake should not have caregivers
    When I edit the last user intake
    # “Same as User” is checked and “No Caregiver #1” is clickable
    Then "user_intake_subscriber_is_user" checkbox should be checked
    And "user_intake_no_caregiver_1" checkbox should be checked
    And "user_intake_no_caregiver_2" checkbox should be checked
    And "user_intake_no_caregiver_3" checkbox should be checked
    # At Config > Users, verify the following 2 users were created
    When I view the senior of last user intake
    Then page content should have "halouser, subscriber for"
    And page content should not have "caregiver for"

  # Add caregiver: My Links > Config > Users > (find row for new halouser) > Caregiver > Add Caregiver > Add new caregiver with no email
  Scenario: admin > add a new caregiver with no email
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    #   * "Admin" cannot create a caregiver anymore
    #   * activating an admin also makes it logged in
    # And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I view the senior of last user intake
    And I follow links "Caregivers > add_caregiver_button"
    And I follow "Add new caregiver with no email"
    And I fill in the following:
      | Username         | caregiver1    |
      | Password         | abc123        |
      | Confirm Password | abc123        |
      | First Name       | cg first name |
      | Last Name        | cg last name  |
      | Address          | chicago       |
      | Cross St         | chicago       |
      | City             | chicago       |
      | State            | IL            |
      | Zipcode          | 12345         |
      | Home Phone       | 1234567890    |
      | Work Phone       | 1234567890    |
    And I press "submit_caregiver"
    Then I should see "cg first name cg last name"

  # Approve Subscription agreement after picking login/password
  Scenario: halouser > approve subscription agreement
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    # Login as admin of the group created in Section 1
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I logout
    # Try clicking activation link in both emails
    And I activate the "reseller_senior" senior of last order
    And I check "userintake_agree"
    And I press "Agree"
    Then I should see "Successfully updated"

  Scenario: halouser > submit user intake form - subscriber is caregiver
    Given the product catalog exists
    And the following devices:
      | serial_number |
      | H200220022    |
      | H100110011    |
    And critical alerts types exist
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I place an online order for "reseller" group
    # submit button is not available in trial period
    And panic button test data is received for user intake "last"
    # Open the user intake, perform the following steps and click Save
    And I edit the last user intake
    # Check email, text toggles
    And I check "caregiver1_email_flag"
    And I check "caregiver2_email_flag"
    And I check "caregiver3_email_flag"
    And I check "caregiver1_text_flag"
    And I check "caregiver2_text_flag"
    And I check "caregiver3_text_flag"
    And I uncheck "user_intake_subscriber_is_user"
    And I check "user_intake_subscriber_is_caregiver"
    # And I check "user_intake_no_caregiver_1"
    And I uncheck "user_intake_no_caregiver_2"
    And I uncheck "user_intake_no_caregiver_3"
    And I fill the subscriber details for user intake form
    # Add Caregiver #2 and Caregiver #3
    And I fill the caregiver2 details for user intake form
    And I fill the caregiver3 details for user intake form
    And I select "Verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver3_attributes__profile_attributes_carrier_id"
    # Add today’s date as Desired Installation Date
    And I select "user_intake_installation_datetime" date as "`Date.today.to_s`"
    # Add GW and Transmitter serial numbers by finding  unused (no icon) serial numbers at Config > Devices
    And I fill in "user_intake_gateway_serial" with "H200220022"
    And I fill in "user_intake_transmitter_serial" with "H100110011"
    And I press "user_intake_submit"
    # TODO: Then I should see "successfully updated"
    # Verify serial numbers were mapped to devices at Config > Devices
    And devices "H200220022, H100110011" should be attached to last user intake
    # Click “Submit” button on User intake form and verify “Ready for Approval” state at My Links > User Intakes
    #  Mon Nov 22 13:31:40 IST 2010, ramonrails: TODO: manually smoke tested this step
    When I edit the last user intake
    # Then page content should have "H200220022, H100110011, caregiver2 first name, caregiver3 first name, `Date.today.to_s`"
    #   * This is now AJAX. need capybara
    # email, text and phone checkboxes
    # https://redmine.corp.halomonitor.com/issues/3674
    Then caregiver2 of last user intake should have email, text checked
    And caregiver3 of last user intake should have email, text checked
    # Then "caregiver1_email_flag" checkbox should be checked
    # And "caregiver2_email_flag" checkbox should be checked
    # And "caregiver3_email_flag" checkbox should be checked
    # And "caregiver1_text_flag" checkbox should be checked
    # And "caregiver2_text_flag" checkbox should be checked
    # And "caregiver3_text_flag" checkbox should be checked

  Scenario: halouser > submit user intake form - make all users distinct
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    And I am listing user intakes
    And I follow "edit_link"
    And I uncheck "user_intake_subscriber_is_user"
    And I uncheck "user_intake_subscriber_is_caregiver"
    And I uncheck "user_intake_no_caregiver_1"
    And I uncheck "user_intake_no_caregiver_2"
    And I uncheck "user_intake_no_caregiver_3"
    And I fill the subscriber details for user intake form
    And I fill the caregiver1 details for user intake form
    And I fill the caregiver2 details for user intake form
    And I fill the caregiver3 details for user intake form
    And I select "Verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_subscriber_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver1_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver3_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    # TODO: Then I should see "successfully updated"
    Then senior of last user intake should not be subscriber
    And subscriber of last user intake should not be caregiver
    And last user intake should have 5 users

  # 
  #  Fri Nov 12 00:20:54 IST 2010, ramonrails
  #  release 1.6.0 test cases from Intake + Install States spreadsheet
  #  http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=3
  # https://redmine.corp.halomonitor.com/issues/3798
  Scenario: D2 - halouser == subscriber. Enable test mode (opt out of call center + caregivers away)
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I place an online order for "reseller" group
    Then senior of last user intake should be in test mode
    # Verify “Opt out of live call center” is checked in the profile of halouser
    And senior of last user intake should be opted out of call center
    # Verify all caregivers are away at Config > Users > (pick row) > Caregivers
    And I activate the last senior as "reseller_senior"
    And I activate the last subscriber as "reseller_subscriber"
    And caregivers of last user intake should be away
    # Open user intake and Verify Credit Card/Manual Billing radio button is set to credit card
    #  Mon Nov 22 13:33:56 IST 2010, ramonrails
    #   TODO: these are ajax/css steps. need capybara. webrat does not work. manualy smoke tested
    # When I edit the last user intake
    # Then "user_intake_credit_debit_card_proceessed_" checkbox should be checked
    # And "user_intake_bill_monthly_" checkbox should not be checked

  # https://redmine.corp.halomonitor.com/issues/3798
  Scenario: halouser <> subscriber - Enable test mode (opt out of call center + caregivers away)
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing an online order for "reseller" group
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then senior of last user intake should be in test mode
    # Verify “Opt out of live call center” is checked in the profile of halouser
    And senior of last user intake should be opted out of call center
    # Verify all caregivers are away at Config > Users > (pick row) > Caregivers
    And I activate the last senior as "reseller_senior"
    And I activate the last subscriber as "reseller_subscriber"
    And caregivers of last user intake should be away
  
  # (1) Uncheck "Same as User" at the Online Store
  # (2) Verify both halouser and subsriber (and roles) in Config > Users
  # (3) Also, verify SQL - see note
  # (4) Verify call center account number is incremented and
  #     click envelope button and verify email is sent
  # (5) Verify Credit Card/Manual Billing radio button User Intake Form
  Scenario: H4 - Intake + Install States spreadsheet
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    # Uncheck “Same as Users Home Address”
    And I uncheck "order_bill_address_same"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Success"
    # “Same as User” is unchecked, “Add as #1 Caregiver” is checked, and “No Caregiver #1” is not clickable
    And billing and shipping addresses should not be same
    # At Config > Users, verify the 2 users halouser and subscriber (will also include caregiver role) were added.
    And last user intake should have separate senior and subscriber
    And subscriber of last user intake is also the caregiver
    #
    # verify roles in config > users
    # Verify no extra roles and no extra users were created.
    And last user intake should have 2 users
    When I view the subscriber of last user intake
    Then page content should have "subscriber for, caregiver for"
    #
    # verify call center account number
    # Verify call center account number is incremented in the profile of halouser
    Then last user intake should have latest call center account number
    #
    #  Mon Dec 20 23:44:09 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3767
    #   * safety_care email dispatch is elimited from business logic
    # safety care email
    # When I send caregiver details for the last user intake
    # Then 1 email to "safety care" should be sent for delivery
    #
    Then the last user intake should have credit card value
    #   * Cannot check javascript action
    # When I edit the last user intake
    # Then the "Card" checkbox should be checked
    # And the "Manual Billing" checkbox should not be checked
    When I logout
    And I activate the last subscriber as "reseller_subscriber"
    Then last subscriber should be activated
    And I should see "reseller_subscriber"
  
  # user intake sheet: H4
  # (3) Activate user, subscriber, and caregiver via email link
  Scenario: Activating admin, senior, subsriber and caregivers
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I create admin of "reseller" group
    And I activate the last user as "reseller_admin"
    And I am placing an online order for "reseller" group
    And I fill in "Coupon Code" with "reseller_coupon"
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    When I edit the last user intake
    And I uncheck "user_intake_subscriber_is_caregiver"
    And I uncheck "user_intake_no_caregiver_1"
    And I uncheck "user_intake_no_caregiver_2"
    And I uncheck "user_intake_no_caregiver_3"
    And I fill the caregiver1 details for user intake form
    And I fill the caregiver2 details for user intake form
    And I fill the caregiver3 details for user intake form
    And I select "Verizon" from "user_intake_caregiver1_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver2_attributes__profile_attributes_carrier_id"
    And I select "Verizon" from "user_intake_caregiver3_attributes__profile_attributes_carrier_id"
    And I press "user_intake_submit"
    # TODO: Then I should see "successfully updated"
    #
    # activate senior
    When I activate the last senior as "reseller_senior"
    Then last senior should be activated
    #
    # activate subscriber
    When I activate the last subscriber as "reseller_subscriber"
    Then last subscriber should be activated
    #
    # activate caregiver1
    When I activate the last caregiver1 as "reseller_caregiver1"
    Then last caregiver1 should be activated
    #
    # activate caregiver2
    When I activate the last caregiver2 as "reseller_caregiver2"
    Then last caregiver2 should be activated
    #
    # activate caregiver3
    When I activate the last caregiver3 as "reseller_caregiver3"
    Then last caregiver3 should be activated
  
    # https://redmine.corp.halomonitor.com/issues/3793
    # QUESTION: If a subscriber subscribes for multiple halousers, how does he/she view all those user intakes?
  Scenario: Activated subscriber (not same as halouser) can edit user intake
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    And I uncheck "order_bill_address_same"
    And I fill the shipping details for online store
    And I fill the billing details for online store
    And I fill the credit card details for online store
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Success"
    #
    When I activate the last subscriber as "reseller_subscriber"
    Then last subscriber should be activated
    #
    When I follow "User Intake"
    #   * TODO: Need capybara
    # Then the page content should have "reseller, cuc_ship@chirag.name, cuc_bill@chirag.name"
    Then page content should have "User Information, Billing Information"
  
  Scenario: User Intake > Submit > Approve > Panic > Installed
    Given I am an authenticated super admin
    And the following groups:
      | name       |
      | halo_group |
    And the following carriers:
      | name    |
      | verizon |
    When I am creating a user intake
    And I select "halo_group" from "group"
    And I fill the senior details for user intake form
    And I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"
    And I press "Submit"
    Then page content should have "successfully created"
    And last user intake should have a senior profile
    And the last senior should not have an invoice
    And user intake "last" should have "Ready for Approval" status
    When I edit the last user intake
    And I press "Approve"
    Then page content should have "successfully updated"
    And the last senior should not have an invoice
    And user intake "last" should have "Ready to Install" status
    When panic button test data is received for user intake "last"
    Then user intake "last" should have "Installed" status
    #   * https://redmine.corp.halomonitor.com/issues/4111#note-8
    When panic button test data is received for user intake "last"
    Then last user intake retains its existing panic timestamp
    And the last senior should not have an invoice

  Scenario: Online Order > User Intake > Submit > Approve > Panic > Installed
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Success"
    #   * submit
    When I edit the last user intake
    And I press "Submit"
    Then page content should have "successfully updated"
    And the last user intake does not have any invoice
    #   * approve
    When I edit the last user intake
    And I press "Approve"
    Then page content should have "successfully updated"
    And user intake "last" should have "Ready to Install" status
    And the last user intake does not have any invoice
    #   * panic
    When panic button test data is received for user intake "last"
    Then user intake "last" should have "Ready to Bill" status
    And the last user intake does not have any invoice
    #   * bill
    When I edit the last user intake
    And I press "Bill"
    Then user intake "last" should have "Installed" status
    And the last invoice has pro-rata and recurring columns filled
    #   * https://redmine.corp.halomonitor.com/issues/4111#note-8
    When panic button test data is received for user intake "last"
    Then last user intake retains its existing panic timestamp

  Scenario: Online Order > User Intake > Submit > Approve > Ship date > Start Subscription > Installed
    Given the product catalog exists
    When I create a "reseller" reseller group
    And I create a coupon code for "reseller" group
    And I am placing an online order for "reseller" group
    And I uncheck "order_bill_address_same"
    And I press "Continue"
    And I press "Place Order"
    Then I should see "Success"
    #   * submit
    When I edit the last user intake
    And I press "Submit"
    Then page content should have "successfully updated"
    And the last invoice has pro-rata and recurring columns empty
    #   * approve
    When I edit the last user intake
    And I press "Approve"
    Then page content should have "successfully updated"
    And user intake "last" should have "Ready to Install" status
    And the last invoice has pro-rata and recurring columns empty
    #   * ship date
    When the last user intake had the product shipped 5 weeks ago
    #   * start subscription (same as "Bill")
    And I start the subscription for the last user intake
    Then user intake "last" should have "Installed" status
    And the last user intake should prorate up to this month
    And the last user intake should start subscription from upcoming month
    And the last invoice has pro-rata and recurring columns filled
