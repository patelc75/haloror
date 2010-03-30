# user mailer specific steps
#

# Given
#And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be queued
Given /^Email dispatch queue is empty$/ do
  Email.delete_all
end

Then /^email to "([^\"]*)" with subject "([^\"]*)" should be sent for delivery$/ do |email, subject|
  #assert !Email.count(:conditions => ["`emails`.`to` = ? AND `emails`.'subject' = ?", email, subject]).blank?, "Email to #{email} with subject #{subject} not found"
  found = false
  Email.all(:conditions => '"to" = ' + "'#{email}'").each do |message|
    if message.mail.include?(subject)
      found = true
    end
  end
  assert found == true, "Email to #{email} with subject #{subject} not found"
end

