# steps specific to user intake form
#

Then /^user "([^\"]*)" should have "([^\"]*)" role$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  user.roles.map(&:name).include? role_name
end

Then /^user "([^\"]*)" should have "([^\"]*)" role for the "([^\"]*)" user$/ do |user_name, role_name, for_user_name|
  user = User.find_by_login(user_name)
  for_user = User.find_by_login(for_user_name)
  user.has_role? role_name, for_user
end

# Given /^the following user_intakes:$/ do |user_intakes|
#   UserIntake.create!(user_intakes.hashes)
# end
# 
# When /^I delete the (\d+)(?:st|nd|rd|th) user_intake$/ do |pos|
#   visit user_intakes_url
#   within("table tr:nth-child(#{pos.to_i+1})") do
#     click_link "Destroy"
#   end
# end
# 
# Then /^I should see the following user_intakes:$/ do |expected_user_intakes_table|
#   expected_user_intakes_table.diff!(tableish('table tr', 'td,th'))
# end
