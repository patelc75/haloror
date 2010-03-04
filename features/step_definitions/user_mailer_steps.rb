# user mailer specific steps
#

# Given
#And email to "cuc_senior@chirag.name" with subject "Please read before your installation" should be queued

Then /^email to "([^\"]*)" with subject "([^\"]*)" should be sent for delivery$/ do |email, subject|
  assert !Email.count(:conditions => {:to => "#{email}", :subject => subject}).blank?, "Subject not found"
end