# Be sure to restart your web server when you modify this file.

AUTHORIZATION_MIXIN = 'object roles'
DEFAULT_REDIRECTION_HASH = { :controller => 'sessions', :action => 'new' }

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]
  
  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/rules )
  
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  #config.action_controller.session = { :session_key => "_myapp_session", :secret => "some secret phrase of at least 30 characters" }
  
  # See Rails::Configuration for more options
  config.active_record.observers = :user_observer, :device_event_observer, :event_action_observer, :critical_device_event_observer, :gateway_event_observer
  
  config.gem "tzinfo"
  config.gem "chronic"
  config.gem "rufus-scheduler"
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
#hash used for ruby-debug gem, used to store Rails source code
#SCRIPT_LINES__ = {} if ENV['RAILS_ENV'] == 'development'


ActionMailer::Base.delivery_method = :activerecord
#ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true

SMTP_SETTINGS_LOCALHOST={
  :address => "localhost" ,
  :port => 25,
  :domain => "halomonitor.com"
}
SMTP_SETTINGS_SERVER2={
  :address => "localhost" ,
  :port => 25,
  :domain => "halomonitor.com"
}
SMTP_SETTINGS_NARFONIX = {
  :address => "mail.haloresearch.net" ,
  :port => 25,
  :domain => "haloresearch.net" ,
  :authentication => :login,
  :user_name => "chirag@haloresearch.net" ,
  :password => "irdikt75" 
}

if (ENV['RAILS_ENV'] == 'production')
  ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST
else
  ActionMailer::Base.smtp_settings = SMTP_SETTINGS_NARFONIX
end

require 'rubygems'
require 'will_paginate'
require 'action_mailer/ar_sendmail'
require 'halo_mailer'
require 'postgre_extensions'
require 'server_instance'
require 'rexml-expansion-fix'

ExceptionNotifier.exception_recipients = %w(exceptions@halomonitoring.com)  
# defaults to exception.notifier@default.com
ExceptionNotifier.sender_address = %("HaloRoR Error" <	no-reply@halomonitoring.com>)
# defaults to "[ERROR] "
ExceptionNotifier.email_prefix = "[" + ServerInstance.current_host_short_string + "] "

# Timezone Setup
ActiveRecord::Base.default_timezone = :utc # Store all times in the db in UTC
require 'tzinfo/lib/tzinfo' # Use tzinfo library to convert to and from the users timezone
ENV['TZ'] = 'UTC' # This makes Time.now return time in UTC and assumes all data in DB is this timezone, seems to only work in production mode

#Rufus-related constants
GATEWAY_OFFLINE_TIMEOUT=20
GATEWAY_OFFLINE_TIMEOUT_MARGIN=0.10
GATEWAY_OFFLINE_POLL_RATE='1m'
DEVICE_UNAVAILABLE_TIMEOUT=5
DEVICE_UNAVAILABLE_POLL_RATE='1m'
EMAIL_NOTIFICATION_RATE='1m'
MAX_ATTEMPTS_BEFORE_NOTIFICATION=1

BUNDLE_JOB_DIAL_UP_TIME='1m'
#DailyReports
DAILY_REPORT_TIME='30 2 * * *'

STRAP_OFF_POLL_RATE='1m'
STRAP_OFF_TIMEOUT=60
MAX_ATTEMPTS_BEFORE_NOTIFICATION_STRAP_OFF=1

#ADL-related constants
MIN_ADL_RESTING_ORIENTATION=75
MAX_ADL_RESTING_ORIENTATION=105
MIN_ADL_RESTING_ACTIVITY=2000

#Mgmt protocol-related
MGMT_CMD_ATTEMPTS_WITHOUT_ACK=5

LOST_DATA_GAP = 17

EVENTS_PER_PAGE = 25
REPORTING_USERS_PER_PAGE = 50
REORTING_DEVICES_PER_PAGE = 50

MGMT_POLL_RATE=900
INSTALL_WIZ_TIMEOUT_REGISTRATION=180.seconds
INSTALL_WIZ_TIMEOUT_GATEWAY=220.seconds
INSTALL_WIZ_TIMEOUT_CS=240.seconds
INSTALL_WIZ_TIMEOUT_PHONE=145.seconds
INSTALL_WIZ_TIMEOUT_HEARTRATE=240.seconds
INSTALL_WIZARD_POLL_RATE = 1
INSTALL_WIZARD_TIMEOUT=900
INSTALL_WIZARD_START_TIMESTAMP_DELAY=3600 * 24
RANGE_TEST_PERCENTAGE=100
HEARTRATE_DETECTED_PERCENTAGE=90
PHONE_SELF_TEST_PERCENTAGE=65
CHEST_STRAP_DETECTED_PERCENTAGE=55
CHEST_STRAP_SELF_TEST_PERCENTAGE=45
GATEWAY_SELF_TEST_PERCENTAGE=30
REGISTRATION_PERCENTAGE=15
GATEWAY_SELF_TEST_DELAY=3600

#SELF TEST STEP DESCRIPTIONS
INSTALLATION_SESSION_CREATED_ID=1
REGISTRATION_COMPLETE_ID=2
REGISTRATION_FAILURE_ID=3
SELF_TEST_CHEST_STRAP_MGMT_COMMAND_CREATED_ID=4
SELF_TEST_PHONE_MGMT_COMMAND_CREATED_ID=5
SELF_TEST_GATEWAY_COMPLETE_ID=6
SELF_TEST_GATEWAY_FAILED_ID=7
SELF_TEST_GATEWAY_TIMEOUT_ID=8
SELF_TEST_CHEST_STRAP_COMPLETE_ID=9
SELF_TEST_CHEST_STRAP_FAILED_ID=10
SELF_TEST_CHEST_STRAP_TIMEOUT_ID=11
SELF_TEST_PHONE_COMPLETE_ID=12
SELF_TEST_PHONE_FAILED_ID=13
SELF_TEST_PHONE_TIMEOUT_ID=14
CHEST_STRAP_PROMPT_ID=15
CHEST_STRAP_FASTENED_DETECTED_ID=16
CHEST_STRAP_FASTENED_TIMEOUT_ID=17
HEARTRATE_DETECTED_ID=18
HEARTRATE_TIMEOUT_ID=19
START_RANGE_TEST_PROMPT_ID=20
STOP_RANGE_TEST_PROMPT_ID=21
RANGE_TEST_COMPLETE_ID=22
RANGE_TEST_FAILURE_ID=23
SLOW_POLLING_MGMT_COMMAND_CREATED_ID=24
ADD_RANGE_TEST_NOTES_ID=25
INSTALLATION_SESSION_COMPLETE_ID=26
INSTALLATION_SERIAL_NUMBERS_ENTERED_ID=27
INSTALLATION_SERIAL_NUMBERS_ENTERED_FAILED_ID=28
REGISTRATION_TIMEOUT_ID=29
DIAL_UP_ARCHIVE_FILES_TO_KEEP_MIN=2
EMERGENCY_GROUPS=['EMS', 'SafetyCare']
ALERTS_ENABLED_BY_DEFAULT=['BatteryCritical']
BATTERY_REMINDER_POLL_RATE='15m'
BATTERY_REMINDER_TWO = 7200     #2 hours
BATTERY_REMINDER_THREE = 14400  #4 hours 

#used when call is accepted/resolved on crit1 and needs to be updated on crit2 
#so the agent doesn't accidentally accept/resolve the call on crit2
SYSTEM_USERNAME="HALO_SYSTEM_USER"
SYSTEM_PASSWORD="Halo_p455w0rd"

DEVICE_TYPES = {:H1 => 'Chest Strap', :H2 => 'Gateway'}
GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT=1800  #30 minutes


SAFETYCARE_HEARTBEAT_TIME = "55s"