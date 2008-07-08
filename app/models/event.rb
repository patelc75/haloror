class Event < ActiveRecord::Base
  include UtilityHelper
  
  belongs_to :user
  #belongs_to :alert_type
  
  belongs_to :event, :polymorphic => true
  
  has_many :event_actions
  
  acts_as_authorizable
  
  def string(user)
    strings = {'Fall' => 'Fell'}
    
    # "#{user.profile.first_name} #{strings[self.event_type]}"
    "#{user.profile.first_name}: #{self.event_type}"
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
  
  def self.get_latest_event_by_type_and_user(type, user_id)
    event = Event.find(:first, :order => "timestamp DESC", :conditions => "event_type = '#{type}' and user_id='#{user_id}'")
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
      device_unavailable = Event.get_latest_event_by_type_and_user('DeviceAvailableAlert', user.id)
      if Event.get_latest_event_by_type_and_user('DeviceUnavailableAlert', user.id).timestamp > device_unavailable.timestamp
        UtilityHelper.camelcase_to_spaced('DeviceUnavailableAlert')
      else
        if(device_unavailable.timestamp > connected_state.timestamp)
          connected_state = device_unavailable
        end
        strap_removed = Event.get_latest_event_by_type_and_user('StrapFastened', user.id)
        if Event.get_latest_event_by_type_and_user('StrapRemoved', user.id).timestamp > strap_removed.timestamp
          UtilityHelper.camelcase_to_spaced('StrapRemoved')
        else
          if(strap_removed.timestamp > connected_state.timestamp)
            connected_state = strap_removed
          end
            
          UtilityHelper.camelcase_to_spaced(connected_state.event_type.to_s)
        end
      end          
    end
  end
end
