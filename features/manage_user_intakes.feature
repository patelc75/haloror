Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  # Background: Authenticated user
  #   Given I am authenticated as "chirag" with password "chirag"
    
  Scenario: Submit new user_intake with billing same as user
    Given I am authenticated as "chirag" with password "chirag"
     Then I should see "My Links"
     #  And I am creating a user
     # Then I should see "Sign up the myHalo User"
     # When debug
     #  And I select "halo" from "group"
     #  And I check "same_as_user" 
     #       And I press "Submit"
     # Then user "user" should have "halouser" role
     #  And user "halouser" should have "subscriber" role for the "halouser" user

  Scenario: Submit new user_intake with billing same as #1 caregiver
    Given I am authenticated as "chirag" with password "chirag"
      And I am on the new user_intake page
  	  And I "Same As User" is not clicked
     When I click "Add as #1 Caregiver"
  	  And I click "Email" 
      And I press "Submit"
      And I go to call list for user "user"
  	 Then user "user" should have "halouser" role
  	  And user "separateuser" should have "subscriber, caregiver" roles for the "halouser" user
  	  And user "separateuser" should have email toggled for "halouser" user
