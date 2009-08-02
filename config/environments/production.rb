# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
#config.action_controller.consider_all_requests_local = false
#config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# my code starts here
# Show full error reports and disable caching
#config.action_controller.consider_all_requests_local = true
config.action_controller.consider_all_requests_local = false # debugging exception_notifier
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
#config.action_mailer.raise_delivery_errors = false
config.action_mailer.raise_delivery_errors = true # debugging exception_notifier


HV_APP_ID = "388278cd-5467-45af-a2b5-3d2c5fabffa3"
HV_CERT_FILE = "#{RAILS_ROOT}/config/healthvault/halo_monitor-prod-388278cd-5467-45af-a2b5-3d2c5fabffa3.pfx"
HV_CERT_PASS = ""
HV_SHELL_URL = "https://account.healthvault.com"
HV_HV_URL = "https://platform.healthvault.com/platform/wildcat.ashx"
