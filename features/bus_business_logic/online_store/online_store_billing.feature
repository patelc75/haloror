Feature: Online store group billing
  In order to value
  As a role
  I want feature

   # full set of attributes (will be re-visited in 1.7.0)
  # | name             | marketlink      |
  # | charge_kit       | invoice_advance |
  # | charge_mon       | installed       |
  # | charge_lease     | none"           |
  # | grace_lease_days |                 |
  # | grace_lease_from |                 |
  # | grace_mon_days   |                 |
  # | grace_mon_from   | never           |
  # | price_mon_bc     | 7.50            |
  # | price_mon_cs     | 8.50            |
  # | price_lease_bc   |                 |
  # | price_lease_cs   |                 |
  Background:
    Given the product catalog exists
    And the following groups:
      | name               | charge_kit      | charge_mon     | charge_lease   | grace_mon_days | grace_mon_from |
      | direct_to_consumer | point_of_sale   | installed      | none           | 7              | ship           |
      | best_buy           | invoice_advance | installed      | none           |                | never          |
      | active_forever     | invoice_server  | invoice_server | none           | 7              | ship           |
      | marketlink         | invoice_advance | installed      | none           |                | never          |
      | senior_helpers     | invoice_advance | invoice_server | invoice_server |                |                |
      | sub_dealer         |                 |                |                |                |                |
      | sub_dealer2        |                 |                |                |                |                |

   # Tests charge_mon = installed and charge_kit = invoice_advance   
   # Need to rename Group.grace_period to Group.grace_mon_days in DB
   Scenario: If monitoring is configured to charge when installed, User Intake must include successful prorate and recurring credit card charge to switch to "Installed" status
     And I am an authenticated user
     And user "demo" has "sales" role for group "marketlink"
     And user "super_admin" has "super_admin" role
     When I go to the online store
     And I select "marketlink" from "Group"
     And I choose "product_complete"
     And I fill the shipping details for online store
     And I fill the credit card details for online store
     And I check "Same as shipping"
     And I press "Continue"
     And I press "Place Order"
     And I follow "Skip for later"
     And I am editing the user intake associated to last order
     When I select "marketlink" from "Group"
     And I press "user_intake_submit"
     And user "super_admin" approves the associated user intake form
     And a panic button is delivered after the desired installation date and the user is not in test mode
     And user "super_admin" clicks the "Bill" button for the subscriber in the associated user intake form
     Then the associated user intake must include successful prorate and recurring charges
     And the associated one time charge does not exist for the order  #response table only includes the monitoring (both recurring & prorate)    
     And the associated user intake goes to "Installed" state

   # Tests charge_kit=invoice_server or invoice_advance AND charge_mon=invoice_server
   Scenario: If the group is invoiced for both kit and monitoring charges, then hide online store so user is forced to create a new user intake form

   Scenario: Same as previous Scenario except include 1 month free coupon code which means prorate and recurring charged 1 month later (start from scenario 33)

  # this relates to the billing reports slated for 1.7.0
   @wip
   Scenario: 2 subdealer orders under a MarketLink with verification of amounts on the billing page
    And I am an authenticated user
    And group "default" is a child of group "marketlink"
    And group "sub_dealer" is a child of group "marketlink"
    And group "sub_dealer2" is a child of group "marketlink"
    And user "demo" has "sales" role for group "sub_dealer","sub_dealer2"
    When I go to the online store
    And I select "sub_dealer" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    And I follow "Skip for later"
    And page content should have "Thank you"
    And last order should be associated to "sub_dealer" group
    When I go to the online store
    And I select "sub_dealer2" from "Group"
    And I choose "product_clip"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    And I follow "Skip for later"
    Then page content should have "Thank you"
     #put in exact amount when coupon codes are rewritten
    And monitoring fee should be charged on the credit card
    And kit fee should not be charged on the credit card
    # Write feature so billing shows up in triage (after panic button press) and somebody clicks it
    And I follow "My Links > Billing"
    And I select "marketlink" from "Group"
    And I select Time.now.strftime("%B") from "Month"
    Then I should see the heading "Receipt"
     #fix when coupon codes are fixed
    And I should see $59 - $30 associated with "Total" for group "sub_dealer"
     #fix when coupon codes are fixed
    And I should see $49 - $25 associated with "Total" for group "sub_dealer2"
    #price_mon_bc (sub_dealer) + price_mon_cs (sub_dealer2)
    And I should see "16.00" associated with "Total" for group "marketlink"

   @wip
   Scenario: Senior Helpers with verification of amounts on the billing page
     Given a group exists with the following attributes:
       | name                  | "senior_helpers"  |
       | kit_charge            | "invoice_advance" |
       | lease_fee_separate    | "true"            |
       | lease_grace_days      | 7                 |
       | lease_grace_from      | "ship"            |
       | monitoring_grace_days |                   |
       | monitoring_grace_from | "never"           |
       | monitoring_charge     | "invoice_web"     |
       | commission_mon_bc     | 9.00              |
       | commission_mon_cs     | 14.00             |
       | commission_lease_bc   | 15.00             |
       | commission_lease_cs   | 15.00             |
     And I am an authenticated user
     And user "demo" has "sales" role for group "senior_helpers"
     When I go to the online store
     And I select "senior_helpers" from "Group"
     And I choose "product_complete"
     And I fill the shipping details for online store
     And the credit card details should not be present
     Then page content should have "Thank you"
     And monitoring fee should be not charged on the credit card
     And I follow "My Links > Billing"
     And I select "senior_helpers" from "Group"
     And I select Time.now.strftime("%B") from "Month"
     Then I should see the heading "Invoice"
     Then I should see $99 + $30 associated with "Total" for group "senior_helpers"
