# Edit at your own peril - it's recommended to regenerate this file
# in the future when you upgrade to a newer version of Cucumber.

# IMPORTANT: Setting config.cache_classes to false is known to
# break Cucumber's use_transactional_fixtures method.
# For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.gem 'database_cleaner', :lib => false, :version => '>=0.4.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/database_cleaner'))
config.gem 'webrat',           :lib => false, :version => '>=0.6.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/webrat'))
config.gem 'rspec-rails',      :lib => 'spec/rails', :version => '>=1.3.2' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
config.gem 'rspec',            :lib => 'spec', :version => '>=1.3.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'cucumber'
config.gem 'cucumber-rails',   :lib => 'cucumber/rails', :version => '>=0.2.4' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber-rails'))
config.gem "faker"
config.gem "factory_girl"

AUTH_NET_LOGIN="54PB5egZ" #test
AUTH_NET_TXN_KEY="48V258vr55AE8tcg" #test
AUTH_NET_URL="https://apitest.authorize.net/xml/v1/request.api" # test

config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :test
  # ::GATEWAY = ActiveMerchant::Billing::BogusGateway.new
  ::GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
    :login => AUTH_NET_LOGIN,
    :password => AUTH_NET_TXN_KEY
  )
end
