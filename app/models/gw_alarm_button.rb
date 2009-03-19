class GwAlarmButton < DeviceAlert
  set_table_name "gw_alarm_buttons"

  def priority
    return IMMEDIATE
  end
  
  def to_s
    "Gateway Alarm Reset button pressed on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def after_save
    deferred = CallCenterDeferred.find(:all, :conditions => "user_id = #{user_id} AND pending = true")
    if deferred && deferred.size > 0
      deferred.each do |d|
        d.pending = false
        d.save!
        resolve_event(d.event)
      end
    end
  end
  
  def resolve_event(evt)
      follows = CallCenterFollowUp.find(:all, :conditions => "event_id = #{evt.id}")
      if follows
        follows.each do |f|
          e = Event.find(:first, :conditions => "event_id = #{f.id} AND event_type = 'CallCenterFollowUp'")
          if e
            unless e.resolved?
              action = EventAction.new
              action.user_id = user_id
              action.event_id = e.id
              action.description = 'resolved'
              action.save!
            end
          end
        end
      end
  end
  
  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
