# user mailer specific steps
#

# Given
#And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be queued

Then /^email to "([^\"]*)" with text "([^\"]*)" should be sent for delivery$/ do |email, subject|
  #assert !Email.count(:conditions => ["`emails`.`to` = ? AND `emails`.'subject' = ?", email, subject]).blank?, "Email to #{email} with subject #{subject} not found"
  found = false
  Email.all(:conditions => '"to" = ' + "'#{email}'").each do |message|
    if message.mail.include?(subject)
      found = true
    end
  end
  #debugger
  assert found == true, "Email to #{email} with text #{subject} not found"
end

