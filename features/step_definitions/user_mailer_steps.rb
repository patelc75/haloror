# user mailer specific steps
#

# Given

# CHANGED:
#   Given there are no emails
# #And email to "cuc_ship@chirag.name" with subject "Please read before your installation" should be queued
# Given /^Email dispatch queue is empty$/ do
#   Email.delete_all
# end

# subject|body|content does not matter. we will just check entire email content anyways
#
Then /^(.+) emails? to "([^\"]*)" with (subject|body|content) "([^\"]*)" should be sent for delivery$/ do |count, email, part, data|
  #assert !Email.count(:conditions => ["`emails`.`to` = ? AND `emails`.'subject' = ?", email, subject]).blank?, "Email to #{email} with subject #{subject} not found"
  # found = false
  # Email.all(:conditions => '"to" = ' + "'#{email}'").each do |message|
  #   if message.mail.include?(subject)
  #     found = true
  #   end
  # end
  # # no need to check "found"
  if defined?(Spec::Rails::Matchers)
    # found.should == (count.to_i > 0) # when "zero", this is false, otherwise true
    Email.all.select {|e| e.to == email && e.mail.include?( data) }.length.should == count.to_i
  else
    # assert found == true, "Email to #{email} with subject #{subject} not found"
    assert_equal count.to_i, Email.all.select {|e| e.to == email && e.mail.include?( data) }.length
  end
end

Then /^(.+) email(?:|s) to (.+) of user intake "([^\"]*)" should be sent for delivery$/ do |count, whom, _serial|
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
  users.collect(&:email).each {|e| Email.count( :conditions => {:to => e}).should > 0 }
end

Then /^(.+) email(?:|s) to "([^\"]*)" should be sent for delivery$/ do |count, email|
  #
  # either provide an email address, or, write "safety care" or "safety_care" to get "safety_care@myhalomonitor.com"
  email = "safety_care@myhalomonitor.com" if ["safety care", "safety_care"].include?( email)
  Email.count( :conditions => { :to => email} ).should == count.to_i
end

# merged into step definition above
#
# And 1 email with subject "Please read before you installation" should be sent for delivery
# Then /^(\d+) email with subject "([^\"]*)" should be sent for delivery$/ do |count,subject|
#   total = 0
#   Email.find(:all).each do |message|
#     if message.mail.include?(subject)
#       total += 1
#     end
#   end
#   assert_equal count.to_i, total, "#{total} emails with subject #{subject} found"
# end

Then /^email with activation code of last user should be sent for delivery$/ do
  (_user = User.last).should_not be_blank
  Email.all.select {|e| e.mail.include?( _user.activation_code) }.length.should > 0
end
