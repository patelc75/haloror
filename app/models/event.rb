class Event < ActiveRecord::Base
  include UtilityHelper
  
  has_one :call_center_session
  has_one :call_center_wizard
  has_many :notes
  belongs_to :user
  #belongs_to :alert_type
  
  belongs_to :event, :polymorphic => true
  
  has_many :event_actions
  
  def self.create_event(user_id, event_type, event_id, ts)
    now = Time.now
    Event.create(:user_id => user_id, 
          :event_type => event_type, 
          :event_id => event_id, 
          :timestamp => ts || now,
          :timestamp_server => now)
  end
  
  def string(user)
    strings = {'Fall' => 'Fell'}
    
    # "#{user.profile.first_name} #{strings[self.event_type]}"
    "#{user.profile.first_name}: #{self.event_type}"
  end
  
  def notes_string
    string = "Event Notes\n"
    notes.each do |note|
      string += UtilityHelper.format_datetime_readable(note.created_at, user) + " by " + note.creator.name() + "\n" +
        note.notes + "\n\n"
    end
    string
  end
  
  def accepted?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'accepted'
    end
    
    return false
  end
  
  def resolved?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'resolved'
    end
    
    return false
  end

  def false_alarm?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'false_alarm'
    end
    
    return false
  end

  
  def self.get_latest_event_by_type_and_user(type, user_id)
    event = Event.find(:first, :order => "timestamp DESC", :conditions => "event_type = '#{type}' and user_id='#{user_id}' AND timestamp <= '#{Time.now.to_s}'")
    if(event == nil)
      event = Event.new
      event.timestamp = "Jan 1 1970 00:00:00 -0000"
      event.event_type = "Not found"
    end
    
    event
  end
  
  def self.get_connectivity_state_by_user(user)
    gateway_online = Event.get_latest_event_by_type_and_user('GatewayOnlineAlert', user.id)
    if Event.get_latest_event_by_type_and_user('GatewayOfflineAlert', user.id).timestamp > gateway_online.timestamp
      UtilityHelper.camelcase_to_spaced('GatewayOfflineAlert')
    else
      connected_state = gateway_online
      device_available = Event.get_latest_event_by_type_and_user('DeviceAvailableAlert', user.id)
      if Event.get_latest_event_by_type_and_user('DeviceUnavailableAlert', user.id).timestamp > device_available.timestamp
        UtilityHelper.camelcase_to_spaced('DeviceUnavailableAlert')
      else
        if(device_available.timestamp > connected_state.timestamp)
          connected_state = device_available
        end
        strap_fastened = Event.get_latest_event_by_type_and_user('StrapFastened', user.id)
        if Event.get_latest_event_by_type_and_user('StrapRemoved', user.id).timestamp > strap_fastened.timestamp
          UtilityHelper.camelcase_to_spaced('StrapRemoved')
        else
          if(strap_fastened.timestamp > connected_state.timestamp)
            connected_state = strap_fastened
          end
          
          access_mode = Event.get_latest_event_by_type_and_user('AccessMode', user.id)
	  	  if (access_mode.event_type != 'Not found') 
	  	  	if(access_mode.event.mode == 'dialup')
              access_mode.event_type = 'DialUp'
              connected_state = access_mode
        	end
          end
            
          UtilityHelper.camelcase_to_spaced(connected_state.event_type.to_s)
        end
      end          
    end
  end
end
