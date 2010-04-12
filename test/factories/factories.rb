require "faker"

Factory.define :carrier do |v|
  v.name { Faker::Company.name }
  v.domain { Faker::Internet.domain_name }
end

Factory.define :device_model_price do |v|
  v.coupon_code { Faker::Lorem.words[0] }
  v.expiry_date { 2.months.from_now.to_date }
  v.deposit { rand(999) }
  v.shipping { rand(15) }
  v.monthly_recurring { rand(50) }
  v.months_advance { rand(3) }
  v.months_trial { rand(3) }
  v.association :device_model
end

Factory.define :device_model do |v|
  v.part_number "12001002-1" # "myHalo Complete" product
  v.association :device_type
end

Factory.define :device_type do |v|
  v.device_type "Chest Strap" # "myHalo Complete" product
end

Factory.define :device do |v|
  v.serial_number '1234567890'
  v.active true
end

Factory.define :emergency_number do |v|
  v.name { Faker::Company.name }
  v.number { Faker::PhoneNumber.phone_number }
  v.association :group #, :factory => :group
end

Factory.define :gateway do |v|
  v.serial_number { Time.now.to_i }
  v.mac_address "01:23:45:67:89:ab"
  v.vendor { Faker::Company.name }
  v.model { Faker::Lorem.words[0] }
end

Factory.define :group do |v|
  v.name { Faker::Lorem.words[0] }
  v.description { Faker::Lorem.sentence }
end

Factory.define :profile do |v|
  v.first_name { Faker::Name.first_name }
  v.last_name { Faker::Name.last_name }
  v.address { Faker::Address.street_address }
  v.city { Faker::Address.city }
  v.state { Faker::Address.us_state }
  v.zipcode { Faker::Address.zip_code }
  v.time_zone { Time.now.zone }
  v.home_phone "1234567890"
  v.cell_phone "1234567890"
  v.account_number "1234"
  v.hospital_number "0987654321"
  v.doctor_phone "1234567890"
  v.association :carrier #, :factory => :carrier
  v.association :emergency_number #, :factory => :emergency_number
  v.association :user #, :factory => :user
end

Factory.define :rma do |v|
  v.serial_number { rand(9999999999).to_s }
  v.created_at { 5.minutes.ago }
  v.updated_at { Time.now }
  v.completed_on { 1.month.from_now.to_date }
  v.related_rma { rand(9999).to_s }
  v.redmine_ticket { rand(9999).to_s }
  v.service_outage { ['Yes', 'No'][rand(2)] }
  v.comments { Faker::Lorem.sentence }
  v.phone_number { Faker::PhoneNumber.phone_number }
  v.ship_name { Faker::Name.name }
  v.ship_address { Faker::Address.street_address }
  v.ship_city { Faker::Address.city }
  v.ship_state { Faker::Address.us_state }
  v.ship_zipcode rand(99999)
  v.notes { Faker::Lorem.paragraph }
  v.association :created_by, :factory => :user
  v.association :group_id, :factory => :group
  v.association :user_id, :factory => :user
end

Factory.define :user do |v|
  v.login { Faker::Internet.user_name }
  v.password "12345"
  v.password_confirmation "12345"
  v.email { Faker::Internet.email }
end
