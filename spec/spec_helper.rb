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

#  curl
BEGIN_CURL='curl -v -H "Content-Type: text/xml" -d '

#helper methods
def set_timestamp(model)
  if model.respond_to? :timestamp
    model.timestamp = Time.now
    return model.timestamp
  elsif model.respond_to? :begin_timestamp
    model.begin_timestamp = Time.now
    return modle.begin_timestamp
  end
  return nil
end

def generate_auth(timestamp, gateway_id)
  ts = timestamp.strftime("%a %b %d %H:%M:%S -0600 %Y")
  serial_number = Device.find_by_id(gateway_id).serial_number
  serial_number.strip!
  sn = "#{@ts}#{@serial_number}"
  return Digest::SHA256.hexdigest(sn)
end

def get_xml(model)
  xml = model.to_xml(:dasherize => false, :skip_instruct => true)
  xml.gsub!("\n", '')
  return xml
end