class GatewayEventObserver < ActiveRecord::Observer
  include ServerInstance
  observe AccessMode
  
  #change this code to loop through all uses associated with device, write new method to come up array of users mapped to GW
  def before_save(event)
    if event.device_id < 0 or event.device == nil
      raise "#{event.class.to_s}: device_id = #{event.device_id} is invalid"
    else
      users = event.device.users
      users.each do |u|
  		#spoof the user_id so the email will be sent properly      
      	event[:user_id] = u.id
  		CriticalMailer.deliver_device_event_caregiver(event)
      end
    end
  end
  
  #change this code to loop through all uses associated with device
  def after_save(alert)
  	users = alert.device.users
  	users.each do |u|
  	  alert[:user_id] = u.id
  	  Event.create_event(alert.user_id, alert.class.to_s, alert.id, alert.timestamp)		
  	end
  end
end

