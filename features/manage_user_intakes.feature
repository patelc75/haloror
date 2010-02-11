Feature: Manage user_intakes
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Background: Authenticated user
    Given a user "test-user" exists with profile
    And I am authenticated as "test-user" with password "12345"
        
  Scenario: Submit new user_intake with billing same as user
    Given the following groups:
      | name       |
      | halo_group |
    And user "test-user" has "super admin, caregiver" roles
    And I am on new user_intake page
    When I select "halo_group" from "Group"
    And I check "same_as_user" 
    And I fill in the following:
	    | First Name  | myfirstname             |
	    | Last Name   | mylastname              |
	    | Address     | 110, Madison Ave, NY    |
	    | Cross St    | Street 42               |
	    | City        | NY                      |
	    | State       | NY                      |
	    | Zip         | 12201                   |
	    | Home Number | 1-517-123-4567          |
	    | Cell Number | 1-917-123-4567          |
	    | Work Number | 1-212-123-4567          |
	    | Email       | halo_senior@chirag.name |
    And I select "1 Nov 2000" as the "Date of Birth" date
    And I choose "Male"
    And I press "Submit"
    Then profile "myfirstname mylastname" should have "halouser" role
    And profile "myfirstname mylastname" should have "subscriber" role for profile "myfirstname mylastname"

  Scenario: Submit new user_intake with billing same as #1 caregiver
	  Given the following groups:
	    | name       |
	    | halo_group |
	  And user "test-user" has "super admin, caregiver" roles
	  And I am on new user_intake page
	  When I select "halo_group" from "Group"
	  And I check "Add as #1 caregiver" 
	  And I fill in the following within User Information:
	    | First Name  | myfirstname             |
	    | Last Name   | mylastname              |
	    | Address     | 110, Madison Ave, NY    |
	    | Cross St    | Street 42               |
	    | City        | NY                      |
	    | State       | NY                      |
	    | Zip         | 12201                   |
	    | Home Number | 1-517-123-4567          |
	    | Cell Number | 1-917-123-4567          |
	    | Work Number | 1-212-123-4567          |
	    | Email       | halo_senior@chirag.name |
	  And I fill in the following within Billing Information:
	    | First Name  | subscriberfirstname         |
	    | Last Name   | subscriberlastname          |
	    | Address     | 110, Madison Ave, NY        |
	    | Cross St    | Street 42                   |
	    | City        | NY                          |
	    | State       | NY                          |
	    | Zip         | 12201                       |
	    | Home Number | 1-517-123-4567              |
	    | Cell Number | 1-917-123-4567              |
	    | Work Number | 1-212-123-4567              |
	    | Email       | halo_subscriber@chirag.name |
	  And I check "Email" within Billing Information
	  And I select "Yes" from "Do you have key to residence:" within Billing Information
	  And I press "Submit"
	  Then profile "myfirstname mylastname" should have "halouser" role
	  And profile "subscriberfirstname subscriberlastname" should have "subscriber" role for profile "myfirstname mylastname"
	  And profile "subscriberfirstname subscriberlastname" should have "caregiver" role for profile "myfirstname mylastname" with attributes:
		 | email_active | true |
		 | position     | 1    |
		 | is_keyholder | true |
