Given /^I am adding a new caregiver for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  visit "/profiles/new_caregiver_profile/#{user.id}"
end

Then /^I should see profile name (?:for|of) "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  response.should contain(user.name)
end

Then /^I should not see profile name (?:for|of) "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  response.should_not contain(user.name)
end

Then /^I should see "([^\"]*)" link for caregiver "([^\"]*)" of senior "([^\"]*)"$/ do |link_name, caregiver_name, senior_name|
  caregiver = User.find_by_login(caregiver_name)
  caregiver.should_not be_blank
  
  senior = User.find_by_login(senior_name)
  senior.should_not be_blank
  
  roles_user = senior.roles_user_by_caregiver(caregiver)
  roles_user.should_not be_blank
  
  response.should have_tag("a", :href => "/alerts/index/#{roles_user.id}/?senior_id=#{senior.id}")
end
