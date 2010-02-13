Feature: Bestbuy retail store
  In order to buy the Halo products in retail
  As an authenticated user
  I want the store for retail product

  # General assumptions
  #   1.  A user can buy the product either as myHaloUser or Caregiver, not both
  #       A set os radio buttons are more appropriate than checkboxes
  
  Background: Purchase product on bestbuy store
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
    And the following groups:
      | name | halo-group |
    And I navigate to the bestbuy store
    When I fill in the following:
      | Kit Serial Number | 1234567              |
      | Name              | myhalouser name      |
      | Shipping address  | AL-address           |
      | City              | AL-city              |
      | Street            | AL-street            |
      | Zip               | 122001               |
      | Phone             | +91-212-234-4567     |
      | Email             | retail_user@halo.com |
      | Card number       | 4111111111111111     |
      | CSC               | 123                  |
      | Comments          | Just some comments   |
    And I select "3 Jan 2012" as "Expiration" date
    And I select "halo-group" from "Group"

  Scenario: User purchases retail product for self
    When I choose "Same as myHalo user"
    And I press "Continue"
    Then page should show the following text:
      """
      Thank you myhalouser name for purchasing myHalo Kit
      Your recurring monthly charge will be $59.00/mo and will begin immediately
      We have sent you a confirmation on your email address retail_user@halo.com
      """
      # each row is a phrase appears somewhere on the page
      # not necessarily in the same order or appearance or template
    And profile "myhalouser name" should have "halouser" role
    And profile "myhalouser name" should have "subscriber" role for profile "myhalouser name"

  Scenario: User purchases retail product as caregiver
    When I choose "Add as caregiver"
    And I press "Continue"
    Then page should show the following text:
      """
      Thank you myhalouser name for purchasing myHalo Kit
      Your recurring monthly charge will be $59.00/mo and will begin immediately
      We have sent you a confirmation on your email address retail_user@halo.com
      """
    And profile "myhalouser name" should have "subscriber, caregiver" roles for profile "myhalouser name"
