set :application, "integration"
set :repository,  "http://svn2.assembla.com/svn/halotrac/trunk/"
#ssh_options[:port] = 80
#set :secure_ssh_port, 80
set :user, "web" 
#set :runner, nil
#default_run_options[:pty] = true
#set :cap_user, "caprec"
#set :cap_group, "caprec"
#set :cap_user, "mywebapp"
#set :cap_group, "mywebapp"
set :lsws_cmd, "/opt/lsws/bin/lswsctrl"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
#set :deploy_to, "/home/web/#{application}"
set :deploy_to, "/home/web/integration"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
#set :scm, :subversion
#set :deploy_via, :export

#set :scm_username, 'madhukarpadma'
#set :scm_command, '/usr/bin/svn'
#set :local_scm_command, :default

#default_run_options[:pty] = true
set :svn_username, 'madhukarpadma'


if ENV.has_key?('SERVER') && !ENV['SERVER'].nil?
  role :web, ENV['SERVER']
  role :app, ENV['SERVER']
  role :db, ENV['SERVER']
else
  role :app, "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
  role :web, "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
  role :db,  "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
end

#set :scm_username, 'madhukarpadma'

#def run_task_on_single_host
 # Capistrano::Configuration::Roles.class_eval do
  #  yield
#  end
#end

#if ENV['server']
 # run_task_on_single_host do
  #  alias old_role role
   # def role(which, *args)
    #  options = args.last.is_a?(Hash) ? args.pop : {}
     # which = which.to_sym
    #  args.each do |host|
     #   next unless ENV['server'] == host
      #  roles[which] << ServerDefinition.new(host, options)
    #  end
  #  end
#  end
#end


#role :app, "67-207-146-58.slicehost.net"
#role :web, "67-207-146-58.slicehost.net"
#role :db,  "67-207-146-58.slicehost.net", :primary => true

#role :app, "67-207-132-26.slicehost.net"
#role :web, "67-207-132-26.slicehost.net"
#role :db,  "67-207-132-26.slicehost.net", :primary => true

#role :app, "www.myhalomonitor.com","integration.myhalomonitor.com"
#role :web, "www.myhalomonitor.com","integration.myhalomonitor.com"
#role :db,  "www.myhalomonitor.com", :primary => true

#role :app, "integration.myhalomonitor.com"
#role :web, "integration.myhalomonitor.com"
#role :db,  "integration.myhalomonitor.com", :primary => true

#role :app, "myhalomonitor.com"
#role :web, "myhalomonitor.com"
#role :db,  "myhalomonitor.com", :primary => true

#task :after_update_code, :roles => :app do
 # sudo <<-CMD
  #sh -c "chown -R #{cap_user}:#{cap_group} #{release_path} &&
   #      chmod -R g+w #{release_path}"
  #CMD
#end

namespace :deploy do
  desc "Restart litespeed web server" 
  task :restart, :roles => :app do
    sudo "#{lsws_cmd} restart" 
    sudo "thin stop"
    sudo "export JOBS_TYPE=task; thin -e production -p 8900 -a 127.0.0.1 -u web -g web -l /home/web/haloror/log/task-production.log start >> /home/web/haloror/log/task-production.log 2>&1"
  end
  
  desc "Stop litespeed server" 
  task :stop, :roles => :app do
    sudo "#{lsws_cmd} stop" 
    sudo "thin stop"
  end
  
  desc "Start litespeed web server" 
  task :start, :roles => :app do
    sudo "#{lsws_cmd} start" 
    sudo "export JOBS_TYPE=task; thin -e production -p 8900 -a 127.0.0.1 -u web -g web -l /home/web/haloror/log/task-production.log start >> /home/web/haloror/log/task-production.log 2>&1"
  end

  desc "copy database.yml file"
  task :after_update_code, :roles => :app do 
  run "cp #{release_path}/config/production_database.yml 
  #{release_path}/config/database.yml" 
  end
  
  task :show_tasks do
  run("cd #{deploy_to}/current; /usr/bin/rake -T")
  end
end  

  
#  desc "Start litespeed web server" 
 # task :start_test, :roles => :app do
  #  sudo "#{lsws_cmd} start" 
  #end

  #desc "Stop litespeed server" 
  #task :stop_test, :roles => :app do
   # sudo "#{lsws_cmd} stop" 
  #end

  #task :after_update_test, :roles => :app do
   # sudo <<-CMD
    #sh -c "chown -R #{cap_user}:#{cap_group} #{release_path} && chmod -R g+w #{release_path}"
    #CMD
    #sudo "chmod -R 2770 /home/web/captest" 
    #sudo "chgrp -R www-data /home/web/captest"
  #end
#end

after "deploy", "deploy:cleanup"
after "deploy", "deploy:restart"
after "deploy", "deploy:after_update_code"
#after "deploy", "deploy:migrate"

#after "deploy", "deploy:after_update_test"


#set :use_sudo, false 

#task :restart, :roles => :app do
 # sudo "#{lsws_cmd} restart"
#end


#task :restart, :roles => :app do
 # sudo "#{lsws_cmd} restart"
#end


#deploy.app.task :after_start do
 # restart_web_server
#end


#deploy.task :restart_web_server, :roles => :web do
 # /opt/lsws/bin/lswsctrl restart"
#end


#task :restart_web_server, :roles => :app do
 
#task :restart_web_server do
 #"#{lsws_cmd} restart"
#end

#after "deploy:start", :restart_web_server

#role :app, "67-207-132-26.slicehost.net"
#role :web, "67-207-132-26.slicehost.net"
#role :db,  "67-207-132-26.slicehost.net", :primary => true
