# givens

Given /^(?:|a )group "([^\"]*)" exists with group admin$/ do |name|
  Given %{a group "#{name}" exists}
  
  user_name = "admin_of_#{name.gsub(' ','_')}"
  Given %{a user "#{user_name}" exists with profile}
  Given %{user "#{user_name}" has "admin" role for group "#{name}"}
end
