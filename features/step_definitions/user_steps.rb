# user specific steps
#
include ApplicationHelper

# Given

Given /^a user "([^\"]*)" exists with profile$/ do |user_name|
  # profile = Factory.build(:profile)
  # profile.user = Factory.build(:user, :login => user_name)
  # #profile.home_phone = "9178178864"
  # profile.save
  # profile.user.activate
  user = Factory.create(:user, :login => user_name)
  user.activate
end

Given /^user "([^\"]*)" is activated$/ do |user_name|
  User.find_by_login(user_name).activate
end

#Usage:And user "test-user" has "super admin, caregiver" roles
Given /^user "([^\"]*)" has "([^\"]*)" role(?:|s)$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  roles = role_name.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  roles.each {|role| user.has_role role}
end

Given /^user "([^\"]*)" has "([^\"]*)" role(?:|s) for group "([^\"]*)"$/ do |user_name, role_name, group_name|
  user = User.find_by_login(user_name)
  roles = role_name.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  roles.each {|role| user.has_role role, Group.find_by_name(group_name)}
end

When /^I navigate to caregiver page for "([^\"]*)" user$/ do |user_name|
  visit "call_list/show/#{User.find_by_login(user_name).id}"
end

# roles pattern can be: "caregiver", "caregiver, user, halouser"
# role(s) can be used singular or plural
#
Then /^user "([^\"]*)" should have "([^\"]*)" role(?:|s) for user "([^\"]*)"$/ do |user_name, role_name, for_user_name|
  user = User.find_by_login(user_name)
  for_user = User.find_by_login(for_user_name)
  assert ((role_name.split(',').collect {|p| p.strip}) - user.roles_for(for_user).map(&:name)).blank?
end

# role(s) can be used singular or plural
#
Then /^user "([^\"]*)" should have "([^\"]*)" role(?:|s)$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  assert ((role_name.split(',').collect {|p| p.strip}) - user.roles.map(&:name)).blank?
end

Then /^user "([^\"]*)" should have email switched (on|off) for "([^\"]*)" user$/ do |user_name, status, for_user_name|
  pending # express the regexp above with the code you wish you had
end

Then /^I should have "([^\"]*)" for user "([^\"]*)"$/ do |status,login|
  user = User.find_by_login(login)
  ms = user.battery_status
  assert ms == status,"No Data"
end
