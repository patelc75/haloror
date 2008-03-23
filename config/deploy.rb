set :application, "integration"
set :repository,  "http://svn2.assembla.com/svn/halotrac/trunk/"

set :user, "web" 

set :lsws_cmd, "/opt/lsws/bin/lswsctrl"

set :deploy_to, "/home/web/integration"

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


namespace :deploy do
  desc "Restart litespeed web server" 
  task :restart, :roles => :app do
    sudo "#{lsws_cmd} restart"
    sudo "cd #{deploy_to}; ./config/jobs/control.rb -e production task restart"
  end
  
  desc "Stop litespeed server" 
  task :stop, :roles => :app do
    sudo "#{lsws_cmd} stop" 
    stop_background_jobs
  end
  
  desc "Start litespeed web server" 
  task :start, :roles => :app do
    sudo "#{lsws_cmd} start" 
    start_background_jobs
  end

  desc "Stop script/runner which is used to run background jobs"
  task :stop_background_jobs, :roles => :app do
    sudo "cd #{deploy_to}; ./config/jobs/control.rb -e production task stop"
  end

  desc "Start script/runner which is used to run background jobs"
  task :start_background_jobs, :roles => :app do
    sudo "cd #{deploy_to}; ./config/jobs/control.rb -e production task start"
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



after "deploy", "deploy:cleanup"
#after "deploy", "deploy:restart"
after "deploy", "deploy:after_update_code"
after "deploy", "deploy:migrate"


