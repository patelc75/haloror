Given /^I am adding a new caregiver for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  visit "/profiles/new_caregiver_profile/#{user.id}"
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

Then /^I should see section header for caregivers of "([^\"]*)"$/ do |user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  response.should contain("#{user.full_name}'s Caregivers")
end

Then /^I should see (.+) link for all caregivers of "([^\"]*)"$/ do |type, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  user.caregivers.each {|caregiver| response.should have_tag("a[href=?]", /(.+)edit_caregiver_profile\/#{caregiver.profile.id}(.+)/) }
end

Then /^I should not see (.+) link for any caregivers of "([^\"]*)"$/ do |type, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  user.caregivers.each {|caregiver| response.should_not have_tag("a[href=?]", /(.+)edit_caregiver_profile\/#{caregiver.profile.id}(.+)/) }
end

Then /^I should see a dropdown having profile names of "([^\"]*)"$/ do |users_logins|
  users = users_logins.split(',').collect(&:strip).collect {|e| User.find_by_login(e) }
  users.each {|user| response.should have_tag("option[value=?]", user.id) }
  # option[label] not working for some reason. used "value" attribute to verify
end
