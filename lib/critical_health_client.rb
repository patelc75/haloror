require 'socket'
require 'timeout'

class CriticalHealthClient

  CRITICALHEALTH_ADDRESS = "62.28.143.10"
  CRITICALHEALTH_EVENT_PORT = 50000
  CRITICALHEALTH_COMMAND_PORT = 50001

  def self.alert(user, event_type,timestamp)
  	time_format = timestamp.strftime("%Y-%m-%d|%H:%M:%S")
    Timeout::timeout(2) {
      sock = TCPSocket.open(CRITICALHEALTH_ADDRESS, CRITICALHEALTH_COMMAND_PORT)
      sock.write("event,%s,%s,%s\r\n" % [event_type, time_format, user ])
      
      RAILS_DEFAULT_LOGGER.info("event,%s,%s,%s\r\n" % [event_type, time_format, user ])
      RAILS_DEFAULT_LOGGER.info("user_id: "+ user.to_s)
      RAILS_DEFAULT_LOGGER.info("event type: "+ event_type)

      response = sock.readline
      sock.close
    }
  end

  def self.event_type_string(klass)
    # FIXME: TODO: fill out these event types properly
    case klass
      when "Fall" then "FALL"
      when "Panic" then "PANIC"
      when "GwAlarmButton" then "GwAlarmButton"
      #when "CallCenterFollowUp" then "004"
      when "BatteryReminder" then "BatteryReminder"
  	  when "StrapOff" then "StrapOff"
  	  when "GatewayOfflineAlert" then "GatewayOfflineAlert"
  	  when "DeviceUnavailableAlert" then "DeviceUnavailableAlert"	
      else "000"
  	end
  end
end