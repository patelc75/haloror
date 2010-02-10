require "faker"

Factory.define :user do |v|
  v.login "demo"
  v.password "12345"
  v.password_confirmation "12345"
  v.email "demo@example.com"
end
