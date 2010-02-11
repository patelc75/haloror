# user specific steps
#

Given /^user "([^\"]*)" has "([^\"]*)" role$/ do |user_name, role_name|
  user = User.find_by_login(user_name)
  user.has_role role_name.gsub(/ /,'_')
end