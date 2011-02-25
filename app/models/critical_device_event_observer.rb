class CriticalDeviceEventObserver  < ActiveRecord::Observer
    include ServerInstance
    include UtilityHelper
    observe Fall, Panic, GwAlarmButton, CallCenterFollowUp

    # 
    #  Sat Feb 26 01:42:35 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4223
    def before_save( event)
      #   * remember the changes made to this model
      @_changes = event.changes
    end

    # https://redmine.corp.halomonitor.com/issues/3076
    # this ws before_save but it caused the data loss due to reload of record
    def after_save(event)
      # 
      #  Fri Feb  4 21:56:28 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/4147
      #   * we need to call this code from outside this observer
      #   * observer can only have a predefined set of methods
      #   * we need to keep this code in a public method in a module and call it from where exception happens
      #   option 2
      #   * put this entire code in before_save (does not serve the purpose)
      #
      #   NOT TOUCHED THE CODE YET for #4147
      #
      if UtilityHelper.validate_event_user(event) == true #only validating user because GW does not use the device_id
        if event.user.profile         
          if event.call_center_pending == false
            DeviceAlert.notify_call_center_and_partners(event)
            #refs #3958 comment/uncomment due to Email delay from ATL-WEB1 on 4 hour slots on critical alerts
            #if(ServerInstance.current_host_short_string() != "ATL-WEB1" and ServerInstance.current_host_short_string() != "CRIT2")              
            DeviceAlert.notify_operators(event)
            #end    
          end
          # 
          #  Sat Feb 26 01:29:40 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4223
          # if ( ServerInstance.current_host_short_string() != "ATL-WEB1" && ServerInstance.current_host_short_string() != "CRIT2" )
          #   * server host string checking is shortened for better maintenance and readability
          #   * notify caregivers irrespective of call_center_pending flag
          #   * do not notify if the last thing changed was call_center_pending flag
          DeviceAlert.notify_caregivers(event) unless ( ServerInstance.host?( "ATL-WEB1", "CRIT2") || @_changes.keys.include?( "call_center_pending") )
          # end
        else
          CriticalMailer.deliver_monitoring_failure("Missing user profile!", event)
          UtilityHelper.log_message_critical("Missing user profile!")
          event.timestamp_call_center = nil
          # write this but do not trigger recursive callback
          # we are in after_save
          event.send(:update_without_callbacks)
        end
      end
      #
      # ramonrails: Thu Oct 14 01:55:31 IST 2010
      # CHANGED: rails 2.1.0 is fires after_save for Panic.after_save also
      #   No need to explicitly make a call here
      # event.after_save if event.class == Panic # run more after_save actions for panic
      #
      # ramonrails: Thu Oct 14 02:05:58 IST 2010
      #   return TRUE to continue executing further callbacks
      true
    end
    
# https://redmine.corp.halomonitor.com/issues/3076
#   This callback method was commented out anyways
#   Please see after_save aboev
#
#     def after_save(event)
# =begin      
#       if alert.class == Fall or alert.class == Panic
#         gw_timeout = GwAlarmButtonTimeout.create(:pending => true, 
#                                                 :device_id => alert.device_id, 
#                                                 :user_id => alert.user_id,
#                                                 :event_id => alert.id,
#                                                 :event_type => alert.class.class_name,
#                                                 :timestamp => Time.now)
#         spawn do
#           sleep(GW_RESET_BUTTON_FOLLOW_UP_TIMEOUT) 
#           #RAILS_DEFAULT_LOGGER.warn("spawn Checking CallCenterDeferred: #{deferred.id}")
#           gw_timeout = GwAlarmButtonTimeout.find(gw_timeout.id)
#           if gw_timeout && gw_timeout.pending
#             gw_timeout.update_attributes(:timestamp => Time.now)
#             CriticalMailer.deliver_gw_alarm(gw_timeout)
#             Event.create_event(gw_timeout.user_id, GwAlarmButtonTimeout.class_name, gw_timeout.id, gw_timeout.timestamp)
#           end
#         end
#       end
# =end       
#     end
end