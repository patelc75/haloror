# steps for user intake
#
Given /^I have a (saved|complete|non-agreed) user intake$/ do |state|
  ui = Factory.create(:user_intake)
  unless state == "complete"
    # usually nullify only submitted_at (works for non-agreed)
    # for "saved", also nullify legal_agreement_ and print flags
    fields = ([:legal_agreement_at, :paper_copy_at] + (state == "saved" ? [:submitted_at] : []))
    fields.each {|field| ui.send("#{field}=", nil) }
    ui.send(:update_without_callbacks) # cannot ui.save
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

Given /^user intake "([^"]*)" belongs to group "([^"]*)"$/ do |kit_serial, group_name|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  ui.should_not be_blank
  
  ui.group = Group.find_by_name( group_name)
  ui.save
end

Given /^I am ready to submit a user intake$/ do
  Given %{a user "ui-test-user" exists with profile}
  Given %{I am authenticated as "ui-test-user" with password "12345"}
  Given %{a group "halo_group" exists}
  Given %{a carrier "verizon" exists}
  Given %{user "ui-test-user" has "super admin, caregiver" roles}
  When %{I am creating a user intake}
  When %{I select "halo_group" from "group"}
  When %{I check "user_intake_no_caregiver_1"}
  When %{I check "user_intake_no_caregiver_2"}
  When %{I check "user_intake_no_caregiver_3"}
  When %{I fill the senior details for user intake form}
  When %{I fill in "user_intake_senior_attributes_email" with "senior@example.com"}
  When %{I select "verizon" from "user_intake_senior_attributes__profile_attributes_carrier_id"}
  When %{I check "Same as User"}
  When %{I fill in "user_intake_kit_serial_number" with "1122334455"}
end

Given /^senior of user intake "([^"]*)" (is|is not) in test mode$/ do |kit_serial, condition|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  ui.should_not be_blank
  
  case condition
  when "is"
    ui.senior.test_mode?.should be_true
  when "is not"
    ui.senior.test_mode?.should be_false
  end
end

Given /^user intake "([^"]*)" does not have the product shipped yet$/ do |kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  ui.shipped_at.should be_blank
end

Given /^senior of user intake "([^"]*)" is at "([^"]*)" status$/ do |kit_serial, status|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.status.should == status
end

Given /^the user intake with kit serial "([^"]*)" is not submitted$/ do |arg1|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  ui.submitted_at.should be_blank
end

When /^I (view|edit) user intake with kit serial (.+)$/ do |action, kit|
  user_intake = (kit == "last" ? UserIntake.last : UserIntake.find_by_kit_serial_number(kit) )
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

When /^user intake with kit serial "([^"]*)" is not submitted$/ do |kit_serial|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  ui.should_not be_blank
  
  ui.submitted_at = nil
  ui.senior.status = nil
  ui.save
  ui.senior.save
  ui.senior.status.should be_blank
end

When /^I bring senior of user intake "([^"]*)" into test mode$/ do |kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  
  senior.set_test_mode( true)
end

When /^I follow "([^"]*)" for the (\d+)st user intake$/ do |identifier, nth|
  When %{I am listing user intakes}
  When %{I follow "#{identifier}" in the #{nth} row}
end

When /^the kit serial for user intake "([^"]*)" is updated to "([^"]*)"$/ do |kit_serial, new_kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  ui.update_attributes( :kit_serial_number => new_kit_serial)
end

When /^the senior of user intake "([^"]*)" gets the device installed$/ do |kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  
  senior.update_attributes( :status => User::STATUS[ :install_pending]) # make it install pending
  # This will trigger status change to "Installed"
  # It also sends an email to admin of the group of which this user in halouser
  Panic.create( :user => senior) # create a panic button test
end

When /^the senior of user intake "([^"]*)" gets the call center number$/ do |kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  (profile = senior.profile).should_not be_blank
  profile.update_attributes( :account_number => "1234")
end

When /^I view the last user intake$/ do
  visit url_for( :controller => "user_intakes", :action => "show", :id => UserIntake.last.id)
end

Then /^last user intake has an? (.+) stamp$/ do |which|
  (ui = UserIntake.last).should_not be_blank
  case which
  when "print"
    ui.paper_copy_at.should_not be_blank
  when "agreement"
    ui.legal_agreement_at.should_not be_blank
  end
end

Then /^user intake "([^"]*)" has status "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^"([^"]*)" is enabled for subscriber of user intake "([^"]*)"$/ do |col_name, kit_serial|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  ui.should_not be_blank
  
  case col_name
  when "card"
    ui.subscriber.should_not be_blank
    ui.credit_debit_card_proceessed.should_not be_blank
  end
end

Then /^"([^"]*)" for user_intake "([^"]*)" is assigned$/ do |col_name, kit_serial|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  
  ui.should_not be_blank
  ui.send( col_name.to_sym).should_not be_blank
end

Then /^senior of user intake "([^"]*)" (is|is not) in test mode$/ do |kit_serial, condition|
  ui = UserIntake.find_by_kit_serial_number( kit_serial)
  ui.should_not be_blank
  
  case condition
  when "should"
    ui.senior.test_mode?.should == true
  when "should not"
    ui.senior.test_mode?.should != true
  end
end

Then /^user intake "([^"]*)" has "([^"]*)" status$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^I see "([^"]*)" for the user intake "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^"([^"]*)" for last user intake is (\d+) days after "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|the )last user intake (has|does not have) (.+)$/ do |condition, what|
  if condition == "has"
    case what
    when "bill monthly value"
      pending
    when "credit card value"
      pending
    when "a recent audit log"
      pending
    end
  else
    case what
    when "credit card value"
      pending
    end
  end
end

Then /^(?:|the )senior of user intake "([^"]*)" has (.+)$/ do |kit, what|
  (ui = UserIntake.find_by_kit_serial_number(kit)).should_not be_blank
  (senior = ui.senior).should_not be_blank

  case what
  when "a status attribute"
    senior.attributes.keys.should include( "status")
  when "pending status"
    senior.status.should be_blank
  end
end

Then /^all caregivers for senior of user intake "([^"]*)" are away$/ do |arg1|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  ui.caregivers.should_not be_blank
  ui.caregivers.each {|e| e.active_for?( senior) }
end

Then /^senior of user intake "([^"]*)" is not a member of "([^"]*)" group$/ do |kit_serial, group_name|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.group_memberships.collect(&name).uniq.should_not include( group_name)
end

Then /^"([^"]*)" for last user intake is (\d+) hours after "([^"]*)"$/ do |arg1, arg2, arg3|
  pending # express the regexp above with the code you wish you had
end

Then /^(.+) emails? to "([^"]*)" with kit serial for user intake "([^"]*)" in (subject|body) should be sent for delivery$/ do |count, email, data, place|
  Email.all.select {|e| e.to == email && e.mail.include?( data) }.length.should == count.to_i
end

Then /^attribute "([^"]*)" of user intake "([^"]*)" has value$/ do |attribute, kit_serial|
  attribute = "credit_debit_card_proceessed" if attribute == "card"
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  ui.send(attribute.to_sym).should_not be_blank
  credit_debit_card_proceessed
end

Then /^I see "([^"]*)" for user intake "([^"]*)"$/ do |arg1, arg2|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  response.should contain( "Audit Log for user #{ui.senior.name}")
end

Then /^user intake "([^"]*)" does not have a status attribute$/ do |kit_serial|
  (ui = UserIntake.find_by_kit_serial_number( kit_serial)).should_not be_blank
  ui.attributes.keys.should_not include( "status")
end
