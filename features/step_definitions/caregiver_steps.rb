Given /^I am adding new caregiver for "([^\"]*)"$/ do |senior_name|
  senior = User.find_by_login(senior_name)
  visit "/profiles/new_caregiver_profile/#{senior.id}"
end
