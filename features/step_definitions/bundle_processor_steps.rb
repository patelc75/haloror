Given /^the following bundle_processors:$/ do |bundle_processors|
  BundleProcessor.create!(bundle_processors.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) bundle_processor$/ do |pos|
  visit bundle_processors_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following bundle_processors:$/ do |expected_bundle_processors_table|
  expected_bundle_processors_table.diff!(tableish('table tr', 'td,th'))
end
