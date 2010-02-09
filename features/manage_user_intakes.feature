Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Submit new user_intake with billing same as user
    Given I am on the new user_intake page
  	 When I click "Same As User" 
      And I press "Submit"
  	 Then user "user" should have "halouser" role
  	  And user "halouser" should have "subscriber" role for the "halouser" user

  Scenario: Submit new user_intake with billing same as #1 caregiver
    Given I am on the new user_intake page
  	  And I "Same As User" is not clicked
     When I click "Add as #1 Caregiver"
  	  And I click "Email" 
      And I press "Submit"
  	 Then user "user" should have "halouser" role
  	  And user "separateuser" should have "subscriber" role for the "halouser" user
  	  And user "subscriber" should have "caregiver" role for the "halouser" user
  	  And user "subscriber" should have email toggled for "halouser" user

      # not sure what this scenario meant. too many checks in one statement
      #
	    # And the email toggle in the User for "caregiver" role User in caregiver table for the "halouser" should show the email toggled