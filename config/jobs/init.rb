# File defines all the jobs that we schedule with Rufus to run in the
# background. This file should be sourced exactly once at server
# startup.

## Environment variable jobs_type defines the types of jobs to run on
## this instance. This is useful as you can start several rails
## processes and segment which jobs run on which process. This is most
## critical to ensure jobs you care a lot about get dedicated
## processes.

jobs_type = ENV['jobs_type']
if jobs_type
  jobs_type = jobs_type.strip.downcase
  puts "Scheduling jobs for server of type #{jobs_type}"
  scheduler_file = File.join(File.dirname(__FILE__), "#{jobs_type}.rb")
  if File.exists?(scheduler_file)
    SCHEDULER = Rufus::Scheduler.new
    require scheduler_file
    SCHEDULER.start
  else
    raise "Error starting job scheduler. jobs_type #{jobs_type} requires a file at #{scheduler_file}. This file could not be found"
  end
end
