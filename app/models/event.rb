class Event < ActiveRecord::Base
  include UtilityHelper
  
  has_one :call_center_session
  has_one :call_center_wizard
  has_many :notes
  belongs_to :user # WARNING: What is this association?
  has_many :users, :class_name => "User", :foreign_key => "last_event_id"
  #belongs_to :alert_type
  
  belongs_to :event, :polymorphic => true
  
  has_many :event_actions

  # triggers ----------------------------------
  
  #
  #  Wed Dec  8 00:52:21 IST 2010, ramonrails
  #   * switched off for 1.6.0 www issues
  # # cache trigger
  # # saves the latest event status in users table
  # def after_save
  #   if (user = User.find(user_id))
  #     user.last_event_id = id
  #     user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
  #   end
  #   # User.update(user_id, {:last_event_id => id})
  # end

  # class methods ------------------------------

  # returns the connectivity state for given user
  def self.connectivity_status(user = nil)
    unless user.blank?
      # check these sets in priority order of appearance
      [
        ['GatewayOnlineAlert', 'GatewayOfflineAlert'],
        ['DeviceAvailableAlert', 'DeviceUnavailableAlert'],
        ['StrapFastened', 'StrapRemoved'],
        ['AccessMode']
        ].each do |status_set|
          # fetch the latest event row for the given event types and user
          # break out when a match is found
        break if (event = Event.first( :conditions => {:event_type => status_set, :user_id => user}, :order => 'timestamp DESC'))
        # break if (event = User.find(user).last_event) # can use this shortcut?
      end
    end
    # if nothing was found, create a blank one, else keep the found one
    event ||= Event.new(:timestamp => "Jan 1 1970 00:00:00 -0000", :event_type => "DialUp")
    event
  end
  
  def self.create_event(user_id, event_type, event_id, ts)
    now = Time.now
    Event.create(:user_id => user_id, 
          :event_type => event_type, 
          :event_id => event_id, 
          :timestamp => ts || now,
          :timestamp_server => now)
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
    # CHANGED: quicker and faster algorithm. Need to confirm before implementing
    # this does not even need the additional method get_latest_event_by_type_and_user
    #
    # can the new method connectivity_state be used ?
    
    # Need to understand the logic in this method. Quite confusing, specially near the DialUp
    #
    gateway_online  = Event.get_latest_event_by_type_and_user('GatewayOnlineAlert', user.id)
    gateway_offline = Event.get_latest_event_by_type_and_user('GatewayOfflineAlert', user.id)
    if gateway_offline.timestamp > gateway_online.timestamp
      gateway_offline
    else
      connected_state = gateway_online
      device_available  = Event.get_latest_event_by_type_and_user('DeviceAvailableAlert', user.id)
      device_unavilable = Event.get_latest_event_by_type_and_user('DeviceUnavailableAlert', user.id)
      if device_unavilable.timestamp > device_available.timestamp
        device_unavilable
      else
        if(device_available.timestamp > connected_state.timestamp)
          connected_state = device_available
        end
        strap_fastened = Event.get_latest_event_by_type_and_user('StrapFastened', user.id)
        strap_removed  = Event.get_latest_event_by_type_and_user('StrapRemoved', user.id)
        if strap_removed.timestamp > strap_fastened.timestamp
          strap_removed
        else
          if(strap_fastened.timestamp > connected_state.timestamp)
            connected_state = strap_fastened
          end
          
          access_mode = Event.get_latest_event_by_type_and_user('AccessMode', user.id)
	  	    if (access_mode.event_type != 'Not found') 
	  	  	  if(access_mode.event.mode == 'dialup') # WARNING: what is event.mode ?
                access_mode.event_type = 'DialUp'
                connected_state = access_mode
          	end
          end
            
          connected_state
        end
      end          
    end
  end

  # instance methods ------------------------------
  def can_map?
    self.respond_to?( :lat) && self.respond_to?( :long)
  end

  def location
    _location = [lat, long].compact.join(',') if can_map?
    if _location.blank?
      _location = (user.blank? ? 'U.S.A.' : (user.location || 'U.S.A.'))
    end
  end 
  
  def filter_on_events_page?
    return_val = false 
    
    FILTERED_EVENTS_FOR_NON_SUPER_ADMINS.each do |klass|  
      return_val = true if self.event_type == klass.class_name
    end                
    
    [Panic, Fall, GwAlarmButton].each do |klass|
      return_val = true if self.event_type == klass.class_name and self.event.resolved == "auto"
    end                  
    
    return_val
  end

  # returns boolean for the type of event
  #   these names are collected from the local development database. just run the following query in console
  #   Event.all( :select => "DISTINCT event_type").collect(&:event_type).sort.collect(&:tableize).collect(&:singularize).collect {|e| "#{e}?"}
  # Usage:
  #   Event.last.fall?
  #   Event.last.panic?
  ["access_mode?", "battery_charge_complete?", "battery_critical?", "battery_plugged?", "battery_reminder?",
    "battery_unplugged?", "call_center_deferred?", "call_center_follow_up?", "device_available_alert?",
    "device_unavailable_alert?", "event_action?", "fall?", "gateway_offline_alert?", "gateway_online_alert?",
    "gw_alarm_button?", "gw_alarm_button_timeout?", "panic?", "strap_fastened?", "strap_off_alert?",
    "strap_on_alert?", "strap_removed?"].each do |name|
    define_method( name.to_sym) { event_type == name.chop.classify }
  end

  def icon(event_type = nil)
    # default = status_dial_up.png
    CONNECTIVITY_STATUS_ICONS.has_key?(event_type) ? CONNECTIVITY_STATUS_ICONS[event_type] : 'status_dial_up.png'
  end

  def string(user)
    strings = {'Fall' => 'Fell'}
    
    # "#{user.profile.first_name} #{strings[self.event_type]}"
    "#{user.profile.first_name}: #{self.event_type}"
  end
  
  def notes_string
    string = "Event Notes\n"
    notes.each do |note|
      string += UtilityHelper.format_datetime(note.created_at, user) + " by " + note.creator.name() + "\n" +
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
  
  def test_alarm?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'test_alarm'
    end
    
    return false
  end  

  def false_alarm?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'false_alarm'
    end
    
    return false
  end
  
  def real_alarm?
  	EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
  		return action if action.description == 'real_alarm'
  	end
  	
  	return false
  end
  
  def gw_reset?
  	EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
  		return action if action.description == 'gw_reset'
  	end
  	
  	return false
  end

  def ems?
  	EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
  		return action if action.description == 'ems'
  	end
  	
  	return false
  end
  
  def non_emerg_panic?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'non_emerg_panic'
    end
    
    return false
  end
  
  def duplicate?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'duplicate'
    end
    
    return false
  end
  
  def unclassified?
  	if self.test_alarm? or self.real_alarm? or self.false_alarm? or self.gw_reset? or self.non_emerg_panic? or self.duplicate?
      return false
  	end
  	return true
  end
  
end
