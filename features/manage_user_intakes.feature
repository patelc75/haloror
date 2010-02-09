Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Submit new user_intake with billing same as user
    Given I am on the new user_intake page
	And I click "Same As User" 
    And I press "Submit"
	Then a User with "halouser" role should be created
	And the "halouser" User with a "subscriber" role for the "halouser" User should be created	

  Scenario: Submit new user_intake with billing same as #1 caregiver
    Given I am on the new user_intake page
	And I do not click "Same As User"
	And I click "Add as #1 Caregiver"
	And I click "Email" 
    And I press "Submit"
	Then a User with "halouser" role should be created
	And a separate User with "subscriber" role for the "halouser" User should be created
	And the "subscriber" User should have a "caregiver" role for the "halouser" User
	And the email toggle in the User for "caregiver" role User in caregiver table for the "halouser" should show the email toggled