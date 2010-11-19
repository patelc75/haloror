# ==========
# = givens =
# ==========

Given /^(?:|a )group "([^\"]*)" exists with group admin$/ do |name|
  Given %{a group "#{name}" exists}
  
  user_name = "admin_of_#{name.gsub(' ','_')}"
  Given %{a user "#{user_name}" exists with profile}
  Given %{user "#{user_name}" has "admin" role for group "#{name}"}
end

Given /^group "([^"]*)" is a child of group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

# =========
# = whens =
# =========

When /^I create a "([^"]*)" (.+) group$/ do |_name, _type|
  # do not create again if this is a part of larger test case
  if Group.find_by_name( "#{_name}").blank?
    When %{I am ready to create a "#{_name}" #{_type} group}
    When %{I press "Save"}
  end
end

When /^I am ready to create a "([^"]*)" (.+) group$/ do |_name, _type|
  When %{I am listing groups}
  When %{I follow "New group"}
  When "I fill in the following:", table(%{
    | Name        | #{_name}          |
    | Description | #{_name}          |
    | Email       | #{_name}@test.com |
  })
  When %{I select "#{_type}" from "Sales Type"}
end
