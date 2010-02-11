# general steps
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "scopes"))

# Givens

Given /^debug$/ do
  save_and_open_page
  debugger
end

Given /^I am (?:an )authenticated(?: user)$/ do
  user = Factory.create(:user)
  user.activate
  authenticate("demo", "12345")
end

Given /^I am authenticated as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  authenticate(login, password)
end

Given /^I am (guest|public user|not authenticated)$/ do |user_type|
  visit logout_url
end

Given /^the following (.+):$/ do |name, table|
  model = if name.include?(' ')
    name.singularize.split(' ').collect(&:capitalize).join.constantize
  else
    name.singularize.capitalize.constantize
  end
  model.delete_all
  model.create!(table.hashes)
end

Given /^an? (.+) exists with the following attributes:$/ do |name, attrs_table|
  attrs = {}
  attrs_table.raw.each do |(attr, value)|
    sanitized_attr = attr.gsub(/\s+/, "-").underscore
    attrs[sanitized_attr.to_sym] = value
  end
  Factory.create(name.downcase.gsub(/ /,'_'), attrs)
end

Given /^(?:|a |an )existing (.+) with (.+) as "([^\"]*)"$/ do |name, col, value|
  model = if name.include?(' ')
    name.singularize.split(' ').collect(&:capitalize).join.constantize
  else
    name.singularize.capitalize.constantize
  end
  model.create!(col => value)
end

Given /^I am (creating|editing) (?:|a|an) (.+)$/ do |action, model|
  list_path = model.downcase.pluralize.gsub(' ','_')
  model_sym = model.downcase.singularize.gsub(' ', '_').to_sym
  action_path = case action
    when "creating"
      "/#{list_path}/new"
    when "editing"
      model = model_sym.singularize.split(' ').collect(&:capitalize).join.constantize.find(:first)
      "/#{list_path}/(#{model.id})/edit"
  end
  visit "#{action_path}"
end

Given /^I am listing (.+)$/ do |model|
  visit "/#{model.downcase.pluralize.gsub(' ','_')}"
end

# Whens

When /^I reload$/ do
  reload
end

When /^I (edit|delete|show) the (\d+)(?:st|nd|rd|th) (.+)$/ do |action, pos, model_name|
  action_text = (action == "delete" ? "Destroy" : "#{action.capitalize}")
  visit "/#{model_name.downcase.pluralize.gsub(' ','_')}" if model_name != 'row'
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link action_text
  end
end

When /^(?:|I )visit "([^\"]*)"$/ do |path|
  visit path
end

When /^I check "([^\"]*)" within "([^\"]*)"$/ do |name, scope_name|
  within scope_of(scope_name) do |scope|
    scope.check name
  end
end

When /^I uncheck "([^\"]*)" within "([^\"]*)"$/ do |name, scope_name|
  within scope_of(scope_name) do |scope|
    scope.uncheck name
  end
end

# Thens

Then /^I should see the following (.+):$/ do |model, expected_table|
  expected_table.diff!(tableish('table tr', 'td,th'))
end

Then /^(?:|the )(?:|page )content should have "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect {|p| p.lstrip.rstrip}
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should contain(text)}
  else
    contents.each {|text| assert_contain text}
  end
end

Then /^(?:|page )content should not have "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect {|p| p.lstrip.rstrip}
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should_not contain(text)}
  else
    contents.each {|text| assert_not_contain text}
  end
end

# General methods

def authenticate(login, password)
  visit login_path
  fill_in "username", :with => login
  fill_in "password", :with => password
  click_button "login"
end