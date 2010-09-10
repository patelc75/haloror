# givens

Given /^(?:|a )group "([^\"]*)" exists with group admin$/ do |name|
  Given %{a group "#{name}" exists}
  
  user_name = "admin_of_#{name.gsub(' ','_')}"
  Given %{a user "#{user_name}" exists with profile}
  Given %{user "#{user_name}" has "admin" role for group "#{name}"}
end

Given /^group "([^"]*)" is a child of group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end
