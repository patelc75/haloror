# user mailer specific steps
#

# =========
# = thens =
# =========

# subject|body|content does not matter. we will just check entire email content anyways
#
Then /^(.+) emails? to "([^\"]*)" with (subject|body|content) "([^\"]*)" should be sent for delivery$/ do |_count, email, part, data|
  Email.all.select {|e| e.to == email && e.mail.include?( data) }.length.should == parsed_count( _count)
end

Then /^(.+) email(?:|s) to (.+) of user intake "([^\"]*)" should be sent for delivery$/ do |_count, whom, _serial|
  (ui = UserIntake.find_by_gateway_serial( _serial)).should_not be_blank
  (group = ui.group).should_not be_blank
  (admins = group.has_admins).should_not be_blank
  #
  # collects emails of all admins
  # check: an email each should be delivered to every admin of the selected group
  users = case whom
  when 'admin', 'admins', 'group admin', 'group admins'
    admins
  when 'caregiver', 'caregivers'
    caregivers
  when 'halouser'
    [senior]
  end
  users.collect(&:email).each {|e| Email.count( :conditions => {:to => e}).should == parsed_count(_count) }
end

Then /^(.+) email(?:|s) to "([^\"]*)" should be sent for delivery$/ do |_count, email|
  # either provide an email address, or, write "safety care" or "safety_care" to get "safety_care@myhalomonitor.com"
  # TODO: fix this to check database for the email address
  email = "safety_care@myhalomonitor.com" if ["safety care", "safety_care"].include?( email)
  Email.count( :conditions => { :to => email} ).should == parsed_count(_count)
end

Then /^email with activation code of last user should be sent for delivery$/ do
  (_user = User.last).should_not be_blank
  Email.all.select {|e| e.mail.include?( _user.activation_code) }.length.should > 0
end

def parsed_count( _count)
  case _count
  when 'an'; 1;
  when 'no'; 0;
  else; _count.to_i;
  end
end