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

#When I simulate a "Fall" with delivery to the call center for user id "44" with a "valid" "call center account number"
When /^I simulate a "([^\"]*)" with delivery to the call center for user login "([^\"]*)" with a "([^\"]*)" "([^\"]*)"$/ do |model, login, valid, error_type|
  user = nil
  if valid == "invalid"
    case error_type
      when "call center account number" 
        user = User.find(user_id)
        user.profile.account_number = ""
        user.profile.save
      when "profile"
        user.profile = nil
        user.save
      when "TCP connection"
        #http://rspec.info/documentation/mocks/message_expectations.html
        SafetyCareClient.should_receive(:alert).once.and_raise(Timeout::Error)
      else "Unknown"
    end
  end
  user_id = User.find_by_login(login).id
  SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 0, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  object = model.constantize.create(:timestamp => Time.now-2.minutes, :user_id => user_id, :magnitude => 23, :device_id => 965)
  object.timestamp_server = Time.now-1.minute
  object.save
  DeviceAlert.job_process_crtical_alerts() 
end

Then /^I should have "([^\"]*)" count of "([^\"]*)"$/ do |count, model|
  assert model.constantize.count == count.to_i, "Should have #{count} #{model}"
end

Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center$/ do |model, pending_string|
  if pending_string == "not pending"
    assert model.constantize.first.call_center_pending == false, "#{model} should be not pending"
  elsif pending_string == "pending"
    assert model.constantize.first.call_center_pending == true, "#{model} should be pending"    
  else
    assert false, "#{pending_string} is not a valid pending status"
  end  
end