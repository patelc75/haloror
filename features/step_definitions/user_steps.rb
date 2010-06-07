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
  user.should_not be_blank
  user.profile.should_not be_blank
end

Given /^user "([^\"]*)" is activated$/ do |user_name|
  User.find_by_login(user_name).activate
end

#Usage:And user "test-user" has "super admin, caregiver" roles
Given /^user "([^\"]*)" has "([^\"]*)" role(?:|s)$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  user.should_not be_blank
  
  roles = role_name.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  roles.each {|role| user.has_role role }
end

Given /^user "([^\"]*)" has "([^\"]*)" roles? for (.+) "([^\"]*)"$/ do |user_name, role_name, model_type, model_name|
  user = User.find_by_login(user_name)
  roles = role_name.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  fields_hash = {'group' => 'name', 'user' => 'login'}
  field = (fields_hash.has_key?(model_type) ? fields_hash[model_type] : 'name')
  roles.each {|role| user.has_role role, model_type.gsub(/ /,'_').classify.constantize.send("find_by_#{field}".to_sym, model_name)}
end

Given /^I am creating admin user$/ do
  visit "/user_admin/new_admin"
end

When /^I visit the events page for "([^\"]*)"$/ do |user_name|
  user = User.find_by_login(user_name)
  user.should_not be_blank
  visit "/events/user/#{user.id}"
end

When /^I navigate to caregiver page for "([^\"]*)" user$/ do |user_name|
  visit "call_list/show/#{User.find_by_login(user_name).id}"
end

When /^I select profile name of "([^\"]*)" from "([^\"]*)"$/ do |user_login, drop_down_id|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  select(user.name, :from => drop_down_id)
end

# roles pattern can be: "caregiver", "caregiver, user, halouser"
# role(s) can be used singular or plural
#
Then /^user "([^\"]*)" should have "([^\"]*)" role(?:|s) for (.+) "([^\"]*)"$/ do |user_name, role_name, model_name, for_model_name|
  user = User.find_by_login(user_name)
  case model_name
  when 'user'
    for_object = User.find_by_login(for_model_name)
  when 'group'
    for_object = Group.find_by_name(for_model_name)
  end
  assert ((role_name.split(',').collect(&:strip)) - user.roles_for(for_object).map(&:name)).blank?
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

When /^I simulate a "([^\"]*)" with delivery to the call center for user login "([^\"]*)" with a "([^\"]*)" "([^\"]*)"$/ do |model, login, valid, error_type|
  user = nil
  user = User.find_by_login(login)
  
  if valid == "invalid"
    case error_type
      when "call center account number" 
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
  SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 0, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  object = model.constantize.create(:timestamp => Time.now-2.minutes, :user_id => user.id, :magnitude => 23, :device_id => 965)
  object.timestamp_server = Time.now-1.minute
  object.send(:update_without_callbacks)
  DeviceAlert.job_process_crtical_alerts()
end

Then /^I should have "([^\"]*)" count of "([^\"]*)"$/ do |count, model| 
  assert model.constantize.count + Event.all.length == 2*count.to_i, "Should have #{count} #{model}"
end

Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center with a "([^\"]*)" call center delivery timestamp$/ do |model, pending_string, timestamp_status|
  critical_alert =  model.constantize.first   
  if pending_string == "not pending"
    assert critical_alert.call_center_pending == false, "#{model} should be not pending"
  elsif pending_string == "pending"
    assert critical_alert.call_center_pending == true, "#{model} should be pending"  
  else
    assert false, "#{pending_string} is not a valid pending status"
  end

  if timestamp_status == "missing"
    assert critical_alert.timestamp_call_center.nil?, "#{model} should have nil timestamp"
  elsif timestamp_status == "valid"
    assert critical_alert.timestamp_call_center > critical_alert.timestamp_server, "#{model} should have timestamp_call_center later than timestamp_server"     
  else
    assert false, "#{timestamp_status} is not a valid timestamp status"
  end  
end

Then /^I should see "([^\"]*)" link for user "([^\"]*)"$/ do |link_text, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  user.profile.should_not be_blank
  
  case link_text
  when "caregiver for"
    senior = user.is_caregiver_for_what.first
    response.should contain("caregiver for (#{senior.id}) #{senior.full_name}")
  when "Caregivers"
    response.should have_tag("a[href=?]", /(.+)call_list\/show\/#{user.id}(.+)/)
  end
end
