Given /^I am adding new caregiver for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  visit "/profiles/new_caregiver_profile/#{user.id}"
end

When /^I see list of caregivers for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  visit "/call_list/show/#{user.id}"
end

Then /^I should see profile name for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  response.should contain(user.name)
end
