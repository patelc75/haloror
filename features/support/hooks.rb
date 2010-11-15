#
# Cause scenarios tagged with @fast to fail if the execution takes longer than 0.5 seconds
Around('@fast') do |scenario, block|
  Timeout.timeout(0.5) do
    block.call
  end
end

#  Mon Nov 15 23:44:21 IST 2010, ramonrails
#  cucumber hooks
# Scenario setup
#
Before do
  #
  # Mail traces cleared
  ActionMailer::Base.deliveries.clear
  #
  # start considering data as dirty
  DatabaseCleaner.start
end

# Scenario teardown
#
After do |scenario|
  #
  # Clean all dirty data
  DatabaseCleaner.clean
  #
  # Tell Cucumber to quit after this scenario is done - if it failed.
  Cucumber.wants_to_quit = true if scenario.failed?
end
