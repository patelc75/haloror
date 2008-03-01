# File defines all the jobs that we schedule with Rufus to run in the
# background. This file should be sourced exactly once at server
# startup.

## Environment variable jobs_type defines the types of jobs to run on
## this instance. This is useful as you can start several rails
## processes and segment which jobs run on which process. This is most
## critical to ensure jobs you care a lot about get dedicated
## processes.

## To start up the background jobs, start up a rails server using something like:
## export JOBS_TYPE=task
## thin -e production -p 8900 -a 127.0.0.1 -u web -g web -l /home/web/haloror/log/task-production.log start >> /home/web/haloror/log/task-production.log 2>&1

## To install rufus: gem install rufus-scheduler
## To install thin: gem install thin

jobs_type = ENV['JOBS_TYPE']
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
