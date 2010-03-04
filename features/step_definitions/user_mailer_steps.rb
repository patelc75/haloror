# user mailer specific steps
#

# Given
#And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be queued

Then /^email to "([^\"]*)" with subject "([^\"]*)" should be sent for delivery$/ do |email, subject|
  Email.all(:conditions => '"to" = ' + "'#{email}'").each do |message|
    assert message.mail.include?(subject), "Email not found ..."
  end
end