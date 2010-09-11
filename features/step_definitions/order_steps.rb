When /^the associated one time charge does not exist for the order$/ do
  pending # express the regexp above with the code you wish you had
end

When /^user "([^"]*)" approves the user intake form associated to last order$/ do |login|
  (user = User.find_by_login( login)).should_not be_blank
  Given %{I am authenticated as "#{user}" with password "12345"}
  When %{I am editing the user intake associated to last order}
  When %{debug}
  When %{I press "Approve"}
end
