
Given /^I have some alerts available$/ do
  critical = Factory.create(:alert_group, :group_type => "critical")
  (1..5).each {|e| critical.alert_types << Factory.create(:alert_type, :alert_type => "critical-alert-#{e}") }
  
  non_critical = Factory.create(:alert_group)
  (1..5).each {|e| non_critical.alert_types << Factory.create(:alert_type, :alert_type => "non-critical-alert-#{e}") }
end

When /^I activate (.+) on "([^\"]*)" for "([^\"]*)" caregiven by "([^\"]*)"$/ do |link_type, alert_name, senior_login, caregiver_login|
  lambda { ["email", "text"].include?(link_type) }.should be_true
  
  alert = AlertType.find_by_alert_type(alert_name)
  senior = User.find_by_login(senior_login)
  caregiver = User.find_by_login(caregiver_login)
  roles_user = senior.roles_user_by_caregiver(caregiver)
  
  [alert, senior, caregiver, roles_user].each {|e| e.should_not be_blank }
  
  visit "/alerts/toggle_email/#{alert.id}/?roles_user_id=#{roles_user.id}"
end

Then /^I should see (.+) active for "([^\"]*)"$/ do |link_type, alert_name|
  lambda { ["email", "text"].include?(link_type) }.should be_true
  
  alert = AlertType.find_by_alert_type(alert_name)
  response.should have_tag("img[id=?][src=?]", "alert_email_#{alert.id}", /(.+)call_list-email.gif(.+)/)
end
