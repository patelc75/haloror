# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "development"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'digest'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end
#CONSTANTS
CAREGIVER1='test_caregiver1'
CAREGIVER2='test_caregiver2'
OPERATOR='test_operator'
USER='test_user'
HALO_GATEWAY='Halo Gateway'
HALO_CHEST_STRAP='Halo Chest Strap'
SITE_URL = "localhost:3000"
BEGIN_CURL='curl -v -H "Content-Type: text/xml" -d '
CLAZZES = [BatteryChargeComplete, BatteryPlugged, BatteryUnplugged, BatteryCritical, StrapFastened, StrapRemoved, Fall, Panic]


BATTERY_CHARGE_COMPLETE_METHODS = {:percentage= => 100, :time_remaining= => 1000}
BATTERY_PLUGGED_METHODS         = {:percentage= => 60,  :time_remaining= => 500}
BATTERY_UNPLUGGED_METHODS       = {:percentage= => 50,  :time_remaining= => 500}
BATTERY_CRITICAL_METHODS        = {:percentage= => 10,  :time_remaining= => 100}
STRAP_FASTENED_METHODS          = {}
STRAP_REMOVED_METHODS           = {}
FALL_METHODS                    = {:magnitude=  => 60}
PANIC_METHODS                   = {}

CLAZZ_TO_METHODS = {BatteryChargeComplete => BATTERY_CHARGE_COMPLETE_METHODS, 
                    BatteryPlugged        => BATTERY_PLUGGED_METHODS, 
                    BatteryUnplugged      => BATTERY_UNPLUGGED_METHODS,
                    BatteryCritical       => BATTERY_CRITICAL_METHODS,
                    StrapFastened         => STRAP_FASTENED_METHODS,
                    StrapRemoved          => STRAP_REMOVED_METHODS,
                    Fall                  => FALL_METHODS,
                    Panic                 => PANIC_METHODS}
                    
#refactor to pluralize the model name and generate the path
CLAZZ_TO_PATHS = {BatteryChargeComplete   => 'battery_charge_completes',
                  BatteryPlugged          => 'battery_pluggeds', 
                  BatteryUnplugged        => 'battery_unpluggeds',
                  BatteryCritical         => 'battery_criticals',
                  StrapFastened           => 'strap_fasteneds',
                  StrapRemoved            => 'strap_removeds',
                  Fall                    => 'falls',
                  Panic                   => 'panics'} 


#helper methods
def set_model_values(model)
  methods_hash = CLAZZ_TO_METHODS[model.class]
  methods_hash.each do |key, value|
    model.send(key, value)
  end
end

def get_bundled_curl_cmd(models)
  curl_cmd = BEGIN_CURL 
  curl_cmd += '"'
  
  user = get_user
  device = get_device(user)
  gateway = get_gateway(user)
  ts = Time.now
  auth = generate_auth(ts, gateway.id)
  
  curl_cmd += '<bundle><timestamp>'
  curl_cmd += ts.strftime("%a %b %d %H:%M:%S -0600 %Y")
  curl_cmd += '</timestamp>'
  models.each do |model|    
    curl_cmd += get_xml(user.id, device.id, ts, model)
  end
  curl_cmd += '</bundle>" "http://'
  curl_cmd += SITE_URL
  curl_cmd += '/bundle?gateway_id=' + gateway.id.to_s  
  curl_cmd += '&auth=' + auth
  curl_cmd += '"'
  puts curl_cmd
  return curl_cmd
end
def get_curl_cmd(model)  
  user = get_user
  device = get_device(user)
  gateway = get_gateway(user)  
  ts = Time.now
  auth = generate_auth(ts, gateway.id)
  
  curl_cmd = BEGIN_CURL 
  curl_cmd += '"'
  curl_cmd += get_xml(user.id, device.id, ts, model)
  curl_cmd += '" "http://'
  curl_cmd += SITE_URL
  curl_cmd += '/'
  curl_cmd += get_model_url(model)
  curl_cmd += '?gateway_id=' + gateway.id.to_s
  curl_cmd += '&auth=' + auth
  curl_cmd += '"'
  puts curl_cmd
  return curl_cmd
end

def get_user
  User.find_by_login(USER)
end

def get_device(user)
  user.devices.find(:first, :conditions => "device_type = '#{HALO_CHEST_STRAP}'")
end

def get_gateway(user)
  user.devices.find(:first, :conditions => "device_type = '#{HALO_GATEWAY}'")
end

def set_timestamp(timestamp, model)
  if model.respond_to? :timestamp
    model.timestamp = timestamp
    model.timestamp
  elsif model.respond_to? :begin_timestamp
    model.begin_timestamp = timestamp
    modle.begin_timestamp
  end
end
#.strftime("%a %b %d %H:%M:%S -0600 %Y")
def generate_auth(timestamp, gateway_id)
  ts = timestamp.strftime("%a %b %d %H:%M:%S -0600 %Y")
  Hash::XML_FORMATTING['datetime'] = Proc.new { |datetime| 
  datetime.strftime("%a %b %d %H:%M:%S -0600 %Y") }  
  serial_number = Device.find_by_id(gateway_id).serial_number
  serial_number.strip!
  sn = "#{ts}#{serial_number}"
  puts sn
  return Digest::SHA256.hexdigest(sn)
end

def get_xml(user_id, device_id, timestamp, model)
  model.user_id = user_id
  model.device_id = device_id
  set_timestamp(timestamp, model)
  xml = model.to_xml(:dasherize => false, :skip_instruct => true, :skip_types => true)
  xml.gsub!("\n", '')
  return xml
end

def get_model_url(model)
  return CLAZZ_TO_PATHS[model.class]
end