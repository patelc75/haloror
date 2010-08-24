# Tell Cucumber to quit after this scenario is done - if it failed.
After do |s| 
  Cucumber.wants_to_quit = true if s.failed?
end
