Feature: Manage coupon codes
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated user
    And a group "group1" exists
    And the following device_models:
      | part_number | device_type_name |
      | 12001002-1  | Chest Strap      |
    And no coupon codes exist
      
  Scenario: Add a new coupon code
    Given I am creating a coupon code
    When I select "group1" from "Group"
    And I select "12001002-1 -- Chest Strap" from "Device model"
    And I fill in the following:
      | Coupon Code       | cc_160_pq1 |
      | Deposit           | 66         |
      | Shipping          | 6          |
      | Monthly recurring | 77         |
      | Months advance    | 0          |
      | Months trial      | 2          |
    And I press "Save"
    Then I should see "successfully"
    And coupon code "cc_160_pq1" should have a related device model, group
    
  Scenario: Edit coupon code
  