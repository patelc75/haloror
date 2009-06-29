# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    include UtilityHelper
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
 
 def image_for_event(event)
   type = event[:event_type]
   if ['Fall', 'Panic'].include? type
     return image_tag('/images/severe_button_82_22.png')
   elsif ['GatewayOfflineAlert', 'DeviceUnavailbleAlert', 'BatteryCritical'].include? type
     return image_tag('/images/caution_button_82_22.png')
   elsif ['BatteryReminder'].include? type
   	if event.event.reminder_num < 3
   		return image_tag('/images/caution_button_82_22.png')
   	elsif event.event.reminder_num == 3
   		return image_tag('/images/severe_button_82_22.png')
   	end
   else 
     return image_tag('/images/normal_button_82_22.png')
   end
 end
end
