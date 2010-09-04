Feature: Online store group
  In order to value
  As a role
  I want feature

  Background:
    Given the following groups:
      | name   |
      | group1 |
      | group2 |
    And the product catalog exists
    
  Scenario: Guest will not see any groups
    Given I am guest
    When I go to the online store
    Then the page content should not have "group1, group2"

  Scenario: Authenticated user should only see assigned groups
    Given I am an authenticated user
    And user "demo" has "sales" role for group "group1"
    When I go to the online store
    Then I should see "group1"
    And I should not see "group2"

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario: Order has an associated group when completed by authenticated user
    Given I am an authenticated user
    And user "demo" has "sales" role for group "group1"
    When I go to the online store
    And I select "group1" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    And I follow "Skip for later"
    Then page content should have "Thank you"
    And last order should be associated to "group1" group    
    
    
   Scenario: 2 subdealer orders under a MarketLink with verification of amounts on the billing page
    Given a group exists with the following attributes:
      | name | "sub_dealer" | 
      | price_mon_cs | 28.00 |   
    Given a group exists with the following attributes:
      | name | "sub_dealer2" | 
    And a group exists with the following attributes:
      | name | "default" | 
      | price_mon_bc | 25.00 |   
      | price_mon_cs | 30.00 |   
    And a group exists with the following attributes:
      | name | "marketlink" |
      | charge_kit | "invoice_advance"   | 
      | charge_mon | "installed"  |
      | charge_lease | "none"  |
      | grace_lease_days |  |
      | grace_lease_from |  |
      | grace_mon_days |  |
      | grace_mon_from | "never" |       
      | price_mon_bc | 7.50 |   
      | price_mon_cs | 8.50 |   
      | price_lease_bc |  |   
      | price_lease_cs |  |                             
    And I am an authenticated user 
    And group "default" is a child of group "marketlink"   
    And group "sub_dealer" is a child of group "marketlink"
    And group "sub_dealer2" is a child of group "marketlink"
    And user "demo" has "sales" role for group "sub_dealer" and "sub_dealer2" #right syntax?
    When I go to the online store
    And I select "sub_dealer" from "Group"
    And I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I press "Continue"
    And I press "Place Order"
    And I follow "Skip for later"
    Then page content should have "Thank you"
    And last order should be associated to "sub_dealer" group
    And I go to the online store
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
    Then I should see $59 - $30 associated with "Total" for group "sub_dealer" #fix when coupon codes are fixed       
    Then I should see $49 - $25 associated with "Total" for group "sub_dealer2" #fix when coupon codes are fixed         
    Then I should see "16.00" associated with "Total" for group "marketlink" #price_mon_bc (sub_dealer) + price_mon_cs (sub_dealer2)
        
    Scenario: Senior Helpers with verification of amounts on the billing page
     Given a group exists with the following attributes:
       | name | "senior_helpers" | 
       | kit_charge | "invoice_advance"  | 
       | lease_fee_separate | "true" |
       | lease_grace_days | 7 |
       | lease_grace_from | "ship" |
       | monitoring_grace_days |  |
       | monitoring_grace_from | "never" |      
       | monitoring_charge | "invoice_web" |   
       | commission_mon_bc | 9.00 |   
       | commission_mon_cs | 14.00 |   
       | commission_lease_bc | 15.00 |   
       | commission_lease_cs | 15.00 |            
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
     

          