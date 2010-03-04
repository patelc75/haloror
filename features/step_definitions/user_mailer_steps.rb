# user mailer specific steps
#

# Given
#And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be queued

Then /^email to "([^\"]*)" with subject "([^\"]*)" should be sent for delivery$/ do |email, subject|
  emails = Email.find(:all, :conditions => '"to" = ' + "'#{email}'")
  emails.each do |e|
    found = e.mail.include?(subject)
  end
end