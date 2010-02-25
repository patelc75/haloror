# steps for user intake form
#

When /^I fill the (.+) details for user intake form$/ do |which|
  which = which.gsub(' ','_')
  if ['user_profile', 'subscriber', 'caregiver1', 'caregiver2', 'caregiver3'].include?(which)
    { "first_name"  => "#{which} first name",
      "last_name"   => "#{which} last name",
      "address"     => "#{which} address",
      "city"        => "#{which} city",
      "state"       => "#{which} state",
      "zipcode"     => "22001",
      "home_phone"  => "2120001112",
      "cell_phone"  => "2120001112",
      "work_phone"  => "2120001112",
      "email"       => "#{which}@example.com"}.each do |field, value|
      When %{I fill in "#{which}_#{field}" with "#{value}"}
    end
    #
    # cross_st is only for user profile
    When %{I fill in "user_profile_cross_st" with "street address"} if which == "user_profile"
  end
end
