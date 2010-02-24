# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include UtilityHelper
  include UserHelper
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
   elsif ['GatewayOfflineAlert', 'DeviceUnavailbleAlert', 'BatteryCritical','DialUpStatus','StrapRemoved'].include? type
     return image_tag('/images/caution_button_82_22.png')
   elsif ['BatteryReminder'].include? type
   	if event.event.reminder_num < 3
   		return image_tag('/images/caution_button_82_22.png')
   	elsif event.event.reminder_num == 3
   		return image_tag('/images/severe_button_82_22.png')
   	elsif event.event.reminder_num == 4
   	  return image_tag('/images/normal_button_82_22.png')
   	end
   else 
     return image_tag('/images/normal_button_82_22.png')
   end
  end

  # collect activerecord errors using add_to_base
  # required only for procedural progamming used in user, user_intake etc
  #
  def collect_active_record_errors(collect_here, names_to_collect_from = [])
    if collect_here.is_a? ActiveRecord::Base # forget otherwise
      #
		  # = Add errors and validation to activerecord
		  # example: add errors from @profile and @user objects to @user_intake
		  # Errors will be added only for variables that exist right now
		  #   errors may be caused by activerecord validations of these objects using save!
		  #   this will show proper validation errors on the form
		  #
	    names_to_collect_from.each do |obj_name|
	      obj = eval("@#{obj_name}")
        #
        # variable does not exist? or not AR? add a general validation error
        if obj.blank? || !obj.is_a?(ActiveRecord::Base)
          collect_here.errors.add_to_base "#{obj_name} data is not appropriate. Please notify the administrator if you have filled the profile correctly but see this error."
        else
          #
          # variable exists? is AR?, add specific validation errors
          obj.errors.each_full { |e| collect_here.errors.add_to_base e } unless obj.errors.count.zero?
        end
      end # each
    end # only collect when AR
  end
  
end
