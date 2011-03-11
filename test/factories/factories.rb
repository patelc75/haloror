require "faker"
require "digest/md5"
require "factory_girl"

Factory.define :group do |v|
  v.name { Faker::Lorem.words[0] + (Time.now.to_i + rand(9999999999)).to_s }
  v.email { Faker::Internet.email }
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

Factory.define :device_revision do |v|
  v.revision "v1-1"
  v.comments { Faker::Lorem.sentence }
  v.association :device_model
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
  v.dealer_install_fee { rand(99) }
  v.association :device_model
  v.association :group
end

Factory.define :device do |v|
  #
  # Need a 10 digit serial_number
  v.serial_number { Time.now.to_i.to_s.ljust( 10, "0") }
  v.active true
  v.association :device_revision
end

Factory.define :device_available_alert do |v|
  v.association :device
  v.priority { rand(99) }
end

Factory.define :device_unavailable_alert do |v|
  v.association :device
end

Factory.define :device_info do |v|
  v.serial_number { |e| e.device.serial_number }
  v.mac_address {  6.times.collect { "%02d" % rand(99) }.join(':') } # "64:97:62:76:78:86"
  v.vendor { Faker::Company.name }
  v.model { Faker::Lorem.words[0] }
  v.device_info_type { Faker::Lorem.words[0] }
  v.hardware_version { "4.times.collect { rand(99).to_s }.join('.')" }
  v.software_version { "4.times.collect { rand(99).to_s }.join('.')" }
  v.software_version_new { rand(1) == 1 }
  v.software_version_current { rand(1) == 1 }
  v.association :device
  v.association :user
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

Factory.define :fall do |v|
  v.timestamp             { 30.minutes.ago }
  v.magnitude             28
  v.timestamp_call_center { 30.minutes.ago }
  v.call_center_pending   true
  v.timestamp_server      { 30.minutes.ago }
  v.gw_timestamp          { 30.minutes.ago }
  v.severity              1
  v.call_center_timed_out true
  v.association :user
  v.association :device
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

Factory.define :mgmt_query do |v|
  v.timestamp_server { Time.now }
  v.timestamp_device { Time.now }
  v.poll_rate 60
  v.cycle_num 1
  v.association :device
end

Factory.define :order do |v|
  v.number { ("0".."9").to_a.shuffle.join }
  v.bill_first_name { Faker::Name.first_name }
  v.bill_city { Faker::Address.city }
  v.bill_state { Faker::Address.us_state }
  v.bill_zip { Faker::Address.zip_code }
  v.bill_phone { ("0".."9").to_a.shuffle.join }
  v.bill_email { Faker::Internet.email }
  v.card_number "4" + ("1"*15)
  v.ship_first_name { Faker::Name.first_name }
  v.ship_city { Faker::Address.city }
  v.ship_state { Faker::Address.us_state }
  v.ship_zip { Faker::Address.zip_code }
  v.ship_phone { ("0".."9").to_a.shuffle.join }
  v.ship_email { Faker::Internet.email }
  v.card_type "VISA"
  v.ship_last_name { Faker::Name.last_name }
  v.bill_last_name { Faker::Name.last_name }
  v.coupon_code { ("A".."Z").to_a.shuffle[0..7].join }
  v.kit_serial { ("A".."Z").to_a.shuffle[0..7].join }
  v.ship_address { Faker::Address.street_address }
  v.bill_address { Faker::Address.street_address }
  v.comments { Faker::Lorem.paragraph }
  v.card_expiry { 3.months.from_now }
  v.association :created_by, :factory => :user
  v.association :updated_by, :factory => :user
  v.association :group
  v.created_at { Time.now }
  v.updated_at { Time.now }
  v.association :user_intake
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
  v.home_phone { (0..9).to_a.shuffle.join('') }
  v.cell_phone { (0..9).to_a.shuffle.join('') }
  v.account_number { (0..9).to_a.shuffle.join('') }[0..3]
  v.hospital_number { (0..9).to_a.shuffle.join('') }
  v.doctor_phone { (0..9).to_a.shuffle.join('') }
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

Factory.define :role do |v|
  v.name { Faker::Lorem.words[0] }
end

Factory.define :roles_users_option do |v|
  v.removed { rand(1) == 1 }
  v.active { rand(1) == 1 }
  v.phone_active { rand(1) == 1 }
  v.text_active { rand(1) == 1 }
  v.email_active { rand(1) == 1 }
  v.is_keyholder { rand(1) == 1 }
  v.position { rand(3) }
  v.relationship { Faker::Name.name }
end

Factory.define :strap_fastened do |v|
  v.association :device
  v.association :user
end

Factory.define :strap_removed do |v|
  v.association :device
  v.association :user
end

Factory.define :system_timeout do |v|
  v.mode                            { ['dialup', 'ethernet'][rand(1)] }
  v.gateway_offline_timeout_sec     3600
  v.device_unavailable_timeout_sec  3600
  v.strap_off_timeout_sec           3600
  v.critical_event_delay_sec        3600
  v.battery_reminder_two_sec        3600
  v.battery_reminder_three_sec      3600
  v.gateway_offline_offset_sec      3600
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
  # v.gateway_serial { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  # v.transmitter_serial { Faker::PhoneNumber.phone_number.to_i.to_s.ljust( 10, "0") }
  # v.submitted_at { Time.now } # we will submit manually where required
  v.paper_copy_submitted_on { Time.now }
  v.legal_agreement_at { Time.now }
  v.association :group
  v.subscriber_is_user false # { rand(1) == 1 }
  v.subscriber_is_caregiver false # { rand(1) == 1 }
  v.no_caregiver_1 false
  v.no_caregiver_2 false
  v.no_caregiver_3 false
  v.need_validation false # force skip errors
  #
  # valid callbacks for factory_girl are
  #   :after_build, :after_create, :after_stub
  v.after_create do |ui|
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user|
      ui.send("#{user}=".to_sym, Factory.build(:user, :email => "#{user}@test.com"))
    end
    # ui.skip_validation = true # we need "edit" links in list
    # ui.update_attribute(:locked, false) # 3215: do not force this attribute update
    ui.senior.is_halouser_of ui.group
    ui.subscriber.is_subscriber_of ui.senior
    ui.caregiver1.is_caregiver_of ui.senior
    ui.caregiver2.is_caregiver_of ui.senior
    ui.caregiver3.is_caregiver_of ui.senior
  end
  v.after_build do |ui|
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user|
      ui.send("#{user}=".to_sym, Factory.build(:user, :email => "#{user}@test.com"))
    end
  end
  v.after_stub do |ui|
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user|
      ui.send("#{user}=".to_sym, Factory.build(:user, :email => "#{user}@test.com"))
    end
  end
end

Factory.define :vital do |v|
  v.timestamp { Time.now }
  v.association :user
end
