Feature: Caregiver profile
  In order to value
  As a role
  I want feature
    
  Scenario: Create caregiver profile
    Given a user "test-user" exists with profile
    And a user "senior-user" exists with profile
    And the following groups:
      | name   |
      | group1 |
    And the following carriers:
      | name    |
      | verizon |
    And I am authenticated as "test-user" with password "12345"
    And user "test-user" has "super_admin" roles
    And user "senior-user" has "halouser" roles for group "group1"
    And I am adding new caregiver for "senior-user"
    When I fill in the following:
      | Username         | cg1        |
      | Password         | cg1        |
      | Confirm Password | cg1        |
      | First Name       | cg1        |
      | Last Name        | cg1        |
      | Address          | cg1        |
      | Cross St         | cg1        |
      | City             | cg1        |
      | State            | cg1        |
      | Zipcode          | 11111      |
      | Home Phone       | 1234567890 |
      | Work Phone       | 1234567890 |
      | Cell Phone       | 1234567890 |
    And I select "verizon" from "profile_carrier_id"
    And I press "submit_caregiver"
    Then I should see "cg1 cg1"
