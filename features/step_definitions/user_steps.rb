# user specific steps
#
include ApplicationHelper

# ==========
# = givens =
# ==========

# accept multiple comma separated names in one go
Given /^(?:|a )user "([^\"]*)" exists with profile$/ do |user_names|
  user_names.split(',').collect(&:strip).each do |user_name|
    user = Factory.create(:user, :login => user_name, :email => "#{user_name.gsub(' ','_')}@test.com")
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
  user_names = user_names.split(',').collect(&:strip).flatten.uniq
  role_names = role_names.split(',').collect {|p| p.strip.gsub(/ /,'_')}.flatten.uniq
  user_names.each do |user_name|
    find_or_create_user( user_name) # make sure this exist, if not already
    (user = User.find_by_login(user_name)).should_not be_blank
    role_names.each {|role| user.has_role role }
  end
end

# allow multiple users, multiple roles and multiple model objects
Given /^user "([^\"]*)" (?:|has|have) "([^\"]*)" roles? for (.+) "([^\"]*)"$/ do |user_names, role_names, model_type, model_names|
  user_names = user_names.split(',').collect(&:strip)
  role_names = role_names.split(',').collect {|p| p.strip.gsub(/ /,'_')}
  model_names = model_names.split(',').collect(&:strip)
  model_type = model_type.singularize
  fields_hash = {'group' => 'name', 'user' => 'login'}
  field = (fields_hash.has_key?(model_type) ? fields_hash[model_type] : 'name')
  user_names.each do |user_name|
    # we just have email in some cases. no profile or login. so we check for steps by email as well
    user = ( User.find_by_login(user_name) || User.find_by_email( user_name) )
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

Given /^user "([^\"]*)" (.+) in test mode$/ do |user_login, state|
  (user = User.find_by_login(user_login)).should_not be_blank
  # user.update_attributes( :test_mode => (state == 'is')) # user object in memory is still not changed
  user.test_mode = (state == 'is')
  user.save
end

Given /^user "([^\"]*)" status gets changed to "([^\"]*)"$/ do |login, status|
  (user = User.find_by_login( login)).should_not be_blank
  user.status = status
  user.save.should == true
end


# =========
# = whens =
# =========

When /^I am changing the password for "([^"]*)"$/ do |_login|
  (_user = User.find_by_login( _login)).should_not be_blank
  visit "/profiles/change_password_init/#{_user.id}?user_id=#{_user.id}"
end

When /^I activate the "([^\"]*)" senior of last order$/ do |_name|
  (_order = Order.last).should_not be_blank
  (_ui = _order.user_intake).should_not be_blank
  (_user = _ui.senior).should_not be_blank
  visit "/activate/#{_user.activation_code}"
  When "I fill in the following:", table(%{
    | Username         | #{_name} |
    | Password         | #{_name} |
    | Confirm Password | #{_name} |
  })
  When %{I press "subscribe_button"}
end

When /^I activate the last (.+) as "([^\"]*)"$/ do |_user_type, _name|
  When %{I am activating the last #{_user_type} as "#{_name}"}
  When %{I press "subscribe_button"}
end

When /^I am activating the last (.+) as "([^\"]*)"$/ do |_user_type, _name|
  _user = case _user_type
  when 'user'
    User.last
  when 'senior', 'subscriber', 'caregiver1', 'caregiver2', 'caregiver3'
    UserIntake.last.send( _user_type)
  end
  _user.should_not be_blank
  visit "/activate/#{_user.activation_code}"
  When "I fill in the following:", table(%{
    | Username         | #{_name} |
    | Password         | #{_name} |
    | Confirm Password | #{_name} |
  })
end

When /^I create admin of "([^\"]*)" group$/ do |_name|
  When %{I am creating admin of "#{_name}" group}
  When %{I press "subscribe"}
end

When /^I am creating admin of "([^\"]*)" group$/ do |_name|
  # just random groups to check concurrent existance
  Given "the following groups:", table(%{
    | name            | sales_type | description                |
    | bogus1_group    | reseller   | bogus reseller             |
    | retailer1_group | retailer   | retailer_group description |
  })
  Given %{a role "admin" exists}
  When "I go to the home page"
  When %{I follow links "Config > Sign up users with other roles"}
  When %{I select "#{_name}_group" from "Group"}
  When %{I select "admin" from "Role"}
  When "I fill in the following:", table(%{
    | Email      | #{_name}_admin@text.com |
    | First Name | #{_name}_admin          |
    | Last Name  | #{_name}_admin          |
    | Address    | admin address           |
    | City       | admin_city              |
    | State      | admin_state             |
    | Zipcode    | 12345                   |
    | Home Phone | 1234567890              |
    | Work Phone | 1234567890              |
  })
end

When /^I activate and login as the senior of last user intake$/ do
  When %{I am activating the "senior" of last user intake}
  When %{I fill in "user_login" with "myhalouser"}
  When %{I fill in "user_password" with "12345"}
  When %{I fill in "user_password_confirmation" with "12345"}
  When %{I press "subscribe_button"}
  When %{I login as "myhalouser" with password "12345"}
end

When /^I get data in (.+) for user "([^\"]*)"$/ do |model_name, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  model = Factory.build(model_name.singularize.gsub(/ /,'_').to_sym)
  model.user = user # apply in memory
  model.save.should be_true
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

When /^I press "([^\"]*)" within "([^\"]*)" user row$/ do |button, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  within("div#user_#{user.id}") do
    click_button(button)
  end
end

When /^a panic button is delivered after the desired installation date and the user is not in test mode$/ do
  pending # express the regexp above with the code you wish you had
end

# =========
# = thens =
# =========

Then /^last (.+) should be activated$/ do |_user_type|
  _user = case _user_type
  when 'user'
    User.last
  when 'senior', 'subscriber', 'caregiver1', 'caregiver2', 'caregiver3'
    UserIntake.last.send( _user_type)
  end
  _user.should_not be_blank
  _user.should be_activated
end

Then /^user "([^\"]*)" should have data for (.+)$/ do |user_login, method_names|
  methods = method_names.split(',').collect(&:strip).collect(&:to_sym) # array of method names as symbols
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  methods.each {|method| user.send(method).should_not be_blank } # send each method to get not_blank value
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
# https://redmine.corp.halomonitor.com/issues/2755#note-17
# enhanced to support profile model
#
Then /^user "([^\"]*)" (should|should not) have "([^\"]*)" role(?:|s) for (.+) "([^\"]*)"$/ do |user_name, status, role_name, model_name, for_model_name|
  user = (user_name == 'last' ? User.last : ( User.find_by_login(user_name) || User.find_by_email(user_name) ))
  user.should_not be_blank
  case model_name
  when 'user'
    for_object = User.find_by_login(for_model_name)
  when 'group'
    for_object = Group.find_by_name(for_model_name)
  when 'profile'
    for_object = find_profile_user(for_model_name)
  end
  role_name.split(',').collect(&:strip).each do |role|
    # TODO: send method should work here
    # DRY this once it is all green
    if status == 'should'
      user.roles_for(for_object).map(&:name).flatten.should include(role)
    else
      user.roles_for(for_object).map(&:name).flatten.should_not include(role)
    end
  end
end

# role(s) can be used singular or plural
#
Then /^user "([^\"]*)" should have "([^\"]*)" role(?:|s)$/ do |user_name, role_name|
  (user = User.find_by_login(user_name)).should_not be_blank
  
  role_name.split(',').collect(&:strip).flatten.each do |role|
    user.roles.collect(&:name).flatten.should include(role)
  end
  # assert ((role_name.split(',').collect {|p| p.strip}) - user.roles.map(&:name)).blank?
end

# Then /^user "([^\"]*)" should have email switched (on|off) for "([^\"]*)" user$/ do |user_name, status, for_user_name|
#   pending # express the regexp above with the code you wish you had
# end

Then /^I should have "([^\"]*)" for user "([^\"]*)"$/ do |status, login|
  (user = User.find_by_login(login)).should_not be_blank
  user.battery_status.should == status
  # ms = user.battery_status
  # assert ms == status,"No Data"
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

Then /^page content should have user names for "([^\"]*)" within "([^\"]*)"$/ do |csv_data, scope_selector|
  users = []
  logins = csv_data.split(',').collect(&:strip)
  logins.each do |login|
    user = User.find_by_login(login)
    user.should_not be_blank
    users << user
  end
  users.flatten.compact.should_not be_blank
  names = users.collect(&:name).join(',')
  Then %{page content should have "#{names}" within "#{scope_selector}"}
end

# multiple values can be given comma separated in the csv_data
# example:
#   Then I should see "a, b, c" within "userlogin" user row
Then /^I (should|should not) see "([^\"]*)" within "([^\"]*)" user row$/ do |logic, csv_data, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  # WARNING: DIV should be used here, not TR. HTML needs an update but it also had to be within <form>
  data_array = csv_data.split(',').collect(&:strip)
  within("tr#user_#{user.id}") do |scope|
    # dynamically send should or should_not
    data_array.each {|data| scope.send("#{logic.gsub(/ /,'_')}".to_sym, contain(data)) }
  end
end

Then /^I (should|should not) see "([^\"]*)" xpath within "([^\"]*)" user row$/ do |logic, csv_data, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  data_array = csv_data.split(',').collect(&:strip)
  data_array.each do |data|
    within("div#user_#{user.id}") do |scope|
      if logic == 'should'
        scope.should have_xpath( data)
      else
        scope.should_not have_xpath( data)
      end
    end
  end
end

Then /^user "([^\"]*)" should have a recent audit log for status "([^\"]*)"$/ do |login, status|
  (user = User.find_by_login( login)).should_not be_blank
  (log = user.triage_audit_logs.latest).should_not be_blank
  log.status.should == status
end

Then /^I (can|cannot) change the status of user "([^\"]*)" to "([^\"]*)"$/ do |condition, login, status|
  (user = User.find_by_login(login)).should_not be_blank
  # user.update_attributes( :status => status) did not work
  user.status = status
  user.save
  user.status.to_s.should == status.to_s # nil.to_s will be ""
end

Then /^user "([^\"]*)" should have attribute "([^\"]*)"$/ do |login, attribute|
  (user = User.find_by_login( login)).should_not be_blank
  user.attributes.keys.should include( attribute)
end

# ===================================
# = local methods to simplify steps =
# ===================================

def find_or_create_user( login)
  if User.find_by_login( login).blank?
    Factory.create( :user, :login => login) # password would be "12345"
  end
end