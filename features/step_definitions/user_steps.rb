# user specific steps
#
include ApplicationHelper

# Given

# accept multiple comma separated names in one go
Given /^(?:|a )user "([^\"]*)" exists with profile$/ do |user_names|
  user_names.split(',').collect(&:strip).each do |user_name|
    user = Factory.create(:user, :login => user_name)
    user.should_not be_blank
    user.id.should_not be_blank
    
    (profile = user.profile).should_not be_blank
    profile.id.should_not be_blank
  end
end

Given /^user "([^\"]*)" is activated$/ do |user_names|
  user_names.split(',').collect(&:strip).each do |user_name|
    User.find_by_login(user_name).activate
  end
end

#Usage:And user "test-user" has "super admin, caregiver" roles
Given /^user "([^\"]*)" has "([^\"]*)" role(?:|s)$/ do |user_names, role_names|
  users = user_names.split(',').collect(&:strip)
  roles = role_names.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  users.each do |user_name|
    roles.each do |role|
      user = User.find_by_login(user_name)
      user.should_not be_blank

      roles.each {|role| user.has_role role }
    end
  end
end

# allow multiple users, multiple roles and multiple model objects
Given /^user "([^\"]*)" has "([^\"]*)" roles? for (.+) "([^\"]*)"$/ do |user_names, role_names, model_type, model_names|
  user_names = user_names.split(',').collect(&:strip)
  role_names = role_names.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  model_names = model_names.split(',').collect(&:strip)
  model_type = model_type.singularize
  fields_hash = {'group' => 'name', 'user' => 'login'}
  field = (fields_hash.has_key?(model_type) ? fields_hash[model_type] : 'name')
  user_names.each do |user_name|
    user = User.find_by_login(user_name)
    user.should_not be_blank
    role_names.each do |role|
      model_names.each do |model_name|
        model_object = model_type.gsub(/ /,'_').classify.constantize.send("find_by_#{field}".to_sym, model_name)
        user.has_role role, model_object
        user.has_role?( role, model_object).should be_true
      end
    end
  end
end

Given /^I am creating admin user$/ do
  visit "/user_admin/new_admin"
end

Given /^call center account number for "([^\"]*)" is "([^\"]*)"$/ do |user_login, number|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  user.profile.account_number = number
  user.profile.save
end

When /^I get data in (.+) for user "([^\"]*)"$/ do |model_name, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  Factory.create(model_name.singularize.gsub(/ /,'_').to_sym, :user => user)
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

Then /^user "([^\"]*)" should have updated cache for (.+)$/ do |user_login, field|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  user.should respond_to(field.to_sym)
  user.send(field.to_sym).should_not be_blank
  user.send(field.to_sym).should > 0
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

Then /^I should have "([^\"]*)" for user "([^\"]*)"$/ do |status,login|
  user = User.find_by_login(login)
  ms = user.battery_status
  assert ms == status,"No Data"
end

# shifted to critical_alert_steps.rb when merged prod-temp to master
# Then /^I should have "([^\"]*)" count of "([^\"]*)"$/ do |count, model| 
#   assert model.constantize.count + Event.all.length == 2*count.to_i, "Should have #{count} #{model}"
# end

# shifted to critical_alert_steps.rb when merged prod-temp to master
# Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center with a "([^\"]*)" call center delivery timestamp$/ do |model, pending_string, timestamp_status|
#   critical_alert =  model.constantize.first   
#   if pending_string == "not pending"
#     assert critical_alert.call_center_pending == false, "#{model} should be not pending"
#   elsif pending_string == "pending"
#     assert critical_alert.call_center_pending == true, "#{model} should be pending"  
#   else
#     assert false, "#{pending_string} is not a valid pending status"
#   end
# 
#   if timestamp_status == "missing"
#     assert critical_alert.timestamp_call_center.nil?, "#{model} should have nil timestamp"
#   elsif timestamp_status == "valid"
#     assert critical_alert.timestamp_call_center > critical_alert.timestamp_server, "#{model} should have timestamp_call_center later than timestamp_server"     
#   else
#     assert false, "#{timestamp_status} is not a valid timestamp status"
#   end  
# end

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
