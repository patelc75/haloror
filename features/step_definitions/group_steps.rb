# givens

Given /^(?:|a )group "([^\"]*)" exists with group admin$/ do |name|
  group = Factory.create( :group, { :name => name })
  group.should_not be_blank
  
  user_name = "admin_of_#{name.gsub(' ','_')}"
  Given %{a user "#{user_name}" exists with profile}
  Given %{user "#{user_name}" has "admin" role for group "#{name}"}
end
