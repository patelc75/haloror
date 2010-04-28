# steps for user intake form
#

When /^I fill the (.+) details for user intake form$/ do |which|
  which = which.gsub(' ','_')
  if ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].include?(which)
    { "first_name"  => "#{which} first name",
      "last_name"   => "#{which} last name",
      "address"     => "#{which} address",
      "city"        => "#{which} city",
      "state"       => "#{which} state",
      "zipcode"     => "22001",
      "home_phone"  => "2120001112",
      "cell_phone"  => "2120001112",
      "work_phone"  => "2120001112"}.each do |field, value|
      When %{I fill in "user_intake_#{which}_attributes__profile_attributes_#{field}" with "#{value}"}
    end
    When %{I fill in "user_intake_#{which}_attributes_email" with "#{which}@example.com"}
    #
    # cross_st is only for user profile. but this is not mandatory
    # When %{I fill in "user_profile_cross_st" with "street address"} if which == "senior"
  end
end
