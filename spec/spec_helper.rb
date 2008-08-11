# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "development"
IS_RANDOM=true
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
CLAZZES = [BatteryChargeComplete, BatteryPlugged, BatteryUnplugged, BatteryCritical, StrapFastened, StrapRemoved, Vital]

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
  return curl_cmd
end

def get_curl_cmd_for_ack(model, type)
  user = get_user
  device = get_device(user)
  gateway = get_gateway(user)  
  ts = Time.now
  auth = generate_auth(ts, gateway.id)
  
  curl_cmd = BEGIN_CURL 
  curl_cmd += '"<management_ack_device><device_id>'
  curl_cmd += device.id.to_s
  curl_cmd += '</device_id><cmd_type>'
  curl_cmd += type
  curl_cmd += '</cmd_type><timestamp>'
  curl_cmd += ts.strftime("%a %b %d %H:%M:%S -0600 %Y")
  curl_cmd += '</timestamp></management_ack_device>" "http://'
  curl_cmd += SITE_URL
  curl_cmd += '/'
  curl_cmd += get_model_url(model)
  curl_cmd += '?gateway_id=' + gateway.id.to_s + '&auth=' + auth + '"'
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
    model.begin_timestamp
  elsif model.respond_to? :timestamp_device
    model.timestamp_device = timestamp
    model.timestamp_device
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
  if model.respond_to? :user_id
    model.user_id = user_id
  end
  if model.respond_to? :device_id
    model.device_id = device_id
  end
  set_timestamp(timestamp, model)
  xml = ""
  if model.class == MgmtQuery
    xml = "<management_query_device><timestamp>#{timestamp.strftime("%a %b %d %H:%M:%S -0600 %Y")}</timestamp><device_id>#{model.device_id}</device_id><poll_rate>#{model.poll_rate}</poll_rate></management_query_device>"
  else
    xml = model.to_xml(:dasherize => false, :skip_instruct => true, :skip_types => true)
  end
  xml.gsub!("\n", '')
  xml.gsub!("nil=\"true\"", '')
  return xml
end

def get_model_url(model)
  return model.class.to_s.pluralize.underscore
end