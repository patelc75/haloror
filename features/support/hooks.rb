# Cause scenarios tagged with @fast to fail if the execution takes longer than 0.5 seconds
#
Around('@fast') do |scenario, block|
  Timeout.timeout(0.5) do
    block.call
  end
end

# Tell Cucumber to quit after this scenario is done - if it failed.
#
# After do |scenario|
#   Cucumber.wants_to_quit = true if scenario.failed?
# end
