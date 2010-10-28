# general steps
#
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "scopes"))
# require File.join(File.dirname(__FILE__), "..", "..", "test", "factories", "factories.rb")

# Given

Given /^debug$/ do
  save_and_open_page
  debugger # permanent. required here
end

Given /^I am (?:|an )authenticated(?: user)$/ do
  _login = "demo"
  # debugger
  user = User.find_by_login( _login)
  user = Factory.create(:user, {:login => _login, :password => '12345', :password_confirmation => '12345'}) if user.blank?
  user.activate unless user.activated?
  authenticate( _login, "12345")
  ['Welcome', user.profile.name].each {|e| response.should contain( e) } # successful login?
end

Given /^I am authenticated as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  user = User.find_by_login( login)
  authenticate(login, password)
  ['Welcome', user.profile.name].each {|e| response.should contain( e) } # successful login?
end

Given /^I login as "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  When %{I go to the login page}
  When %{I fill in "Username" with "#{login}"}
  When %{I fill in "Password" with "#{password}"}
  When %{I press "login_button"}
end

Given /^I am (guest|public user|not authenticated)$/ do |user_type|
  Given %{I logout}
end

Given /^I logout$/ do
  visit logout_url
  response.should_not contain('Welcome')
end

Given /^I am an authenticated super admin$/ do
  Given %{I am an authenticated user}
  Given %{user "demo" has "super_admin" role}
end

Given /^the following (.+):$/ do |name, table|
  # # Thu Oct 28 22:47:21 IST 2010
  # # complex steps in pre-quality require the existing data
  # name.gsub(/ /,'_').classify.constantize.delete_all
  #
  # single line statement causes user_intake locked after_save
  # we need to skip_validation to save it and allow "edit"
  #   table.hashes.each {|hash| Factory.build(model.to_s.underscore.to_sym, hash) }
  table.hashes.each do |hash|
    model = Factory.build(name.gsub(/ /,'_').singularize.to_sym)
    model.attributes = hash # apply attributes in memory. helps to apply virtual attributes correctly
    model.skip_validation = true if model.is_a?( UserIntake)
    model.save
    if model.is_a?( UserIntake)
      # now make relations
      model.senior.is_halouser_of model.group
      model.subscriber.is_subscriber_of model.senior
      model.caregiver1.is_caregiver_of model.senior unless model.caregiver1.blank?
      model.caregiver2.is_caregiver_of model.senior unless model.caregiver2.blank?
      model.caregiver3.is_caregiver_of model.senior unless model.caregiver3.blank?
    end
  end
  # model.create!(table.hashes)
end

# Assumption: the model will validate with just the "name" column
# Usage:
#   Given a user exists
#   Given a 
Given /^a (.+) "([^"]*)" exists$/ do |what, name|
  model = Factory.create( what.gsub(' ','').downcase.to_sym, { :name => name })
  model.should_not be_blank
end

Given /^an? (.+) exists with the following attributes:$/ do |name, attrs_table|
  attrs = {}
  attrs_table.raw.each do |(attr, value)|
    sanitized_attr = attr.gsub(/\s+/, "-").underscore
    #
    # if a dynamic expression is included, evaluate that and get the result
    value = (value.split("`").enum_with_index.collect {|p, i| (i%2).zero? ? p.strip : eval(p).to_s }.join(' ').strip) if value.include?("`")
    attrs[sanitized_attr.to_sym] = value
  end
  if attrs.has_key?(:id)
    remove_existing = true # do we have ID?
    attrs.map {|key, value| attrs[key] = value.to_i if key.to_s[-2..-1] == 'id' } # convert to integer if ID
  end
  id = attrs[:id].to_i # fetch ID as integer
  model_const = model_name_to_constant(name)
  model_const.delete(id) if model_const.count(:conditions => {:id => id}) # remove any existing with same ID
  #
  # Factory better be built in memory, attributes applied, then saved. This keep data as intended.
  # Virtual attributes get applied correctly
  model = Factory.build(name.downcase.gsub(/ /,'_').to_sym)
  model.attributes = attrs # apply the attributes
  model.save.should be_true
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
  model = "device model price" if model == "coupon code"
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
  visit url_for( :controller => model.gsub(' ','_').tableize, :action => 'index') # "/#{model.downcase.pluralize.gsub(' ','_')}"
end

# Usage:
#   Given there are no panics, Email, user, user intakes, Device Type, Device Models
Given /^there are no (.+)$/ do |_models|
  _models.split(',').each {|e| e.strip.gsub(' ','_').classify.constantize.send(:delete_all) }
end

# # CHANGED: merge into "there are no ___"
# Given /^there is no data for (.+)$/ do |models|
#   models.split(',').each {|e| e.strip.singularize.camelize.constantize.send(:delete_all) }
# end

# When

When /^I reload(?:| the page)$/ do
  reload
end

When /^I follow links "([^\"]*)"$/ do |links_text|
  links_text.split('>').collect(&:strip).each {|link| click_link(link) }
end

When /^I (edit|delete|show|follow) the (\d+)(?:st|nd|rd|th) (.+)$/ do |action, pos, model_name|
  action_text = (action == "delete" ? "Destroy" : "#{action.capitalize}")
  visit url_for(:controller => model_name.gsub(' ','_').pluralize, :action => 'index') unless model_name == 'row'
  # visit eval("#{model_name.downcase.pluralize.gsub(' ','_')}_path") unless model_name == 'row'
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link action_text
  end
end

When /^I follow "([^"]*)" (?:in|for) the (\d+)(?:st|nd|rd|th) row$/ do |action, pos|
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link action
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

Then /^a (.+) should exist with (.+) "([^"]*)"$/ do |what, column, data|
  what = 'device model price' if what.downcase == 'coupon code'
  row = what.gsub(' ','_').classify.constantize.send( "find_by_#{column}".to_sym, data)
  row.should_not be_blank
  row.send( column.to_sym).should == data
end

Then /^I should see "([^\"]*)" link$/ do |link_text|
  response.should have_tag("a", :text => link_text)
end

Then /^page has the following content visible:$/ do |string|
  string.each do |row|
    assert_have_selector4
  end
end

Then /^I should see the following (.+):$/ do |model, expected_table|
  expected_table.diff!(tableish('table tr', 'td,th'))
end

Then /^page should have a dropdown for "([^\"]*)"$/ do |data_set|
  case data_set
  when "all groups"
    Group.all.each do |group|
      response.should have_tag("select[id=?]", 'group_name') { with_tag("option", :text => group.name) }
    end
  end
end

Then /^page should not have a (.+) button$/ do |which|
  response.should_not contain( which)
end

Then /^the (\d+)(?:st|nd|rd|th) row (should|should not) contain "([^\"]*)"$/ do |pos, state, label|
  within("table tr:nth-child(#{pos.to_i+1})") do |content|
    if state == 'should'
      content.should contain(label)
    else
      content.should_not contain(label)
    end
  end
end

# accepts any ruby expression enclosed in ``
# usage:
#   Then page content should have "Successfully processed at `Time.now`"
Then /^(?:|the )page content (?:|should have) "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect do |part|
    if part.include?("`")
      part.split("`").enum_with_index.collect {|p, i| (i%2).zero? ? p.strip : eval(p).to_s }.join(' ').strip
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

Then /^(?:|the )(?:|page )content (?:should|does) not have "([^\"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect(&:strip)
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should_not contain(text)}
  else
    contents.each {|text| assert_not_contain text}
  end
end

Then /^(?:|the )page content (?:should have|has) "([^"]*)" within "([^"]*)"$/ do |csv_data, scope_selector|
  data_array = csv_data.split(',').collect(&:strip)
  within(scope_selector) do |scope|
    data_array.each {|data| scope.should contain(data) }
  end
end

Then /^(?:|the )page source (?:should have|has) xpath "([^"]*)"$/ do |array_as_text|
  contents = array_as_text.split(',').collect do |part|
    if part.include?("`")
      part.split("`").enum_with_index.collect {|p, i| (i%2).zero? ? p.strip : eval(p).to_s }.join(' ').strip
    else
      part.strip
    end
  end
  contents.each {|text| response.body.should have_xpath(text)}
end


Then /^I should have the following counts of data:$/ do |table|
  table.raw.each do |model_name, count|
    model_name_to_constant(model_name).count.should == count.to_i unless count.blank?
  end
end

Then /^(?:|the )(?:|page )content (?:should have|has) the following:$/ do |text|
  contents = text.collect(&:strip)
  if defined?(Spec::Rails::Matchers)
    contents.each {|text| response.should contain(text)}
  else
    contents.each {|text| assert_contain text}
  end
end

Then /^(?:|the )(?:|page )content (?:should|does) not have the following:$/ do |text|
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

Then /^"([^"]*)" checkbox must be checked$/ do |identifier|
  response.should have_xpath("//input[@id=#{identifier.gsub(' ','_').downcase} and @checked='checked']")
end

Then /^I cannot change the status of user "([^"]*)" to Anything else$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

# General methods

def authenticate(login, password)
  visit login_path
  fill_in "Username", :with => login
  fill_in "Password", :with => password
  click_button "login_button"
end