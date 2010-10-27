Feature: Online Store Kit
  In order sell Halo products online to direct customer
  As an administrator
  I want to provide a public online store to direct customers

  Background:
    Given I am an authenticated user
    And the product catalog exists
    And user "demo" has "super admin" role
    And the following groups:
      | name          | sales_type |
      | resellergroup | reseller   |
      | retailergroup | retailer   |
      | regulargroup  |            |
    When I go to the online store

  # https://redmine.corp.halomonitor.com/issues/3170
  Scenario Outline: Reseller, Retailer and Other groups see Kit Serial appropriately
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I select "<group>" from "Group"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "<result>"
    
    Examples:
      | group         | result                    |
      | retailergroup | Kit Serial Number         |
      # (Tue Oct  5 21:36:41 IST 2010)
      #   business logic changed. Only retailer can see kit serial page
      #   http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=2
      # | resellergroup | Kit Serial Number         |
      # | regulargroup  | HALO SUBSCRIBER AGREEMENT |

  # https://redmine.corp.halomonitor.com/issues/3170
  # (Tue Oct  5 20:48:31 IST 2010) Only retailers can see online store kit entry page
  #   http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=2
  Scenario Outline: Force or Optional Kit
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "order_bill_address_same"
    And I select "<group>" from "Group"
    And I press "Continue"
    And I press "Place Order"
    And I fill in "order_kit_serial" with "<kit_serial>"
    And I press "<button>"
    Then page content should have "<result>"
    
    Examples:
      | group         | result                                    | kit_serial | button |
      | retailergroup | HALO SUBSCRIBER AGREEMENT                 | H400000155 | Skip   |
      | retailergroup | HALO SUBSCRIBER AGREEMENT                 | H400000155 | Next   |
      | retailergroup | successfully saved with Kit Serial Number |            | Next   |
      # Thu Sep 23 02:42:22 IST 2010
      # The business logic changed to "allow everyone to skip kit serial number step"