set :application, 'application'

set :application_domain, 'secondary-domain.com'

set :user, 'username'

set :txd_primary_domain, 'primary-domain.com'

set :lighty_port, xxxx

set :repository, "http://primary-domain.com/svn/application/trunk"

set :svn_username, Proc.new { "username --password password" }

set :deploy_to, "/users/home/username/applications/application"

    

set :restart_via, :run
set :use_sudo, false


    

set :scm, :subversion


    

role :app, "secondary-domain.com"
role :web, "secondary-domain.com"
role :db, "secondary-domain.com"


    

desc "Make directories on TextDrive and setup lighttpd config"
task :setup_lighty do

  write_lighty_config_file
  write_lighttpdctrl_script

  # Do initial setup and then get the new code for this site
  setup
  deploy
  
  # Start the lighty server
  set :lighttpdctrl_restart, "/users/home/username/lighttpd/lighttpdctrl restart"
  set :lighttpdctrl_start, "/usr/local/sbin/lighttpd -f /users/home/username/lighttpd/lighttpd.conf"
  run lighttpdctrl_start
  
  #run "/usr/local/sbin/lighttpd -f /users/home/username/lighttpd/lighttpd.conf"

  # Schedule cron job to start when server restarts
  #run "crontab -l > /users/home/username/lighttpd/crontab.conf" # Backup existing settings
  run "echo '@reboot #{lighttpdctrl_start}' >> /users/home/username/lighttpd/crontab.conf"
  run "crontab /users/home/username/lighttpd/crontab.conf" # Apply

  # TODO Rest of web-based server config
  #http://manuals.textdrive.com/read/chapter/61    

end


    

   1. No sudo access on txd :)
      desc "Restart lighty"
      task :restart, :roles => :app do run "/users/home/username/lighttpd/lighttpdctrl restart"
      end

      desc "Write customized lighttpd.conf file to server."
      task :write_lighty_config_file do
      # Make some folders run "if [ ! -d lighttpd/cache/compress ]; then mkdir -p lighttpd/cache/compress; fi" run "if [ ! -d var/run ]; then mkdir -p var/run; fi" run "if [ ! -d var/log ]; then mkdir var/log; fi" run "if [ ! -d applications ]; then mkdir applications; fi" # Make the config file buffer = render(:template => <<LIGHTY_CONFIG)
      server.dir-listing = "disable"
      server.modules = ( "mod_rewrite", "mod_access", "mod_fastcgi", #"mod_compress", "mod_accesslog")
         1. a static document-root, for virtual-hosting take look at the
         2. server.virtual-* options
            server.document-root = "/users/home/username/applications/application/current/public/"
         3. where to send error-messages to
            server.errorlog = "/users/home/username/logs/lighttpd.error.log"
         4. files to check for if .../ is requested
            server.indexfiles = ( "index.php", "index.html", "index.htm", "index.rb")
         5. mimetype mapping
            mimetype.assign = ( ".pdf" => "application/pdf", ".sig" => "application/pgp-signature", ".spl" => "application/futuresplash", ".class" => "application/octet-stream", ".ps" => "application/postscript", ".torrent" => "application/x-bittorrent", ".dvi" => "application/x-dvi", ".gz" => "application/x-gzip", ".pac" => "application/x-ns-proxy-autoconfig", ".swf" => "application/x-shockwave-flash", ".tar.gz" => "application/x-tgz", ".tgz" => "application/x-tgz", ".tar" => "application/x-tar", ".zip" => "application/zip", ".mp3" => "audio/mpeg", ".m3u" => "audio/x-mpegurl", ".wma" => "audio/x-ms-wma", ".wax" => "audio/x-ms-wax", ".ogg" => "audio/x-wav", ".wav" => "audio/x-wav", ".gif" => "image/gif", ".jpg" => "image/jpeg", ".jpeg" => "image/jpeg", ".png" => "image/png", ".xbm" => "image/x-xbitmap", ".xpm" => "image/x-xpixmap", ".xwd" => "image/x-xwindowdump", ".css" => "text/css", ".html" => "text/html", ".htm" => "text/html", ".js" => "text/javascript", ".asc" => "text/plain", ".c" => "text/plain", ".conf" => "text/plain", ".text" => "text/plain", ".txt" => "text/plain", ".dtd" => "text/xml", ".xml" => "text/xml", ".mpeg" => "video/mpeg", ".mpg" => "video/mpeg", ".mov" => "video/quicktime", ".qt" => "video/quicktime", ".avi" => "video/x-msvideo", ".asf" => "video/x-ms-asf", ".asx" => "video/x-ms-asf", ".wmv" => "video/x-ms-wmv", ".bz2" => "application/x-bzip", ".tbz" => "application/x-bzip-compressed-tar", ".tar.bz2" => "application/x-bzip-compressed-tar" )

            #Server ID Header
            server.tag = "lighttpd | TextDriven"
               1. accesslog module
                  accesslog.filename = "/users/home/username/logs/access_log"
               2. deny access the file-extensions

            #
         6. ~ is for backupfiles from vi, emacs, joe, ...
         7. .inc is often used for code includes which should in general not be part
         8. of the document-root
            url.access-deny = ( "~", ".inc" )
               1. Options that are good to be but not neccesary to be changed #######



    

   1. bind to port (default: 80)
      server.port = <%= lighty_port %>
   2. bind to localhost (default: all interfaces)

      #server.bind = "grisu.home.kneschke.de"
   3. to help the rc.scripts
      server.pid-file = "/users/home/username/var/run/lighttpd.pid"

      ###############
         1. To add other domains or subdomains, copy this section and replace your primary domain
         2. with the appropriate other domain.

            #
            $HTTP["host"] =~ "(www.)?secondary-domain.com" {
         3. server.document-root = "/users/home/username/applications/application/current/public" server.errorlog = "/users/home/username/logs/loops.lighttpd-error.log" accesslog.filename = "/users/home/username/logs/access_log"



  url.rewrite = ( "/$" => "index.html", "([^.]+)$" => "$1.html" )
  server.error-handler-404 = "/dispatch.fcgi" 

  fastcgi.server = ( ".fcgi" =>
    ( "localhost" =>
        (
          "socket"   => "/users/home/username/applications/application/lighttpd-fcgi.socket",
          "bin-path" => "/users/home/username/applications/application/current/public/dispatch.fcgi",
          "bin-environment" => ( "RAILS_ENV" => "production" ),
          "min-procs" => 1,
          "max-procs" => 2,
          "idle-timeout" => 60
        )
    )
  )
 } 
    

###############


    

   1. change uid to <uid> (default: don't care)
      server.username = "<%= user %>"
   2. change uid to <uid> (default: don't care)
      server.groupname = "<%= user %>"
         1. compress module
         1. FIX Does each virtual sub-host need its own compress.cache-dir ?

            #compress.cache-dir = "/home/<%= user %>/lighttpd/cache/compress/"

            #compress.filetype = ("text/plain", "text/html")

            LIGHTY_CONFIG
            # Write the config file to disk put buffer, "lighttpd/lighttpd.conf" #, :mode => xxxx
            end

            desc "Sets up lighttpd control script for starting, stopping, and restarting lighty"
            task :write_lighttpdctrl_script do
            buffer = render(:template => <<LIGHTTPDCTRL)

            #!/bin/sh

            #
         2. lighty update script to kill stray processes.

            #
         3. AUTHOR: Jarkko Laine http://jlaine.net/blog

            #

            LIGHTTPD_CONF=/users/home/username/lighttpd/lighttpd.conf
            PIDFILE=/users/home/username/var/run/lighttpd.pid

            case "$1" in start) # Starts the lighttpd deamon echo "Starting Lighttpd" lighttpd -f $LIGHTTPD_CONF ;; stop) # stops the daemon bt cat'ing the pidfile echo "Stopping Lighttpd" kill `cat $PIDFILE` # kill the fastcgi processes, too ps auxww|grep 'ruby'|awk '{print $2}'|xargs kill -9 ;; restart) ## Stop the service regardless of whether it was ## running or not, start it again. echo "Restarting Lighttpd" $0 stop $0 start ;; reload) # reloads the config file by sending HUP echo "Reloading config" kill -HUP `cat $PIDFILE` ;; *) echo "Usage: lighttpdctrl (start|stop|restart|reload)" exit 1 ;;
            esac
            LIGHTTPDCTRL put buffer, "lighttpd/lighttpdctrl", :mode => 0755
            end

            #
            task :after_deploy do

            #
            run "cp /users/home/username/etc/applicationn.yml /users/home/username/applications/application/current/config/database.yml"

            #

            #

            #setup links to directories in the shared directory

            #

            #delete "#{current_path}/public/photos", :recursive => true

            #

            #run "ln -nfs #{shared_path}/photos #{current_path}/public/photos"

            #
            end

            desc "Deletes all directories and contents made by setup_lighty"
            task :teardown_lighty do
            run "rm -rf lighttpd" run "rm -rf var" run "rm -rf applications" # TODO Clear cron jobs that were setup # Kill processes run "killall -9 lighttpd" run "killall -9 ruby"

            end

            #desc "Start the spinner daemon, using local lighttpdctrl"

            #task :spinner, :roles => :app do
         4. run "/home/#{user}/lighttpd/lighttpdctrl restart"

            #end
         5. =================================
         6. Sample tasks from original deploy.rb
         7. Some may not work with TextDrive (spinner, etc.)
         8. =================================



    

   1. Define tasks that run on all (or only some) of the machines. You can specify
   2. a role (or set of roles) that each task should be executed on. You can also
   3. narrow the set of servers to a subset of a role by specifying options, which
   4. must match the options given for the servers to select (like :primary => true)



    

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC


    

task :backup, :roles => :db, :only => { :primary => true } do

  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
    ch.send_data "thepasswordn" if out =~ /^Enter password:/
  end

end

    

   1. Tasks may take advantage of several different helper methods to interact
   2. with the remote server(s). These are:

      #
   3. * run(command, options={}, &block): execute the given command on all servers
   4. associated with the current task, in parallel. The block, if given, should
   5. accept three parameters: the communication channel, a symbol identifying the
   6. type of stream (:err or :out), and the data. The block is invoked for all
   7. output from the command, allowing you to inspect output and act
   8. accordingly.
   9. * sudo(command, options={}, &block): same as run, but it executes the command
  10. via sudo.
  11. * delete(path, options={}): deletes the given file or directory from all
  12. associated servers. If :recursive => true is given in the options, the
  13. delete uses "rm -rf" instead of "rm -f".
  14. * put(buffer, path, options={}): creates or overwrites a file at "path" on
  15. all associated servers, populating it with the contents of "buffer". You
  16. can specify :mode as an integer value, which will be used to set the mode
  17. on the file.
  18. * render(template, options={}) or render(options={}): renders the given
  19. template and returns a string. Alternatively, if the :template key is given,
  20. it will be treated as the contents of the template to render. Any other keys
  21. are treated as local variables, which are made available to the (ERb)
  22. template.



    

#desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do

  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"

end

    

   1. You can use "transaction" to indicate that if any of the tasks within it fail,
   2. all should be rolled back (for each task that specifies an on_rollback
   3. handler).



    

desc "A task demonstrating the use of transactions."
task :long_deploy do

  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web

end


    

desc "Used only for deploying when the spinner isn't running"
task :cold_deploy do

  transction do
    update_code
    symlink
  end

  spinner

end