set :application, "captest"
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
set :deploy_to, "/home/web/captest"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :subversion
set :deploy_via, :export

set :svn_username, 'madhukarpadma'

role :app, "67-207-132-26.slicehost.net"
role :web, "67-207-132-26.slicehost.net"
role :db,  "67-207-132-26.slicehost.net", :primary => true

#task :after_update_code, :roles => :app do
 # sudo <<-CMD
  #sh -c "chown -R #{cap_user}:#{cap_group} #{release_path} &&
   #      chmod -R g+w #{release_path}"
  #CMD
#end

#task :restart, :roles => :app do
 # sudo "#{lsws_cmd} restart"
#end


#task :restart, :roles => :app do
 # sudo "#{lsws_cmd} restart"
#end

namespace :deploy do
  desc "Restart litespeed web server" 
  task :restart, :roles => :app do
    sudo "#{lsws_cmd} restart" 
  end
  
  desc "Stop litespeed server" 
  task :stop, :roles => :app do
    sudo "#{lsws_cmd} stop" 
  end
  
  desc "Start litespeed web server" 
  task :start, :roles => :app do
    sudo "#{lsws_cmd} start" 
  end
end  



#def run_task_on_single_host
 # Capistrano::Configuration::Roles.class_eval do
  #  yield
  #end
#end

#if ENV['server']
 # run_task_on_single_host do
  #  alias old_role role
   # def role(which, *args)
    #  options = args.last.is_a?(Hash) ? args.pop : {}
     # which = which.to_sym
      #args.each do |host|
       # next unless ENV['server'] == host
        #roles[which] << ServerDefinition.new(host, options)
      #end
    #end
  #end
#end
  
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

#after "deploy", "deploy:cleanup"
after "deploy", "deploy:restart"
#after "deploy", "deploy:after_update_test"


#set :use_sudo, false 


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
