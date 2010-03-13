# user specific steps
#
include ApplicationHelper

# Given

Given /^a user "([^\"]*)" exists with profile$/ do |user_name|
  profile = Factory.build(:profile)
  profile.user = Factory.build(:user, :login => user_name)
  profile.save
  profile.user.activate
end

Given /^user "([^\"]*)" is activated$/ do |user_name|
  User.find_by_login(user_name).activate
end

Given /^user "([^\"]*)" has "([^\"]*)" role(?:|s)$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  roles = role_name.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  roles.each {|role| user.has_role role}
end

# When

When /^I navigate to caregiver page for "([^\"]*)" user$/ do |user_name|
  visit "call_list/show/#{User.find_by_login(user_name).id}"
end

# Then

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

When /^I simulate a "([^\"]*)" with delivery "([^\"]*)" to the call center for a user with id as "([^\"]*)"$/ do | model, success_or_failure, user_id|
  SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 0, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  model.constantize.create(:timestamp => Time.now-1.minute, :user_id => user_id, :magnitude => 23, :device_id => 965)
  SafetyCareClient.should_receive(:alert).once.and_raise(Timeout::Error)
  DeviceAlert.job_process_crtical_alerts() 
end

Then /^I should have "([^\"]*)" count of "([^\"]*)"$/ do |count, model|
  assert model.constantize.count == count
end

Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center$/ do |model, pending_string|
  assert model.constantize.first.call_center_pending == false, ""
end