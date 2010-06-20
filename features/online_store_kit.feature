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

  Scenario Outline: Reseller, Retailer and Other groups see Kit Serial appropriately
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I select "<group>" from "Group"
    And I press "Continue"
    And I press "Place Order"
    Then page content should have "<result>"
    
    Examples:
      | group         | result                    |
      | resellergroup | Kit Serial Number         |
      | retailergroup | Kit Serial Number         |
      | regulargroup  | HALO SUBSCRIBER AGREEMENT |

  Scenario Outline: Force or Optional Kit
    When I choose "product_complete"
    And I fill the shipping details for online store
    And I fill the credit card details for online store
    And I check "Same as shipping"
    And I select "<group>" from "Group"
    And I press "Continue"
    And I press "Place Order"
    And I fill in "myHalo S/N" with "<kit_serial>"
    And I press "<button>"
    Then page content should have "<result>"
    
    Examples:
      | group         | result                               | kit_serial | button |
      | resellergroup | HALO SUBSCRIBER AGREEMENT            |            | Next   |
      | resellergroup | HALO SUBSCRIBER AGREEMENT            | H400000155 | Next   |
      | resellergroup | HALO SUBSCRIBER AGREEMENT            |            | Skip   |
      | resellergroup | HALO SUBSCRIBER AGREEMENT            | H400000155 | Skip   |
      | retailergroup | HALO SUBSCRIBER AGREEMENT            | H400000155 | Next   |
      | retailergroup | Please provide the Kit Serial Number |            | Next   |
