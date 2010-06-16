# Given -----------------------------

Given /^user "([^\"]*)" was dismissed yesterday$/ do |user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  TriageAuditLog.create(:user => user, :updated_at => 1.day.ago, :description => "dismissed yesterday")
end

Given /^battery status for "([^\"]*)" is (\d+) percent$/ do |user_login, number|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  Factory.create(:battery, :user => user, :percentage => number.to_i) # should also cache the field
end

Given /^last event for "([^\"]*)" is (.+)$/ do |user_login, event_name|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  event = Factory.create(event_name.underscore.to_sym)
  if event.respond_to?(:user_id)
    event.user_id = user.id
    event.save
  end
  Factory.create(:event, :user => user, :event_type => event_name, :event_id => event.id)
end

Given /^a user intake exists with senior "([^\"]*)"$/ do |user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  ui = Factory.create(:user_intake, :senior => user)
  ui.senior.should == user
end

# When -------------------------

When /^I (dismiss|recall) "([^\"]*)"$/ do |status, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  visit url_for(:controller => 'triage_audit_logs', :action => 'new', :user_id => user.id, :is_dismissed => (status == 'dismiss'))
end

When /^I visit triage for user "([^\"]*)" showing group "([^\"]*)"$/ do |user_login, group_name|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  group = Group.find_by_name(group_name)
  group.should_not be_blank
  
  visit url_for(:controller => 'users', :action => 'triage', :id => user.id, :search_group => group.id)
end

When /^I visit "([^\"]*)" (dismissed|pending) triage for group "([^\"]*)"$/ do |user_login, status, group_name|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  group = Group.find_by_name(group_name)
  group.should_not be_blank

  visit url_for(:controller => 'users', :action => 'triage', :id => user.id, :search_group => group.id, :search_status => status.camelize)
end

# Then --------------------------------

Then /^I should see (.+) alert for "([^\"]*)"$/ do |alert, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  response.should have_tag("div[id=?]", "#{alert}_#{user.id}")
end

Then /^I should see (.+) icon for "([^\"]*)"$/ do |file_name, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  response.should have_tag("img[id=?]", "#{file_name}_#{user.id}")
end

Then /^I should not see any green battery$/ do
  [50,75,100].each {|e| response.body.should_not have_tag("div[class=?]", "battery-width-#{e}") }
  # [50,75,100].each {|e| lambda { response.include?("battery-width-#{e}") }.should be_false }
end

Then /^I should see (\d+) wide (red|yellow|green) battery for "([^\"]*)"$/ do |width, color, user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  response.should have_tag("div[id=?]", "user_#{user.id}_battery_#{color}_#{width}")
end
