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

  def credit_card_types
    return {
      'VISA'              => 'visa',
      'MasterCard'        => 'master',
      'American Express'  => 'american_express',
      'Discover'          => 'discover'
    }
  end

  # accepts the name of model as string, returns and constant for the model
  #   singular, plural, with or without underscore
  #   examples: user, book_store. book stores, account payables
  def model_name_to_constant(name)
    name.singularize.split(' ').collect(&:capitalize).join.constantize
  end
  
  # just ensure the folder exists as specified in the full path
  def ensure_folder(path)
    paths = csv_to_array(path)
    Dir.mkdir(path) unless File.exists?(path)
  end
  
  # take a comma/<delimiter> separated string/text and return an array of strings.
  # no blank spaces before/after each element value
  def csv_to_array(phrase, delimiter = ',')
    phrase.split(delimiter).collect {|p| p.lstrip.rstrip }
  end
end
