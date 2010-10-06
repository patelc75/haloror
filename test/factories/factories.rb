require "faker"
require "digest/md5"
require "factory_girl"

Factory.define :group do |v|
  v.name { Faker::Lorem.words[0] + (Time.now.to_i + rand(9999999999)).to_s }
  v.description { Faker::Lorem.sentence }
end

Factory.define :alert_type do |v|
  v.alert_type { Faker::Lorem.words[0] }
  v.phone_active { rand(1) == 1 }
  v.email_active { rand(1) == 1 }
  v.text_active { rand(1) == 1 }
  v.deprecated { rand(1) == 1 }
end

Factory.define :alert_group do |v|
  v.group_type { Faker::Lorem.words[0] }
end

Factory.define :battery do |v|
  v.timestamp { Time.now.to_s }
  v.percentage { rand(100) }
  v.time_remaining {|e| e.percentage }
  v.acpower_status { rand(1) == 1 }
  v.charge_status { rand(1) == 1 }
  v.association :user
  v.association :device
end

Factory.define :battery_plugged do |v|
  v.percentage { rand(100) }
  v.time_remaining { rand(500) }
  v.association :device
  v.association :user
end

Factory.define :carrier do |v|
  v.name { Faker::Company.name }
  v.domain { Faker::Internet.domain_name }
end

Factory.define :device_type do |v|
  v.device_type "Chest Strap" # { Faker::Lorem.words[0] } # "Chest Strap"
end

Factory.define :device_model do |v|
  v.part_number "12001002-1" # { Faker::PhoneNumber.phone_number.to_i.to_s } # "12001002-1"
  v.association :device_type
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
  v.association :group
end

Factory.define :device do |v|
  #
  # Need a 10 digit serial_number
  v.serial_number { Time.now.to_i.to_s.ljust( 10, "0") }
  v.active true
end

Factory.define :device_available_alert do |v|
  v.association :device
  v.priority { rand(99) }
end

Factory.define :device_unavailable_alert do |v|
  v.association :device
end

Factory.define :dial_up do |v|
  
end

Factory.define :emergency_number do |v|
  v.name { Faker::Company.name }
  v.number { Faker::PhoneNumber.phone_number }
  v.association :group
end

Factory.define :event do |v|
  v.event_type { ['BatteryPlugged', 'DeviceAvailableAlert', 'DeviceUnavailableAlert',
    'GatewayOfflineAlert', 'GatewayOnlineAlert', 'StrapFastened', 'StrapRemoved', 'Dialup'][rand(7)] }
  v.association :user
end

Factory.define :gateway do |v|
  v.serial_number { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  v.mac_address "rand(99):rand(99):rand(99):rand(99):rand(99):ab"
  v.vendor { Faker::Company.name }
  v.model { Faker::Lorem.words[0] }
end

Factory.define :gateway_offline_alert do |v|
  v.association :device
end

Factory.define :gateway_online_alert do |v|
  v.association :device
end

Factory.define :panic do |v|
  v.timestamp { Time.now }
  v.duration_press { rand(10) }
  v.timestamp_call_center { [Time.now, nil][rand(1)] }
  v.call_center_pending {|panic| panic.timestamp_call_center.blank? }
  v.timestamp_server { Time.now }
  v.association :user
  v.association :device
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
  # v.association :user #, :factory => :user
end

Factory.define :rma do |v|
  v.serial_number { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") } # { rand(9999999999).to_s }
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
  v.association :group
  v.association :user
end

Factory.define :strap_fastened do |v|
  v.association :device
  v.association :user
end

Factory.define :strap_removed do |v|
  v.association :device
  v.association :user
end

Factory.define :triage_audit_log do |v|
  v.association :user
  v.is_dismissed { rand(1) == 1 }
  v.description { Faker::Lorem.paragraph }
end

Factory.define :user do |v|
  v.login { Faker::Internet.user_name + Digest::MD5.hexdigest(Time.now.to_s)[0..20] }
  v.salt { |user| Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.login}--") }
  v.crypted_password { |user| Digest::SHA1.hexdigest("--#{user.salt}--12345--") }
  v.email {|u| "#{u.login}@example.com" } # pre-defined domain used in some tests
  v.test_mode true # default is true
  v.association :profile
  # # WARNING: do not use v.association or v.profile syntax here.
  # # if you do, cucumber complications happen and scenarios will fail randomly for no valid visible reason
  # v.after_build do |user|
  #   user.profile {|e| Profile.find_by_user_id(e.id) || Factory.build(:profile) }
  # end
  # v.after_create do |user|
  #   user.profile {|e| Profile.find_by_user_id(e.id) || Factory.create(:profile, :user_id => e.id) }
  #   user.save
  # end
  v.after_create {|user| user.activate }
end

Factory.define :user_intake do |v|
  v.installation_datetime { 1.month.from_now }
  v.association :created_by, :factory => :user
  v.association :updated_by, :factory => :user
  v.bill_monthly { rand(1) == 1 }
  v.credit_debit_card_proceessed { |ui| !ui.bill_monthly } # reverse of the other field
  v.kit_serial_number { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  v.gateway_serial { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  v.transmitter_serial { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  v.submitted_at { Time.now }
  v.paper_copy_at { Time.now }
  v.legal_agreement_at { Time.now }
  v.association :group
  v.subscriber_is_user { rand(1) == 1 }
  v.subscriber_is_caregiver { rand(1) == 1 }
  (1..3).each { |e| v.send("no_caregiver_#{e}".to_sym, false) }
  ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user|
    # v.send("#{user}".to_sym, Factory.create(:user))
    v.association user.to_sym, :factory => :user
  end
  v.after_create do |ui|
    # ui.skip_validation = true # we need "edit" links in list
    # ui.update_attribute(:locked, false) # 3215: do not force this attribute update
    ui.senior.is_halouser_of ui.group
    ui.subscriber.is_subscriber_of ui.senior
    ui.caregiver1.is_caregiver_of ui.senior
    ui.caregiver2.is_caregiver_of ui.senior
    ui.caregiver3.is_caregiver_of ui.senior
  end
  # v.after_save   {|ui| user_intake_users(ui) }
  # v.after_create  {|ui| user_intake_users(ui); ui.update_attribute(:locked, false) }
  # v.after_stub    {|ui| user_intake_users(ui) }
end

Factory.define :vital do |v|
  v.timestamp { Time.now }
  v.association :user
end

# methods -------------------

def user_intake_users(ui)
  unless ui.nil?
    ui.skip_validation = true # we need "edit" links in list
    ui.senior.is_halouser_of ui.group
    ui.subscriber.is_subscriber_of ui.senior
    ui.caregiver1.is_caregiver_of ui.senior
    ui.caregiver2.is_caregiver_of ui.senior
    ui.caregiver3.is_caregiver_of ui.senior
  end
end