AUTHORIZATION_MIXIN = 'object roles'
DEFAULT_REDIRECTION_HASH = { :controller => 'sessions', :action => 'new' }

# Rawk Coding

class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{msg} (pid:#{$$})\n"
  end
end


# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

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
  config.active_record.observers = :user_observer, :panic_observer, :fall_observer, :device_alert_observer
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


#ActionMailer::Base.delivery_method = :activerecord
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
  
if (ENV['RAILS_ENV'] == 'production')
  ActionMailer::Base.smtp_settings = {
    :address => "localhost" ,
    :port => 25,
    :domain => "halomonitor.com"
  }
else
  ActionMailer::Base.smtp_settings = {
    :address => "mail.haloresearch.net" ,
    :port => 25,
    :domain => "haloresearch.net" ,
    :authentication => :login,
    :user_name => "chirag@haloresearch.net" ,
    :password => "irdikt75" 
  }
end

require 'rubygems'
require 'action_mailer/ar_sendmail'

class ActionMailer::ARMailer < ActionMailer::Base
  attr_accessor :priority
  def perform_delivery_activerecord(mail)
    if self.priority.nil?
      self.priority = Priority::LOW
    end
    if self.priority > Priority::THRESH_HOLD
      emails = []
      ar_sendmail = ActionMailer::ARSendmail.new
      mail.destinations.each do |destination|
        emails << Email.new(:mail => mail.encoded, :to => destination,
          :from => mail.from.first, :priority => self.priority)
      end
      ar_sendmail.deliver(emails)      
    else
      mail.destinations.each do |destination|
        Email.create  :mail => mail.encoded, :to => destination,
          :from => mail.from.first, :priority => self.priority
      end
    end
  end
end

class ActionMailer::ARSendmail
  def find_emails
    options = { :conditions => ['last_send_attempt < ?', Time.now.to_i - 300], :order => :priority }
    options[:limit] = batch_size unless batch_size.nil?
    mail = @email_class.find :all, options

    log "found #{mail.length} emails to send"
    mail
  end
end

require 'postgre_extensions'

# Exception notifier coding 

ExceptionNotifier.exception_recipients = %w(exceptions@halomonitoring.com)  
# defaults to exception.notifier@default.com
ExceptionNotifier.sender_address = %("Application Error" <app.error@myapp.com>)
# defaults to "[ERROR] "
ExceptionNotifier.email_prefix = "[APP] "

# Timezone Setup

ActiveRecord::Base.default_timezone = :utc # Store all times in the db in UTC
require 'tzinfo/lib/tzinfo' # Use tzinfo library to convert to and from the users timezone
ENV['TZ'] = 'UTC' # This makes Time.now return time in UTC and assumes all data in DB is this timezone