############################
# Based on the original DreamHost deploy.rb recipe
#
#
# GitHub settings #######################################################################################
default_run_options[:pty] = true
set :repository,  "git@github.com:patelc75/haloror.git" #GitHub clone URL
set :scm, "git"
set :scm_passphrase, "irdikt75" #This is the passphrase for the ssh key on the server deployed to
set :branch, "master"
set :scm_verbose, true
#########################################################################################################
set :user, 'web' 
set :domain, 'server.dreamhost.com'  # Dreamhost servername where your account is located 
set :project, 'projectname'  # Your application as its called in the repository
set :application, 'haloror'  # Your app's location (domain or sub-domain name as setup in panel)
set :applicationdir, "/home/#{user}/#{application}"  # The standard Dreamhost setup
set :lsws_cmd, "/opt/lsws/bin/lswsctrl"
set :deploy_to, "/home/web/integration"


if ENV.has_key?('SERVER') && !ENV['SERVER'].nil?
  role :web, ENV['SERVER']
  role :app, ENV['SERVER']
  role :db, ENV['SERVER']
else
  role :app, "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
  role :web, "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
  role :db,  "67-207-146-58.slicehost.net", "67-207-132-26.slicehost.net"
end

# Don't change this stuff, but you may want to set shared files at the end of the file ##################
# deploy config
set :deploy_to, :applicationdir
set :deploy_via, :remote_cache

# roles (servers)
role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
 [:start, :stop, :restart, :finalize_update, :migrate, :migrations, :cold].each do |t|
   desc "#{t} task is a no-op with mod_rails"
   task t, :roles => :app do ; end
 end
 
  desc "Restart litespeed web server" 
  task :restart, :roles => :app do
    sudo "#{lsws_cmd} restart"
    sudo "cd #{deploy_to}; export RAILS_ENV=production; ./config/jobs/control.rb task restart &"
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
    sudo "cd #{deploy_to}; export RAILS_ENV=production; ./config/jobs/control.rb task stop"
  end

  desc "Start script/runner which is used to run background jobs"
  task :start_background_jobs, :roles => :app do
    sudo "cd #{deploy_to}; export RAILS_ENV=production; ./config/jobs/control.rb task start &"
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

# additional settings
default_run_options[:pty] = true  # Forgo errors when deploying from windows
#ssh_options[:keys] = %w(/Path/To/id_rsa)            # If you are using ssh_keys
#set :chmod755, "app config db lib public vendor script script/* public/disp*"
set :use_sudo, false

#########################################################################################################

#for use with shared files (e.g. config files)
after "deploy:update_code" do
  run "ln -s #{shared_path}/database.yml #{release_path}/config"
  run "ln -s #{shared_path}/environment.rb #{release_path}/config"
end

after "deploy", "deploy:cleanup"
#after "deploy", "deploy:restart"
after "deploy", "deploy:after_update_code"
after "deploy", "deploy:migrate"
