# profile related steps
#

# profile role(s) can be used singular or plural
#
Then /^profile "([^\"]*)" should have "([^\"]*)" role(?:|s)$/ do |full_name, role_name|
  user = User.find_by_login(full_name) unless full_name.include? ' '
  if user.blank?
    name = full_name.split(' ')
    profile = Profile.find_by_first_name_and_last_name(name.first, name.last)
    user = profile.user unless profile.blank?
  end
  user.blank? ? false : ((role_name.split(',').collect {|p| p.lstrip.rstrip}) - user.roles.map(&:name)).blank?
end

# profile roles pattern can be: "caregiver", "caregiver, user, halouser"
# profile role(s) can be used singular or plural
#
Then /^profile "([^\"]*)" should have "([^\"]*)" role(?:|s) for profile "([^\"]*)"$/ do |full_name, role_name, for_full_name|
  user = find_user_or_profile_user(full_name)
  for_user = find_user_or_profile_user(for_full_name)
  (user.blank? || for_user.blank?) ? false : ((role_name.split(',').collect {|p| p.lstrip.rstrip}) - user.roles_for(for_user).map(&:name)).blank?
end


# general methods

def find_user_or_profile_user(full_name)
  user = User.find_by_login(full_name) unless full_name.include? ' '
  if user.blank?
      name = full_name.split(' ')
      profile = Profile.find_by_first_name_and_last_name(name.first, name.last)
      user = profile.user unless profile.blank?
  end if
  user
end