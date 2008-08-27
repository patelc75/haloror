# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    
  #these are taken from cd /var/lib/pgsql/data/pg_hba.conf on dfw-web1
  #don't need this because we're filter on Google Analytics site (Edit Settings)
#  @@google_analytics_filter = ["74.138.221.245", 
#                               "24.214.236.100", 
#                               "24.214.236.101", 
#                               "24.214.110.48", 
#                               "99.150.101.191", 
#                               "68.174.89.40", 
#                               "65.13.94.42"]
#  
  def google_analytics_check    
   (request.host == 'myhalomonitor.com' or request.host == 'www.myhalomonitor.com') #and !@@google_analytics_filter.include? request.env["REMOTE_ADDR"].to_s
  end
end
