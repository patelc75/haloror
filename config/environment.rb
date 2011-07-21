# Be sure to restart your web server when you modify this file.

AUTHORIZATION_MIXIN = 'object roles'
DEFAULT_REDIRECTION_HASH = { :controller => 'sessions', :action => 'new' }

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

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
  config.load_paths += %W( #{RAILS_ROOT}/app/rules #{RAILS_ROOT}/config/initializers )
  config.time_zone = 'UTC'
  
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
  config.action_controller.session = { :session_key => "_myapp_session", :secret => "some secret phrase of at least 30 characters" }
  
  # See Rails::Configuration for more options
  config.active_record.observers = :user_observer, :device_event_observer, :event_action_observer, :critical_device_event_observer, :gateway_event_observer
  
  config.gem "rufus-scheduler", :version => ">= 2.0.1", :lib => false
  config.gem "rubyhealthvault", :lib => "healthvault"
  #config.gem "ambethia-recaptcha", :lib => "recaptcha/rails"
  config.gem "markaby"
  config.gem "ezcrypto" # Thu Sep 16 00:15:34 IST 2010
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
SMTP_SETTINGS_LOCALHOST_BACKUP={
  :address => "localhost" ,
  :port => 25,
  :domain => "halomonitor.com"
}

SMTP_SETTINGS_GMAIL = {
  :address => "smtp.gmail.com" ,
  :port => 587,
  :authentication => :plain,
  :user_name => "healthserver@halomonitoring.com",
  :password => "halo75halo" 
}

ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST
# ActionMailer::Base.smtp_settings = SMTP_SETTINGS_GMAIL

require 'rubygems'
require 'will_paginate'
require 'action_mailer/ar_sendmail'
require 'halo_mailer'
require 'postgre_extensions'
require 'server_instance'
require 'rexml-expansion-fix'
require 'active_merchant_extensions'

# TODO: need some work before it can run flawless
# require 'user_monitor' # auto assign created_by, updated_by only if the column exists
# 
# # auto assign created_by, updated_by only if the column exists
# ActiveRecord::Base.class_eval { include ActiveRecord::UserMonitor }

ExceptionNotifier.exception_recipients = %w(exceptions@halomonitoring.com)  
# defaults to exception.notifier@default.com
ExceptionNotifier.sender_address = %("HaloRoR Error" <	no-reply@halomonitoring.com>)
# defaults to "[ERROR] "
ExceptionNotifier.email_prefix = "[" + ServerInstance.current_host_short_string + "] "

# Timezone Setup
#ActiveRecord::Base.default_timezone = :utc # Store all times in the db in UTC
#require 'tzinfo/lib/tzinfo' # Use tzinfo library to convert to and from the users timezone
ENV['TZ'] = 'UTC' # This makes Time.now return time in UTC and assumes all data in DB is this timezone, seems to only work in production mode
Time::DATE_FORMATS[:date_time] = "%a %b %d, %Y at %I:%M%p" #Tue Dec 25,2007 at 03:52PM
Time::DATE_FORMATS[:date_time_seconds] = "%a %b %d, %Y at %I:%M:%S%p" #Tue Dec 25,2007 at 01:02:13PM
Time::DATE_FORMATS[:date_time_seconds_2] = "%m/%d/%y %I:%M%p" #12/25/07 03:52PM
Time::DATE_FORMATS[:date_time_timezone] = Time::DATE_FORMATS[:date_time] + " %Z" #Tue Dec 25, 2007 at 03:52PM CST
Time::DATE_FORMATS[:time_date] = "%I:%M%p on %a %b %d,%Y" #03:52PM on Tue Dec 25,2007
Time::DATE_FORMATS[:time_date_text] = "%I:%M%p %a %b %d" #03:52PM Tue Dec 25
Time::DATE_FORMATS[:time_date_timezone] = "%I:%M%p %Z on %a %b %d, %Y" #03:52PM CST on Tue Dec 25, 2007
Time::DATE_FORMATS[:timezone] = "%Z" #CST
Time::DATE_FORMATS[:day_date] = "%A, %B %d, %Y" # Wednesday, February 10, 2010   
Time::DATE_FORMATS[:day_date_short] = "%a %b %d, %Y" # Wed Feb 10, 2010
Time::DATE_FORMATS[:MM_DD_YYYY] = "%m-%d-%Y" # 12-25-2010
Time::DATE_FORMATS[:day_MM_DD_YYYY] = "%a %m-%d-%Y" # 12-25-2010

#
# set the default display format. no need to explicitly specify the format now.
Time::DATE_FORMATS[:default] = Time::DATE_FORMATS[:date_time_timezone]

HALO_ROLES = ['installer','operator','moderator','sales','admin']

#Rufus-related constants
GATEWAY_OFFLINE_TIMEOUT=20
GATEWAY_OFFLINE_TIMEOUT_MARGIN=0.10
GATEWAY_OFFLINE_POLL_RATE='1m'
DEVICE_UNAVAILABLE_TIMEOUT=5
DEVICE_UNAVAILABLE_POLL_RATE='1m'
EMAIL_NOTIFICATION_RATE='1m'
MAX_ATTEMPTS_BEFORE_NOTIFICATION=1

BUNDLE_JOB_DIAL_UP_TIME='1m'
CRITICAL_ALERT_JOB_TIME='10s'
DAILY_REPORT_TIME='30 5 * * *'

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
REPORTING_USERS_PER_PAGE = 20 # speed up display of lists. browsing schronologically arranged data on pages, or search is better

MGMT_POLL_RATE=900
INSTALL_WIZ_TIMEOUT_REGISTRATION=600.seconds
INSTALL_WIZ_TIMEOUT_GATEWAY=480.seconds
INSTALL_WIZ_TIMEOUT_CS=240.seconds
INSTALL_WIZ_TIMEOUT_PHONE=290.seconds
INSTALL_WIZ_TIMEOUT_HEARTRATE=240.seconds
INSTALL_WIZARD_POLL_RATE = 10
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
DIAL_UP_ARCHIVE_FILES_TO_KEEP_MIN=100
MAX_EMAILS_ALLOWED = 1000
EMERGENCY_GROUPS=['EMS', 'safety_care']
ALERTS_ENABLED_BY_DEFAULT=['BatteryCritical']
BATTERY_REMINDER_POLL_RATE='15m' 

#used when call is accepted/resolved on crit1 and needs to be updated on crit2 
#so the agent doesn't accidentally accept/resolve the call on crit2
SYSTEM_USERNAME="HALO_SYSTEM_USER"
SYSTEM_PASSWORD="Halo_p455w0rd"

DEVICE_TYPES = {:H1 => 'Chest Strap', :H2 => 'Gateway', :H5 => 'Belt Clip'}
GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT=1800  #30 minutes
SERIES_HASH = {"1" => "First","2" => "Second","3" => "Third","4" => "Fourth","5" => "Fifth", "6" => "Sixth", "7" => "Seventh", "8" => "Eighth", "9" => "Ninth", "10" => "Tenth"}

SAFETYCARE_HEARTBEAT_TIME = "55s"
CMS_HEARTBEAT_TIME = "45s"

# Development settings
HV_APP_ID = "6019e8f1-413f-4dfc-878e-62053cbb0dab"
HV_CERT_FILE = "#{RAILS_ROOT}/config/healthvault/halo_monitor-6019e8f1-413f-4dfc-878e-62053cbb0dab.pfx"
HV_CERT_PASS = ""
HV_SHELL_URL = "https://account.healthvault-ppe.com"
HV_HV_URL = "https://platform.healthvault-ppe.com/platform/wildcat.ashx"

# re-captcha
#
ENV['RECAPTCHA_PUBLIC_KEY']  = '6LeR9goAAAAAANZVo52U0AV9iwu0PoslF_FAwF-F'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LeR9goAAAAAAP4iAFbMvp91jkxVyWegay5k-b1v'

# messages for redirect_to_message
ALERT_MESSAGES = {
  :default => "Please click the button to go back",
  :login_failed => "The login information you entered does not match an account in our records. Remember, your login and password is case-sensitive, please check your Caps Lock key.",
  :profile_updated => "Profile Updated. Since you are a super_admin, you were allowed to do this. But you MUST follow up with the call center with these changes.",  
  :call_tech_support => "Please call tech support 1-888-971-HALO (4256) to make this modification.",
  :new_caregiver => "If that email was in our system, the user was added to your caregiver list. If not, an email was sent to that email address."
}

# used at user_mailer.rb, and user.rb
EMAIL_SUBJECT = {
  :installation => 'Please read before your installation',
  :activation => 'Please activate your new myHalo account',
  :activated => 'Your account has been activated!',
  :kit_registered => 'New myHalo User Signed Up',
  :receipt => 'myHalo Receipt',
  :order_summary => 'Order Summary'
}

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  "<span class='error-field'>#{html_tag}</span>"
end

CONNECTIVITY_STATUS_ICONS = {
  # "AccessMode" => "access_mode",
  # "BatteryChargeComplete" => "battery_charge_complete",
  # "BatteryCritical" => "battery_critical",
  "BatteryPlugged" => "battery_plugged",
  # "BatteryReminder" => "battery_reminder",
  # "BatteryUnplugged" => "battery_unplugged",
  # "CallCenterDeferred" => "call_center_deferred",
  # "CallCenterFollowUp" => "call_center_follow_up",
  "DeviceAvailableAlert" => "device_available_alert",
  "DeviceUnavailableAlert" => "device_unavailable_alert",
  # "EventAction" => "event_action",
  # "Fall" => "fall",
  "GatewayOfflineAlert" => "gateway_offline_alert",
  "GatewayOnlineAlert" => "gateway_online_alert",
  # "GwAlarmButton" => "gw_alarm_button"
  # "GwAlarmButtonTimeout" => "gw_alarm_button_timeout",
  # "Panic" => "panic",
  "StrapFastened" => "strap_fastened",
  # "StrapOffAlert" => "strap_off_alert",
  # "StrapOnAlert" => "strap_on_alert",
  "StrapRemoved" => "strap_removed",
  "Dialup" => "status_dial_up" # we are using this existing image as default value
  }
       
FILTERED_EVENTS_FOR_NON_SUPER_ADMINS = [DialUpAlert, AccessMode, DialUpStatus, StrapFastened, StrapRemoved]