#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils' 
require 'active_record'

time_zone = 'CDT'

ROOT = '/home/web/redmine'
DEVROOT = '/home/web/devredmine'
REPOS = '/git_repos/*'
REPOROOT = ROOT + REPOS
REPODEVROOT = DEVROOT + REPOS 

# Output time to Log File
puts Time.now

# Update Each Git Repo for LIVE Redmine
Dir[REPOROOT].each do |path|  
  puts path 
  FileUtils.cd(path)  
  system("git pull")
end

# Update Each Git Repo for DEV Redmine
Dir[REPODEVROOT].each do |path|
  puts path 
  FileUtils.cd(path)  
  system("git pull")
end

# Update Changesets for DEV Redmine
puts DEVROOT 
FileUtils.cd(DEVROOT)
puts "...fetching changesets"
system("/usr/local/bin/ruby script/runner --verbose \"Repository.fetch_changesets\" -e production")

# Update Changesets for LIVE Redmine
puts ROOT
FileUtils.cd(ROOT)
puts "....fetching changesets"
system("/usr/local/bin/ruby script/runner --verbose \"Repository.fetch_changesets\" -e production")

# Output Ending Statement
puts "Update Done! \n \n \n"
