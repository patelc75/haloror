# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :activerecord

# Authorize.net settings
AUTH_NET_LOGIN="54PB5egZ" #test
AUTH_NET_TXN_KEY="48V258vr55AE8tcg" #test
AUTH_NET_URL="https://apitest.authorize.net/xml/v1/request.api" # test
#AUTH_NET_LOGIN="9J37JJs8hvB3" #production
#AUTH_NET_TXN_KEY="84ZnG87jcJMu8R6Z" #producion
#AUTH_NET_URL="https://api.authorize.net/xml/v1/request.api" # production
AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES=9999 # 9999 means subscription with no end date 
AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS="month"
AUTH_NET_SUBSCRIPTION_INTERVAL=1 # e.g. if units is 'months' and interval=1, then subscription will bill once monthly.
AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL=65.00

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  # ::GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
  #   :login => AUTH_NET_LOGIN,
  #   :password => AUTH_NET_TXN_KEY
  # )
end
