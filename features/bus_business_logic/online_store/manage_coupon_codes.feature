Feature: Manage coupon codes
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated user
    And the following groups:
      | name               |
      | reseller           |
      | retailer           |
      | direct_to_consumer |
    And the following device_models:
      | part_number | device_type_name |
      | 12001002-1  | Chest Strap      |
      | 12001008-1  | Belt Clip        |
    And no coupon codes exist
  
  # https://redmine.corp.halomonitor.com/issues/3542
  Scenario: Listing all coupon codes
    Given the following device_model_prices:
      | coupon_code | device_model_part_number | group_name         | deposit |
      | default     | 12001002-1               | reseller           | 99      |
      | default     | 12001008-1               | reseller           | 199     |
      | default     | 12001002-1               | retailer           | 299     |
      | default     | 12001008-1               | retailer           | 399     |
      | default     | 12001002-1               | direct_to_consumer | 499     |
      | default     | 12001008-1               | direct_to_consumer | 599     |
    When I am listing device model prices
    Then page content should have "99, 199, 299, 399, 499, 599"

  Scenario: Add a new coupon code
    Given I am creating a coupon code
    When I select "reseller" from "Group"
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
  