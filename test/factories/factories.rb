require "faker"

Factory.define :carrier do |v|
  v.name Faker::Company.name
  v.domain Faker::Internet.domain_name
end

Factory.define :device do |v|
  v.serial_number '1234567890'
  v.active true
end

Factory.define :emergency_number do |v|
  v.name Faker::Company.name
  v.number Faker::PhoneNumber.phone_number
  v.association :group, :factory => :group
end

Factory.define :group do |v|
  v.name Faker::Lorem.words[0]
  v.description Faker::Lorem.sentence
end

Factory.define :profile do |v|
  v.first_name Faker::Name.first_name
  v.last_name Faker::Name.last_name
  v.address Faker::Address.street_address
  v.city Faker::Address.city
  v.state Faker::Address.us_state
  v.zipcode Faker::Address.zip_code
  v.time_zone Time.now.zone
  v.home_phone "1234567890"
  v.cell_phone "1234567890"
  v.account_number "1234"
  v.hospital_number "0987654321"
  v.doctor_phone "1234567890"
  v.association :carrier, :factory => :carrier
  v.association :emergency_number, :factory => :emergency_number
  v.association :user, :factory => :user
end

Factory.define :user do |v|
  v.login Faker::Internet.user_name
  v.password "12345"
  v.password_confirmation "12345"
  v.email Faker::Internet.email
end
