#require 'ruby-debug'
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
#config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

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
