# user mailer specific steps
#

# Given
#And email to "cuc_ship@chirag.name" with subject "Please read before your installation" should be queued
Given /^Email dispatch queue is empty$/ do
  Email.delete_all
end

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
#   debugger
#   assert_equal count.to_i, total, "#{total} emails with subject #{subject} found"
# end
