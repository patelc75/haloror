class GwAlarmButton < CriticalDeviceAlert
  set_table_name "gw_alarm_buttons"

  def to_s
  	"Gateway RESET button has been pushed for #{user.name} on #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def email_body
    "We have detected that the Gateway RESET button has been pushed for #{user.name} on #{UtilityHelper.format_datetime(timestamp, user)}\n\n" +
      "Sincerely, Halo Staff"
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
