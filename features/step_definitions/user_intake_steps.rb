# steps for user intake form
#

When /^I fill the (.+) details for user intake form$/ do |which|
  prefix = {
    "senior"     => 'user_intake_senior_attributes__profile_attributes',
    "subscriber" => 'user_intake_subscriber_attributes__profile_attributes',
    "caregiver1" => 'user_intake_caregiver1_attributes__profile_attributes',
    "caregiver2" => 'user_intake_caregiver2_attributes__profile_attributes',
    "caregiver3" => 'user_intake_caregiver3_attributes__profile_attributes'
  }
  which = which.gsub(' ','_')
  if prefix.has_key?(which)
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
      When %{I fill in "#{prefix[which]}_#{field}" with "#{value}"}
    end
    #
    # cross_st is only for user profile. but this is not mandatory
    # When %{I fill in "user_profile_cross_st" with "street address"} if which == "senior"
  end
end
