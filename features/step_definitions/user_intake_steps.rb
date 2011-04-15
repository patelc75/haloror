
# ==========
# = givens =
# ==========

Given /^I have a (saved|complete|non-agreed) user intake$/ do |state|
  ui = Factory.build(:user_intake)
  ui.skip_validation = ( state = 'saved') # skip validation means "save" state
  unless state == "complete"
    # usually nullify only submitted_at (works for non-agreed)
    # for "saved", also nullify legal_agreement_ and print flags
    fields = ([:legal_agreement_at, :paper_copy_submitted_on] + (state == "saved" ? [:submitted_at] : []))
    fields.each {|field| ui.send("#{field}=", nil) }
  end
  ui.save.should be_true # send(:update_without_callbacks) # cannot ui.save
end

Given /^the "([^"]*)" of last user intake (is|is not) activated$/ do |_role, _condition|
  (_ui = UserIntake.last).should_not be_blank
  (_user = _ui.send( _role.gsub(/ /,'_').to_sym)).should_not be_blank
  Given %{user "#{_user.login || _user.email}" #{_condition} activated}
end

Given /^I am activating the "([^"]*)" of last user intake$/ do |user_type|
  user_intake = UserIntake.last
  user_intake.should_not be_blank

  user = user_intake.send(user_type.to_sym)
  user.should_not be_blank

  visit activate_path(:activation_code => user.activation_code, :senior => user_intake.senior.id)
end

Given /^user intake "([^"]*)" belongs to group "([^"]*)"$/ do |_serial, group_name|
  ui = UserIntake.find_by_gateway_serial( _serial)
  ui.should_not be_blank

  ui.skip_validation = true
  ui.group = Group.find_by_name( group_name)
  ui.save.should be_true
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
  When %{I fill in "user_intake_gateway_serial" with "1122334455"}
end

Given /^(?:|the )senior of user intake "([^"]*)" (is|is not) in test mode$/ do |_serial, condition|
  ui = UserIntake.find_by_gateway_serial( _serial)
  ui.should_not be_blank

  ui.senior.set_test_mode!( condition == "is")
end

Given /^the senior of last user intake is not in test mode$/ do
  (ui = UserIntake.last).should_not be_blank
  ui.senior.should_not be_blank
  ui.senior.test_mode?.should be_false
end

Given /^senior of user intake "([^"]*)" has profile$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  Factory.create( :profile, :user_id => senior.id).should be_true
  ui.senior.profile.should_not be_blank
end

Given /^user intake "([^"]*)" does not have the product shipped yet$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.shipped_at.should be_blank
end

Given /^(?:|the )senior of user intake "([^"]*)" (has|is at|should be) "([^"]*)" status$/ do |_serial, condition, status|
  ui = ( _serial == 'last' ? UserIntake.last : UserIntake.find_by_gateway_serial( _serial))
  ui.should_not be_blank
  (senior = ui.senior).should_not be_blank
  ui.skip_validation = true
  ui.submitted_at = (status.blank? ? nil : Time.now)
  ui.save.should be_true # send( :update_without_callbacks)
  senior.status = status
  senior.save.should be_true # send( :update_without_callbacks)
  senior.reload
  senior.status.should == status
end

Given /^(?:|the )user intake "([^"]*)" (is|is not) submitted$/ do |_serial, _is|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = true
  ui.submitted_at = (_is == "is" ? 2.days.ago : nil)
  ui.save.should be_true # send( :update_without_callbacks)
  ui.senior.status = "" # make it pending
  ui.senior.save.should be_true # send( :update_without_callbacks)
  ui.reload
  if _is == "is"
    ui.submitted_at.should_not be_blank
  else
    ui.submitted_at.should be_blank
  end
  ui.senior.status.should be_blank
end

Given /^credit card is charged in user intake "([^"]*)"$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.credit_debit_card_proceessed = true
  ui.skip_validation = true
  ui.save.should == true
end

Given /^desired installation date for user intake "([^"]*)" is in (\d+) hours$/ do |_serial, value|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.installation_datetime = (Time.now + value.to_i.hours)
  ui.skip_validation = true
  ui.save.should be_true
end

Given /^(.+) for user intake "([^"]*)" was (\d+) days ago$/ do |what, _serial, span|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank

  case what
  when 'desired installation date', 'monitoring grace period with ship date'
    ui.installation_datetime = span.to_i.days.ago

    (group = ui.group).should_not be_blank
    group.grace_mon_days = 0
    group.save.should be_true
    ui.shipped_at = span.to_i.days.ago
  end
  ui.skip_validation = true
  ui.save.should be_true # send( :update_without_callbacks)
end

Given /^the user intake "([^"]*)" status is "([^"]*)" since past (\d+) day(?:|s)$/ do |_serial, status, count|
  the_date = Time.now - count.to_i.days
  (ui = UserIntake.find_by_gateway_serial(_serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  ui.senior.status = status
  ui.senior.status_changed_at = the_date
  ui.skip_validation = true
  ui.senior.save.should be_true
  ui.senior.add_triage_audit_log( :status => status, :created_at => the_date, :updated_at => the_date).should_not be_blank
end

# credit card value must be checked in a separate step definition
Given /^bill monthly or credit card value are acceptable for user intake "([^"]*)"$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = true
  ui.bill_monthly = true
  ui.save.should be_true
end

# Given /^I am editing the RMA for user intake "([^"]*)"$/ do |_serial|
#   (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
#   (rma = ui.senior.rmas.create( :serial_number => "12345")).should be_true
#   visit url_for( :controller => "rmas", :action => "edit", :id => rma.id)
# end

Given /^RMA for user intake "([^"]*)" discontinues (service|billing) (?:|in )(\d+) (day|day ago)$/ do |_serial, what, span, condition|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  the_date = if (condition == "day")
    Time.now + span.to_i.days
  else
    Time.now - span.to_i.days
  end
  if what == 'service'
    Rma.create( :user_id => ui.senior.id, :serial_number => "12345", :discontinue_service_on => the_date).should be_true
  else
    Rma.create( :user_id => ui.senior.id, :serial_number => "12345", :discontinue_bill_on => the_date).should be_true
  end
end

Given /^we are on or past the desired installation date for senior of user intake "([^"]*)"$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = true
  ui.installation_datetime = Date.today
  ui.save.should be_true
end

Given /^user intake for "([^"]*)" exists$/ do |login|
  (ui = Factory.create( :user_intake)).should_not be_blank
  (user = User.find_by_login(login)).should_not be_blank
  ui.senior = user
  ui.skip_validation = true # when created from order, this might not be fully valid
  ui.save.should be_true
end

Given /^I am editing user intake "([^"]*)"$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  visit url_for( :controller => 'user_intakes', :action => 'edit', :id => ui)
end

# =========
# = whens =
# =========

When /^I edit the last user intake$/ do
  (ui = UserIntake.last).should_not be_blank
  visit url_for( :controller => 'user_intakes', :action => 'edit', :id => ui.id)
end

When /^I send caregiver details for the last user intake$/ do
  (ui = UserIntake.last).should_not be_blank
  ui.senior.should_not be_blank
  visit "/users/send_caregiver_details/#{ui.senior.id}/"
end

When /^user intake "([^"]*)" gets approved$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = true
  ui.senior.status = User::STATUS[ :install_pending]
  ui.save.should be_true
end

When /^panic button test data (is|is not) received for user intake "([^"]*)"$/ do |_state, _serial|
  ui = if (_serial == "last")
    UserIntake.last
  else
    UserIntake.find_by_gateway_serial( _serial)
  end
  ui.should_not be_blank
  (senior = ui.senior).should_not be_blank
  if _state == 'is'
    Factory.create( :panic, {:user => senior}).should be_true
  end
end

When /^I (view|edit) user intake with gateway serial "([^"]*)"$/ do |action, _serial|
  user_intake = UserIntake.find_by_gateway_serial( _serial)
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
    #  
    # 
    #  Wed Nov 10 20:53:17 IST 2010, ramonrails
    #  * we have local columns in user intake for 1.6.0
    # #  Thu Nov  4 01:37:57 IST 2010, ramonrails 
    # #   caregiver options
    # if which =~ /^caregiver/
    #   When %{I check "user_intake_caregiver1_role_options_phone_active"}
    #   When %{I check "user_intake_caregiver1_role_options_email_active"}
    #   When %{I check "user_intake_caregiver1_role_options_text_active"}
    # end
  end
end

When /^I bring senior of user intake "([^"]*)" into test mode$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank

  senior.set_test_mode!( true)
end

When /^I follow "([^"]*)" for the (\d+)st user intake$/ do |identifier, nth|
  When %{I am listing user intakes}
  When %{I follow "#{identifier}" in the #{nth} row}
end

When /^the gateway serial for user intake "([^"]*)" is updated to "([^"]*)"$/ do |_serial, new_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.gateway_serial = new_serial
  ui.skip_validation = true
  ui.save( false)
end

# WARNING: known to fail at panic.save
#   debugging could not reveal any logical reason while 1.6.0 QA. fix pending
When /^the senior of user intake "([^\"]*)" gets the device installed$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank

  senior.status = User::STATUS[ :install_pending] # make it install pending
  senior.send( :update_without_callbacks)
  # This will trigger status change to "Installed"
  # It also sends an email to admin of the group of which this user in halouser
  panic = Panic.new( :user => senior)
  panic.save.should be_true # create a panic button test
end

When /^the senior of user intake "([^\"]*)" gets the call center number$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  (profile = senior.profile).should_not be_blank
  profile.update_attributes( :account_number => "1234")
end

When /^I view the last user intake$/ do
  visit url_for( :controller => "user_intakes", :action => "show", :id => UserIntake.last.id)
end

When /^I view the (senior|subscriber) of last user intake$/ do |_role|
  (ui = UserIntake.last).should_not be_blank
  (_user = ui.send(_role.to_sym)).should_not be_blank
  visit user_path( _user)
end

When /^user intake "([^\"]*)" is submitted again$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = false
  ui.save
end

When /^I update gateway serial for user intake "([^\"]*)" to "([^\"]*)"$/ do |_serial, value|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.skip_validation = true
  ui.gateway_serial = value
  ui.save.should be_true
end

When /^user "([^\"]*)" clicks the "([^\"]*)" button for the subscriber in the associated user intake form$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I am editing the user intake associated to last order$/ do
  (order = Order.last).should_not be_blank
  (ui = order.user_intake).should_not be_blank
  visit url_for( :controller => "user_intakes", :action => "edit", :id => ui.id)
end

When /^the last user intake had the product shipped (\d+) weeks ago$/ do |_time|
  (ui = UserIntake.last).should_not be_blank
  ui.update_attribute( :shipped_at, _time.to_i.weeks.ago).should be_true
end

When /^I start the subscription for the last user intake$/ do
  (ui = UserIntake.last).should_not be_blank
  ui.charge_pro_rata_and_subscription
end

# =========
# = thens =
# =========

Then /^caregiver(\d+) of last user intake should have (.+) opted$/ do |_index, _attribute|
  (ui = UserIntake.last).should_not be_blank
  (_options = ui.send("caregiver#{_index}_role_options")).should_not be_blank
  _options.send(_attribute.to_s).should be_true
end

Then /^"([^\"]*)" is enabled for subscriber of user intake "([^\"]*)"$/ do |col_name, _serial|
  ui = UserIntake.find_by_gateway_serial( _serial)
  ui.should_not be_blank

  case col_name
  when "card"
    ui.subscriber.should_not be_blank
    ui.credit_debit_card_proceessed.should_not be_blank
  end
end

Then /^"([^\"]*)" for user_intake "([^\"]*)" is assigned$/ do |col_name, _serial|
  ui = UserIntake.find_by_gateway_serial( _serial)

  ui.should_not be_blank
  ui.send( col_name.to_sym).should_not be_blank
end

Then /^senior of user intake "([^\"]*)" (should|should not) be in test mode$/ do |_serial, condition|
  ui = if _serial == 'last'
    UserIntake.last
  else
    UserIntake.find_by_gateway_serial( _serial)
  end
  ui.should_not be_blank

  case condition
  when "should"
    ui.senior.test_mode?.should be_true
  when "should not"
    ui.senior.test_mode?.should_not be_true
  end
end

Then /^(senior|subscriber) of last user intake (should|should not) be (.+)$/ do |_who, _condition, _expression|
  (ui = UserIntake.last).should_not be_blank
  (_user = ui.send("#{_who}")).should_not be_blank
  # 
  #   * cases for 'should'
  if _condition == 'should'
    case _expression
    when 'in demo mode'
      _user.demo_mode?.should be_true
    when 'in test mode'
      _user.test_mode?.should be_true
    when 'in vip mode'
      _user.vip.should be_true
    when 'opted in to call center'
      _user.is_halouser_of?( Group.safety_care!).should be_true # member
    when 'opted out of call center'
      _user.is_halouser_of?( Group.safety_care!).should be_false
    when 'subscriber'
      _user.should == ui.subscriber
    when 'caregiver'
      _user.should be_is_caregiver
    when 'caregiver1'
      _user.should == ui.caregiver1
    else
      assert false
    end

    #   * cases for 'should not'
  else
    case _expression
    when 'in demo mode'
      _user.demo_mode?.should be_false
    when 'in test mode'
      _user.test_mode?.should be_false
    when 'in vip mode'
      _user.vip.should be_false
    when 'opted in to call center'
      _user.is_halouser_of?( Group.safety_care!).should be_false
    when 'opted out of call center'
      _user.is_halouser_of?( Group.safety_care!).should be_true # member
    when 'subscriber'
      _user.should_not be_is_subscriber_of( ui.senior)
    when 'caregiver'
      _user.should_not be_is_caregiver
    when 'caregiver1'
      _user.should_not == ui.caregiver1
    when 'caregiver2'
      _user.should_not == ui.caregiver2
    else
      assert false
    end
  end
end

Then /^user intake "([^"]*)" (should|should not) have "([^"]*)" status$/ do |_serial, condition, status|
  ui = (_serial == 'last' ? UserIntake.last : UserIntake.find_by_gateway_serial( _serial))
  ui.should_not be_blank
  ( senior = ui.senior).should_not be_blank
  if condition == "should"
    senior.status.should == status
  else
    senior.status.should != status
  end
end

Then /^I should see "([^"]*)" for the user intake "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then /^(?:|the )last user intake (should|should not) have (.+)$/ do |condition, what|
  (ui = UserIntake.last).should_not be_blank

  if condition == "should"
    case what
    when "a print stamp"
      ui.paper_copy_submitted_on.should_not be_blank
    when "a recent audit log", "an audit log"
      ui.senior.last_triage_audit_log.should_not be_blank
    when "a senior profile"
      ui.senior.should_not be_blank
      ui.senior.profile.should_not be_blank
    when "a status attribute"
      ui.senior.status.should_not be_blank
    when "an agreement stamp"
      ui.legal_agreement_at.should_not be_blank
    when "an invoice"
      ui.senior.invoice.should_not be_blank
    when "bill monthly value"
      ui.bill_monthly.should be_true
    when "credit card value"
      ui.credit_debit_card_proceessed.should be_true
    when 'devices attached'
      [ui.gateway_serial, ui.transmitter_serial].each do |_serial|
        Device.registered?( _serial, ui.senior) unless _serial.blank?
      end
    when 'latest call center account number'
      ui.senior.call_center_account.to_i.should == Profile.last_account_number.to_i
    when 'same subscriber and caregiver1'
      [:subscriber, :caregiver1].each {|e| ui.send( e).should_not be_blank }
      ui.subscriber.should == ui.caregiver1
    when 'separate senior and subscriber'
      [:senior, :subscriber].each {|e| ui.send( e).should_not be_blank }
      ui.senior.should_not == ui.subscriber
    when /^(\d+) users$/
      #  #<MatchData "2 users" 1:"2" 2:"users">
      _count = /^(\d+) (.+)$/.match( what)[1].to_i # match the data pattern and extract as argument 1, 2
      ui.users.length.should == _count
    else
      pending
      # assert false, 'implement this condition'
    end

    #  SHOULD NOT cases
  else
    case what
    when "a status attribute"
      ui.senior.attributes.keys.should_not have( "status")
    when "bill monthly value"
      ui.bill_monthly.should be_false
    when 'caregivers'
      # CHANGED: we cannot check ui.caregivers
      #   because caregivers are instantiated in memory for user_intake UI bug
      #   so we check the total number of users (connected in active record)
      # 
      #  Thu Nov 11 02:00:36 IST 2010, ramonrails
      # we can check after rejecting caregivers with nothing_assigned?
      ui.caregivers.reject(&:nothing_assigned?).should be_blank # just senior and subscriber
    when "credit card value"
      ui.credit_debit_card_proceessed.should be_false
    else
      pending
      # assert false, 'add this condition'
    end
  end
end

Then /^devices "([^\"]*)" should be attached to last user intake$/ do |_serials|
  (ui = UserIntake.last).should_not be_blank
  ui.senior.should_not be_blank
  _serials = _serials.split(',').collect(&:strip).flatten.uniq
  ui.senior.devices.collect(&:serial_number).uniq.should == _serials
end

Then /^(?:|the )senior of user intake "([^"]*)" should have (.+)$/ do |_serial, what|
  ui = UserIntake.find_by_gateway_serial(_serial)
  ui.should_not be_blank
  senior = ui.senior
  senior.should be_valid

  if what == "a status attribute"
    senior.attributes.keys.should include( "status")
  elsif what =~ /status$/
    _status = what.gsub('status','').gsub('"','').strip # .downcase
    if _status == 'pending'
      senior.status.should be_blank
    else
      senior.status.should == _status
    end
  elsif what =~ /^(\d+) devices$/
    senior.devices.length.should == what.split(' ')[0].to_i
  else
    assert false # otherwise, any new step would pass without technically getting covered
  end
end

Then /^subscriber of last user intake is also the caregiver$/ do
  (ui = UserIntake.last).should_not be_blank
  (subs = ui.subscriber).should_not be_blank
  subs.should == ui.caregiver1
  lambda { subs.is_caregiver_of?( ui.senior) }.should be_true
end

# Use: Then caregivers should be away for user intake "12345"
# Then /^all caregivers for senior of user intake "([^"]*)" should be away$/ do |_serial|
# end

Then /^senior of user intake "([^"]*)" should not be a member of "([^"]*)" group$/ do |_serial, group_name|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.group_memberships.collect(&:name).uniq.should_not include( group_name)
end

# WARNING: we accept a blank first_attribute. This is valid in most cases. For example;
#   Then "installation_datetime" for last user intake is 48 hours after "submitted_at"
# * It might not work for other cases
# * Usually the first_attrbute ought to occur "after" second_attribute
#   This allow first_attribute.blank? to generate a valid condition
Then /^"([^"]*)" for last user intake should be (\d+) (hours|days) after "([^"]*)"$/ do |attribute, index, duration, check_attribute|
  (ui = UserIntake.last).should_not be_blank
  first_attribute = ui.send( attribute.to_sym)
  second_attribute = ui.send( check_attribute.to_sym)
  second_attribute.should_not be_blank
  first_attribute.should >= (ui.send( check_attribute.to_sym) + index.to_i.send(duration.to_sym)) unless first_attribute.blank?
end

Then /^(.+) emails? to "([^"]*)" with gateway serial for user intake "([^"]*)" in (subject|body) should be sent for delivery$/ do |count, email, data, place|
  Email.all.select {|e| e.to == email && e.mail.include?( data) }.length.should == count.to_i
end

Then /^attribute "([^"]*)" of user intake "([^"]*)" should have value$/ do |attribute, _serial|
  attribute = "credit_debit_card_proceessed" if attribute == "card"
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.send(attribute.to_sym).should_not be_blank
end

Then /^I should see "([^"]*)" for user intake "([^"]*)"$/ do |arg1, arg2|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  response.should contain( "Audit Log for user #{ui.senior.name}")
end

Then /^user intake "([^"]*)" should not have a status attribute$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.attributes.keys.should_not include( "status")
end

Then /^senior of user intake "([^"]*)" is not a member of "([^"]*)" group$/ do |_serial, group_name|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.group_memberships.collect(&:name).should_not have( group_name)
end

Then /^user intake "([^"]*)" senior should have "([^"]*)" flag ON$/ do |_serial, _attribute|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should be_true
  (senior = ui.senior).should_not be_blank
  senior.send( _attribute.to_sym).should be_true
end

Then /^senior of user intake "([^"]*)" has a recent audit log for status "([^"]*)"$/ do |_serial, status|
  (ui = user_intake_by_gateway( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  (log = senior.last_triage_audit_log).should_not be_blank
  log.status.should == status
end

Then /^user intake "([^"]*)" has "([^"]*)" status$/ do |_serial, status|
  ui = user_intake_by_gateway( _serial)
  ui.senior.status.should == status
end

Then /^the associated user intake must include successful prorate and recurring charges$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^senior of last user intake should have "([^"]*)" status$/ do |status|
  (ui = UserIntake.last).should_not be_blank
  (senior = ui.senior).should_not be_blank
  if status.blank?
    senior.status.should be_blank
  else
    senior.status.should == status
  end
end

# Then /^senior of last user intake should be in (.+)$/ do |_what|
#   (ui = UserIntake.last).should_not be_blank
#   (senior = ui.senior).should_not be_blank
#   case _what
#   when 'demo mode'
#     senior.demo_mode.should be_true
#   when 'vip mode'
#     senior.vip.should be_true
#   else
#     assert false # explicitly implement any required step
#   end
# end

Then /^action button for user intake "([^"]*)" should be colored (.+)$/ do |_serial, color|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.status_button_color.should == color
end

Then /^I should see triage status "([^"]*)" for senior of user intake "([^"]*)"$/ do |status, _serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.alert_status.should == status
end

Then /^last user intake should be read only$/ do
  (ui = UserIntake.last).should_not be_blank
  ui.locked?.should be_true
end

Then /^senior of user intake "([^"]*)" should be opted in to call center$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  senior.group_memberships.should include( Group.safety_care!)
end

Then /^caregivers (should|should not) be away for user intake "([^"]*)"$/ do |condition, _serial|
  ui = ( (_serial == 'last') ? UserIntake.last : UserIntake.find_by_gateway_serial( _serial) )
  ui.should_not be_blank
  (senior = ui.senior).should_not be_blank
  if condition == "should"
    ui.caregivers.each {|e| e.should be_away_for( senior) }
  else
    ui.caregivers.each {|e| e.should be_active_for( senior) }
  end
end

Then /^caregivers of last user intake should be away$/ do
  Then %{caregivers should be away for user intake "last"}
end

Then /^senior of user intake "([^"]*)" is halouser of safety care group$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  lambda { senior.is_halouser_of?( Group.safety_care!) }.should be_true
end

Then /^caregivers of user intake "([^"]*)" are away$/ do |_serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (senior = ui.senior).should_not be_blank
  ui.caregivers.each {|e| e.away_for?( senior).should be_true }
end

Then /^users of last user intake should have (.+)$/ do |_what|
  (ui = UserIntake.last).should_not be_blank
  (senior = ui.senior).should_not be_blank
  subscriber = ui.subscriber
  (caregivers = ui.caregivers) # can be blank
  case _what

  when "appropriate roles"
    lambda { senior.is_halouser_of?( ui.group) }.should be_true
    lambda { subscriber.is_subscriber_of?( senior) }.should be_true unless ui.subscriber.blank?
    caregivers.each {|cg| lambda { cg.is_caregiver_of?( senior) }.should be_true }

  when "valid emails"
    [ui.senior, ui.subscriber, ui.caregivers].flatten.compact.each do |_user|
      _user.email.should_not be_blank unless _user.blank? || _user.new_record? || _user.nothing_assigned?
    end
  else
    assert false # impleemnt everything explicitly
  end
end

Then /^(\d+) users should be associated to last user intake$/ do |_count|
  (ui = UserIntake.last).should_not be_blank
  ui.users.length.should == _count.to_i
end

Then /^(.+) of last user intake (should|should not) have (.+) checked$/ do |_who, _condition, _what|
  (_ui = UserIntake.last).should_not be_blank
  (_user = _ui.send(_who.to_sym)).should_not be_blank
  (_senior = _ui.senior).should_not be_blank
  _attributes = _what.split(',').collect(&:strip)
  _attributes.each do |e|
    if _condition == "should"
      _user.options_attribute_for_senior( _senior, "#{e}_active").should be_true
    else
      _user.options_attribute_for_senior( _senior, "#{e}_active").should_not be_true
    end
  end
end

Then /^last user intake retains its existing panic timestamp$/ do
  (ui = UserIntake.last).should_not be_blank
  ui.senior.panics.length.should == 2
  # 
  #  Thu Feb 10 23:36:51 IST 2011, ramonrails
  #   * WARNING: this may not be appropriate. audits was a better way to check
  # ui.panic_received_at.should == ui.senior.panics.first.timestamp
  ui.panic_received_at.should_not == ui.senior.panics.last.timestamp
  # 
  #  Wed Feb  9 23:29:24 IST 2011, ramonrails
  #   * audit was removed from user intake due to an error
  # ui.audits.last[:changes].keys.should_not include( "installation_datetime")
end

Then /^the last user intake should prorate up to this month$/ do
  (ui = UserIntake.last).should_not be_blank
  if Date.today.day == 1
    ui.pro_rata_end_date.to_date.should == Date.yesterday
  else
    ui.pro_rata_end_date.to_date.should == ((Date.today + 1.month).beginning_of_month.to_date - 1.day)
  end
end

Then /^the last user intake should start subscription from upcoming month$/ do
  (ui = UserIntake.last).should_not be_blank
  if Date.today.day == 1
    ui.subscription_start_date.to_date.should == Date.today
  else
    ui.subscription_start_date.to_date.should == (Date.today + 1.month).beginning_of_month.to_date
  end
end

# Then /^the last user intake does not have any invoice$/ do
#   (_ui = UserIntake.last).should_not be_blank
#   (_senior = _ui.senior).should_not be_blank
#   _senior.invoice.should be_blank
# end

Then /^(.+) email(?:|s) to (.+) of last user intake with (subject|body|content|keyword) "([^\"]*)" should be sent for delivery$/ do |_count, _roles, part, data|
  _logins = _roles.split(',').collect {|e| e.gsub(/ /,'_').strip.to_sym }
  (_ui = UserIntake.last).should_not be_blank
  _emails = _logins.collect do |_login|
    _ui.should respond_to( _login)
    (_user = _ui.send( _login)).should_not be_blank
    _user.email
  end.compact.uniq
  Email.all.select {|e| _emails.include?( e.to) && e.mail.include?( data) }.length.should == parsed_count( _count)
end

Then /^panic warning email (should|should not) be dispatched$/ do |_condition|
  _count = Email.all( :conditions => ["mail LIKE ?", "%Install attempted without approval%"]).length
  if _condition == 'should'
    _count.should > 0
  else
    _count.should == 0
  end
end

Then /^last user intake group should be "([^"]*)"$/ do |_group_name|
  (_ui = UserIntake.last).should_not be_blank
  _ui.group.should_not be_blank
  _ui.group.name.should == _group_name
end

# ============================
# = local methods for DRYness =
# ============================

# TODO: use this at all places now
#
def user_intake_by_gateway( _serial)
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  ui.senior.should_not be_blank
  ui
end
