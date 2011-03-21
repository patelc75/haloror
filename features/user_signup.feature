Feature: Bus user signup
  In order to value
  As a role
  I want feature

  Background:
    Given I am an authenticated super admin
    And a group "mygroup" exists
    And a role "admin" exists

  Scenario: User signup for admin
    When I go to the home page
    And I follow links "Config > Sign up users with other roles"
    And I select "mygroup" from "Group"
    And I select "admin" from "Role"
    And I fill in the following:
      | Email      | admin@chirag.name |
      | First Name | admin_first       |
      | Last Name  | admin_last        |
      | Address    | admin_address     |
      | City       | Chicago           |
      | State      | IL                |
      | Zipcode    | 12345             |
      | Home Phone | 1234567890        |
      | Work Phone | 9876543210        |
    And I press "subscribe"
    Then I should see "Email sent to admin@chirag.name"
    And user "admin@chirag.name" has "admin" role for group "mygroup"
    And 1 email to "admin@chirag.name" with subject "Please activate" should be sent for delivery

  @authentication @4244
  Scenario: Re-send activation email
    Given the product catalog exists
    When I create a coupon code for "mygroup" group
    And I place an online order for "mygroup" group
    And the "halouser" of last user intake is not activated
    When I view the senior of last user intake
    And I follow "Resend Email"
    Then I should see "Activation email sent again"
    And 1 email to halouser of last user intake with subject "Please activate your new myHalo account" should be sent for delivery
    And email with activation code of last user should be sent for delivery
