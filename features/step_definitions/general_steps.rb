# general steps
#
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "scopes"))

# Given

Given /^debug$/ do
  # save_and_open_page
  debugger
  #emails = Email.all(:select => 'emails.mail').map {|p| puts p.mail[0..270] + "\n" }
end

Given /^I am (?:an )authenticated(?: user)$/ do
  user = Factory.create(:user, {:login => 'demo', :password => '12345', :password_confirmation => '12345'})
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
  # single line statement causes user_intake locked after_save
  # we need to skip_validation to save it and allow "edit"
  #   table.hashes.each {|hash| Factory.build(model.to_s.underscore.to_sym, hash) }
  table.hashes.each do |hash|
    model = Factory.build(model.to_s.underscore.to_sym, hash)
    model.skip_validation = true if model.is_a?(UserIntake)
    model.save
  end
  # model.create!(table.hashes)
end

Given /^an? (.+) exists with the following attributes:$/ do |name, attrs_table|
  attrs = {}
  attrs_table.raw.each do |(attr, value)|
    sanitized_attr = attr.gsub(/\s+/, "-").underscore
    attrs[sanitized_attr.to_sym] = value
  end
  if attrs.has_key?(:id)
    remove_existing = true # do we have ID?
    attrs.map {|key, value| attrs[key] = value.to_i if key.to_s[-2..-1] == 'id' } # convert to integer if ID
  end
  id = attrs[:id].to_i # fetch ID as integer
  model_const = model_name_to_constant(name)
  model_const.delete(id) if model_const.count(:conditions => {:id => id}) # remove any existing with same ID
  Factory.create(name.downcase.gsub(/ /,'_'), attrs) # create now
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

Given /^I do not have any (.+)$/ do |models|
  models.split(',').each {|e| e.strip.singularize.camelize.constantize.send(:delete_all) }
end

# When

When /^I reload$/ do
  reload
end

When /^I (edit|delete|show) the (\d+)(?:st|nd|rd|th) (.+)$/ do |action, pos, model_name|
  action_text = (action == "delete" ? "Destroy" : "#{action.capitalize}")
  visit eval("#{model_name.downcase.pluralize.gsub(' ','_')}_path") unless model_name == 'row'
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link action_text
  end
end

When /^(?:|I )visit "([^\"]*)"$/ do |path|
  visit path
end

When /^(?:|I )fill in "([^\"]*)" with "([^\"]*)" within "([^\"]*)"$/ do |field, value, selector|
  within(scope_of(selector)) do |scope|
    scope.fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in "([^\"]*)" for "([^\"]*)" within "([^\"]*)"$/ do |value, field, selector|
  within(scope_of(selector)) do |scope|
    scope.fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in the following within "([^\"]*)":$/ do |scope, fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}" within "#{scope}"}
  end
end

When /^I check "([^\"]*)" within "([^\"]*)"$/ do |name, selector|
  within scope_of(selector) do |scope|
    scope.check name
  end
end

When /^I uncheck "([^\"]*)" within "([^\"]*)"$/ do |name, selector|
  within scope_of(selector) do |scope|
    scope.uncheck name
  end
end

When /^(?:|I )select the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    When %{I select "#{value}" from "#{name}"}
  end
end

# Then

Then /^page has the following content visible:$/ do |string|
  string.each do |row|
    assert_have_selector4
  end
end

Then /^I should see the following (.+):$/ do |model, expected_table|
  expected_table.diff!(tableish('table tr', 'td,th'))
end

Then /^the (\d+)(?:st|nd|rd|th) row should contain "([^\"]*)"$/ do |pos, label|
  within("table tr:nth-child(#{pos.to_i+1})") do |content|
    content.should contain(label)
  end
end

# accepts any ruby expression enclosed in ``
# usage:
#   Then page content should have "Successfully processed at `Time.now`"
Then /^(?:|the )(?:|page )content should have "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect do |part|
    if part.include?("`")
      part.split("`").enum_with_index.collect {|p, i| (i%2).zero? ? p.strip : eval(p).strip }.join(' ')
    else
      part.strip
    end
  end
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should contain(text)}
  else
    contents.each {|text| assert_contain text}
  end
end

Then /^(?:|the )(?:|page )content should not have "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect(&:strip)
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should_not contain(text)}
  else
    contents.each {|text| assert_not_contain text}
  end
end

Then /^I should have the following counts of data:$/ do |table|
  table.raw.each do |model_name, count|
    model_name_to_constant(model_name).count.should == count.to_i unless count.blank?
  end
end

Then /^(?:|the )(?:|page )content should have the following:$/ do |text|
  contents = text.collect(&:strip)
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should contain(text)}
  else
    contents.each {|text| assert_contain text}
  end
end

Then /^(?:|the )(?:|page )content should not have the following:$/ do |text|
  contents = text.collect(&:strip)
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should_not contain(text)}
  else
    contents.each {|text| assert_not_contain text}
  end
end

Then /^(?:|the )page has no rails trace$/ do
  text = "Full trace"
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