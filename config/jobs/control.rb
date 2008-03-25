#!/usr/bin/env ./script/runner

# Executable to startup the job processor. Accepts one parameter - the
# name of the file containing the tasks to run
#
# Ex: ./config/jobs/control.rb task start
# Ex: ./config/jobs/control.rb task stop
# Ex: ./config/jobs/control.rb task restart
#
# Will load the file named task.rb and will run those jobs in the
# background

# Lightweight wrapper to setup logging and keep track of process ID to
# make sure at most one task server is running at any given team
class TaskStartup

  # <tt>jobs_type</tt>: e.g. task - must match a file in this directory named
  # jobs_type.rb (e.g. task.rb)
  def TaskStartup.start(jobs_type)
    ts = TaskStartup.new(jobs_type)
    begin
      ts.record_pid
      yield
      ts.run
    ensure
      ts.remove_pid_file
    end
  end

  def TaskStartup.stop(jobs_type)
    ts = TaskStartup.new(jobs_type)
    ts.remove_pid_file
  end

  def initialize(jobs_type)
    @jobs_type = jobs_type
    @pid_file = File.join(RAILS_ROOT, 'log', "#{jobs_type}-#{ENV['RAILS_ENV']}.pid")
    maybe_shutdown_previous_process
  end

  def record_pid
    open(@pid_file, 'wb') { |f| f << Process.pid.to_s }
  end

  def run
    ## Just need to keep this process alive
    while true
      sleep 300
    end
  end

  def remove_pid_file
    File.delete(@pid_file) if File.file?(@pid_file)
  end

  private
  # handles cleanup of any prior, still running process.
  def maybe_shutdown_previous_process
    if File.file?(@pid_file)
      if pid = IO.read(@pid_file)
        pid = pid.strip
        if !pid.empty? && pid.to_i > 0
          begin
            Process.kill("SIGHUP", pid.to_i)
            puts "Killed #{@jobs_type} process #{pid.to_i}"
          rescue Errno::ESRCH => e
            ## No such process - ignore error
          end
        end
      end
      remove_pid_file
    end
  end

end

jobs_type = ARGV.shift
raise "Specify job type" if jobs_type.nil? || jobs_type.strip.empty?
jobs_type = jobs_type.strip.downcase

scheduler_file = File.join(RAILS_ROOT, 'config', 'jobs', "#{jobs_type}.rb")
if !File.exists?(scheduler_file)
  raise "Error starting job scheduler. jobs_type #{jobs_type} requires a file at #{scheduler_file}. This file could not be found"
end

flag = ARGV.shift
if flag.nil? || flag.empty? 
  raise "Specify start|stop|restart"
end

if flag == "stop" || flag == "restart"
  puts "Stopping jobs for server of type #{jobs_type}"
  TaskStartup.stop(jobs_type)
end

if flag == "start" || flag == "restart"
  puts "Starting jobs for server of type #{jobs_type}"
  TaskStartup.start(jobs_type) do
    log_path = File.join(RAILS_ROOT, 'log', "#{jobs_type}-#{ENV['RAILS_ENV']}.log")
    RAILS_DEFAULT_LOGGER = Logger.new(log_path)
    ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER
    
    SCHEDULER = Rufus::Scheduler.new
    require scheduler_file
    SCHEDULER.start
  end
end
  
