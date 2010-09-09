Feature: Online store group billing
  In order to value
  As a role
  I want feature

  Background: 
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
    Given a group exists with the following attributes:
      | name           | direct_to_consumer |
      | charge_kit     | point_of_sale      |
      | charge_mon     | installed          |
      | charge_lease   | none               |
      | grace_mon_days | 7                  |
      | grace_mon_from | ship               |
    And a group exists with the following attributes:
      | name           | best_buy        |
      | charge_kit     | invoice_advance |
      | charge_mon     | installed       |
      | charge_lease   | none            |
      | grace_mon_from | never           |
    And a group exists with the following attributes:
      | name           | active_forever |
      | charge_kit     | invoice_server |
      | charge_mon     | invoice_server |
      | charge_lease   | none           |
      | grace_mon_days | 7              |
      | grace_mon_from | ship           |
    And a group exists with the following attributes:
      | name           | marketlink      |
      | charge_kit     | invoice_advance |
      | charge_mon     | installed       |
      | charge_lease   | none            |
      | grace_mon_from | never           |
    And a group exists with the following attributes:
      | name         | senior_helpers  |
      | charge_kit   | invoice_advance |
      | charge_mon   | invoice_server  |
      | charge_lease | invoice_server  |
    And a group exists with the following attributes:        
      | name         | sub_dealer |
      | price_mon_cs | 28.00      |
    And a group exists with the following attributes:
      | name | sub_dealer2 |
    And a group exists with the following attributes:
      | name         | default |
      | price_mon_bc | 25.00   |
      | price_mon_cs | 30.00   |
    And the product catalog exists

   # Need to rename Group.grace_period to Group.grace_mon_days in DB  
   Scenario: If kit charge is configured for invoice_advance, $0.00 kit price 
     And I am an authenticated user
     And group "default" is a child of group "marketlink"
     And user "demo" has "sales" role for group "marketlink"
     And I select "marketlink" from "Group" #remove this if there is only 1 group and no drop down is displayed      
     And I choose "product_complete"
     And I fill the shipping details for online store
     And I fill the credit card details for online store     
     And I check "Same as shipping"
     And I press "Continue"
     And I press "Place Order"
     And I follow "Skip for later"
     Then page content should have "Thank you"        
     And  page content should "Kit Total" of "0.00"          

   Scenario: If monitoring charge is configured for installed, User Intake cannot enter "Ready for Approval" status without prorate and recurring credit card charge approved 
     And I am an authenticated user
     And group "default" is a child of group "active_forever"
     And user "demo" has "sales" role for group "active_forever"
     And I select "marketlink" from "Group" #remove this if there is only 1 group and no drop down is displayed      
     And I choose "product_complete"
     And I fill the shipping details for online store
     And I fill the credit card details for online store     
     And I check "Same as shipping"
     And I press "Continue"
     And I press "Place Order"
     And I follow "Skip for later"
     Then page content should have "Thank you"        
     And senior of user intake "12345" has "Ready for Approval" status  #need help to write this           
     
   Scenario: Same as previous Scenario except include 1 month free coupon code 
   
   @wip
   # this relates to the billing reports slated for 1.7.0
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
    And monitoring fee should be charged on the credit card #put in exact amount when coupon codes are rewritten
    And kit fee should not be charged on the credit card
    # Write feature so billing shows up in triage (after panic button press) and somebody clicks it
    And I follow "My Links > Billing"
    And I select "marketlink" from "Group"
    And I select Time.now.strftime("%B") from "Month"
    Then I should see the heading "Receipt"
    And I should see $59 - $30 associated with "Total" for group "sub_dealer" #fix when coupon codes are fixed
    And I should see $49 - $25 associated with "Total" for group "sub_dealer2" #fix when coupon codes are fixed
    And I should see "16.00" associated with "Total" for group "marketlink" #price_mon_bc (sub_dealer) + price_mon_cs (sub_dealer2)
   
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
