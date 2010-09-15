# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# my code starts here
# config.log_level = :debug

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true # debugging exception_notifier
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true # debugging exception_notifier

HV_APP_ID = "388278cd-5467-45af-a2b5-3d2c5fabffa3"
HV_CERT_FILE = "#{RAILS_ROOT}/config/healthvault/halo_monitor-prod-388278cd-5467-45af-a2b5-3d2c5fabffa3.pfx"
HV_CERT_PASS = ""
HV_SHELL_URL = "https://account.healthvault.com"
HV_HV_URL = "https://platform.healthvault.com/platform/wildcat.ashx"

# Authorize.net settings
# AUTH_NET_LOGIN="54PB5egZ" #test
# AUTH_NET_TXN_KEY="48V258vr55AE8tcg" #test
# AUTH_NET_URL="https://apitest.authorize.net/xml/v1/request.api" # test
AUTH_NET_LOGIN="9J37JJs8hvB3" #production
AUTH_NET_TXN_KEY="84ZnG87jcJMu8R6Z" #producion
AUTH_NET_URL="https://api.authorize.net/xml/v1/request.api" # production
AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES=9999 # 9999 means subscription with no end date 
AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS="month"
AUTH_NET_SUBSCRIPTION_INTERVAL=1 # e.g. if units is 'months' and interval=1, then subscription will bill once monthly.
AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL=65.00

# * <tt>:login</tt> -- The Authorize.Net API Login ID (REQUIRED)
# * <tt>:password</tt> -- The Authorize.Net Transaction Key. (REQUIRED)
# * <tt>:test</tt> -- +true+ or +false+. If true, perform transactions against the test server. 
#   Otherwise, perform transactions against the production server.
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
  ::PAYMENT_GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
    :login => AUTH_NET_LOGIN,
    :password => AUTH_NET_TXN_KEY,
    :test => false
  )
end
