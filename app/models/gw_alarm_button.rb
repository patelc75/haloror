class GwAlarmButton < CriticalDeviceAlert
  set_table_name "gw_alarm_buttons"
  belongs_to :user
  belongs_to :device

  def to_s
  	"Alarm cleared for #{user.name} on #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def to_s_short
   "CLEAR #{user.name}" 
  end
  
  def email_body
    "Hello,\n\nWe have detected that the alarm has been cleared (Gateway RESET button has been pushed) for #{user.name} on #{UtilityHelper.format_datetime(timestamp, user)}\n\n" +
      "- Halo Staff"
  end

=begin  
  def after_save
    #removed since we're not using the call center wizard
    #deferred = CallCenterDeferred.find(:all, :conditions => "user_id = #{user_id} AND pending = true")
    #if deferred && deferred.size > 0
    #  deferred.each do |d|
    #    d.pending = false
    #    d.save!
    #   resolve_event(d.event)
    #  end
    #end

    gw_timeout = GwAlarmButtonTimeout.find(:all, :conditions => "user_id = #{user_id} AND pending = true")
    if gw_timeout && gw_timeout.size > 0
      gw_timeout.each do |g|
        g.pending = false
        g.save!
      end
    end    
  end
=end
  
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
end
