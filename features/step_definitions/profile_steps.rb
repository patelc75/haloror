# profile related steps
#
include ApplicationHelper # methods: find_profile_user, split_phrase

Given /^a profile exists for user "([^\"]*)"$/ do |user_login|
  profile = Factory.create(:profile, {:user => User.find_by_login(user_login)})
end

Then /^profile "([^\"]*)" should have "([^\"]*)" role(?:|s) for profile "([^\"]*)" with attributes:$/ do |full_name, role_name, for_full_name, attrs_table|
  Then %{profile "#{full_name}" should have "#{role_name}" role for profile "#{for_full_name}"}
  
  # make hash from cucumber attributes table
  attrs = {}
  attrs_table.raw.each do |(attr, value)|
    sanitized_attr = attr.gsub(/\s+/, "-").underscore
    attrs[sanitized_attr.to_sym] = value
  end
  
  # fetch user, check roles_users_option attributes match
  user = find_profile_user(full_name)
  for_user = find_profile_user(for_full_name)
  roles = split_phrase(role_name, ',')
  roles.each do |role|
    # WARNING: Role table does not have unique names!
    role_tuple = Role.find_by_name_and_authorizable_id(role, for_user.id)
    assert_not_nil role_tuple, "<#{role}> role for <#{for_user.full_name}> is missing."
    roles_user_tuple = user.roles_users.first(:conditions => {:role_id => role_tuple.id})
    assert_not_nil roles_user_tuple, "RolesUsers row of <#{user.full_name}> having <#{role}> role for <#{for_user.full_name}> is missing"
    assert_not_nil roles_user_tuple.roles_users_option, "Role options for user <#{user.full_name}> does not exist!"
  
    options_tuple = roles_user_tuple.roles_users_option # get options data
    tuple_hash = {}
    attrs.keys.each {|k| tuple_hash[k] = options_tuple.send(k).to_s} # generate hash for given attributes only, from option data
    # WARNING: Make sure data types are same for hashes. Hashes need true identical pairs here.
    assert tuple_hash == attrs, "Data: #{tuple_hash.to_yaml} and attributes: #{attrs.to_yaml}" # assert same
  end
end

# profile roles pattern can be: "caregiver", "caregiver, user, halouser"
# profile role(s) can be used singular or plural
#
Then /^profile "([^\"]*)" should have "([^\"]*)" role? for profile "([^\"]*)"$/ do |full_name, role_name, for_full_name|
  Then %{profile "#{full_name}" should exist}
  Then %{profile "#{for_full_name}" should exist}

  user = find_profile_user(full_name)  
  for_user = find_profile_user(for_full_name)
  roles = split_phrase(role_name, ',')
  roles.each do |role|
    assert user.roles_for( for_user).map(&:name).include?(role), "user <#{user.full_name}> does not have <#{role}> role"
  end
end

# profile role(s) can be used singular or plural
#
Then /^profile "([^\"]*)" should have "([^\"]*)" role?$/ do |full_name, role_name|
  Then %{profile "#{full_name}" should exist}
  
  user = find_profile_user(full_name)
  roles = split_phrase(role_name, ',')
  user_roles = user.roles.map(&:name)
  roles.each do |role|
    assert user_roles.include?(role), "User <#{user.full_name}> does not have <#{role}> role"
  end
end

Then /^profile "([^\"]*)" should exist$/ do |full_name|
  user = find_profile_user(full_name)
  assert_not_nil user
  name = split_phrase(full_name)
  assert_equal name[0], user.profile.first_name, "No profile with first name <#{name[0]}>"
  assert_equal name[-1], user.profile.last_name, "No profile with last name <#{name[-1]}>"
end
