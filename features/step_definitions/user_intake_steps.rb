# steps for user intake
#
Given /^I have a (saved|complete|non-agreed) user intake$/ do |state|
  ui = Factory.create(:user_intake)
  unless state == "complete"
    # usually nullify only submitted_at (works for non-agreed)
    # for "saved", also nullify legal_agreement_ and print flags
    fields = ([:legal_agreement_at, :paper_copy_at] + (state == "saved" ? [:submitted_at] : []))
    fields.each {|field| ui.send("#{field}=", nil) }
    ui.send(:update_without_callbacks) # cannit "save" here
  end
end

Given /^the "([^"]*)" of last user intake is not activated$/ do |user_type|
  user_intake = UserIntake.last
  user_intake.should_not be_blank
  
  user = user_intake.send(user_type.to_sym)
  user.should_not be_blank
  
  user.make_activation_pending # change the state of user to "activation pending"
  user.errors.should be_blank
end

Given /^I am activating the "([^"]*)" of last user intake$/ do |user_type|
  user_intake = UserIntake.last
  user_intake.should_not be_blank
  
  user = user_intake.send(user_type.to_sym)
  user.should_not be_blank
  
  visit activate_path(:activation_code => user.activation_code, :senior => user_intake.senior.id)
end

When /^I (view|edit) the last user intake$/ do |action|
  user_intake = UserIntake.last
  user_intake.should_not be_blank
  
  visit url_for(:controller => 'user_intakes', :action => (action == 'view' ? 'show' : action), :id => user_intake.id)
end

When /^I am authenticated as "([^\"]*)" of last user intake$/ do |user_type|
  (ui = UserIntake.last).should_not be_blank
  (user = ui.send(user_type.to_sym)).should_not be_blank
  user.activate unless user.activated?
  
  authenticate(user.login, user.login) # user intake creates password same as login
end

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

Then /^last user intake should have an? (.+) stamp$/ do |which|
  (ui = UserIntake.last).should_not be_blank
  case which
  when "print"
    ui.paper_copy_at.should_not be_blank
  when "agreement"
    ui.legal_agreement_at.should_not be_blank
  end
end
