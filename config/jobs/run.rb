#!/usr/bin/env /web/halo/script/runner

# Executable to startup the job processor. Accepts one parameter - the
# name of the file containing the tasks to run
#
# Ex: ./config/jobs/run.rb task
#
# Will load the file named task.rb and will run those jobs in the
# background

jobs_type = ARGV.first
raise "Specify job type" if jobs_type.nil? || jobs_type.strip.empty?
jobs_type = jobs_type.strip.downcase
puts "Scheduling jobs for server of type #{jobs_type}"
scheduler_file = File.join(RAILS_ROOT, 'config', 'jobs', "#{jobs_type}.rb")
if File.exists?(scheduler_file)
  SCHEDULER = Rufus::Scheduler.new
  require scheduler_file
  SCHEDULER.start

  ## Just need to keep this process alive
  while true
    sleep 300
  end
else
  raise "Error starting job scheduler. jobs_type #{jobs_type} requires a file at #{scheduler_file}. This file could not be found"
end
