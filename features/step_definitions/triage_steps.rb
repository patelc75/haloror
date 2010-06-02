
Given /^user "([^\"]*)" was dismissed yesterday$/ do |user_login|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  TriageAuditLog.create(:user => user, :updated_at => 1.day.ago, :description => "dismissed yesterday")
end

When /^I visit triage for user "([^\"]*)" showing group "([^\"]*)"$/ do |user_login, group_name|
  user = User.find_by_login(user_login)
  user.should_not be_blank
  
  group = Group.find_by_name(group_name)
  group.should_not be_blank
  
  visit url_for(:controller => 'users', :action => 'triage', :id => user.id, :search_group => group.id)
end

When /^I visit the triage for user "([^\"]*)" showing dismissed users for group "([^\"]*)"$/ do |user_login, group_name|
  user = User.find_by_login(user_login)
  user.should_not be_blank

  group = Group.find_by_name(group_name)
  group.should_not be_blank

  visit url_for(:controller => 'users', :action => 'triage', :id => user.id, :search_group => group.id, :search_status => 'Dismissed')
end

Then /^I should not see any green battery$/ do
  [50,75,100].each {|e| response.body.should_not have_tag("div[class=?]", "battery-width-#{e}") }
  # [50,75,100].each {|e| lambda { response.include?("battery-width-#{e}") }.should be_false }
end
