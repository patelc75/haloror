require 'socket'
require 'timeout'

class CriticalHealthClient

  CRITICALHEALTH_ADDRESS = "62.28.143.10"#Andre's machine
  #CRITICALHEALTH_ADDRESS = "89.214.140.7" #Andre's air card
  CRITICALHEALTH_EVENT_PORT = 8910
  CRITICALHEALTH_COMMAND_PORT = 50001

  def self.alert(event_type,user_id,account_num,timestamp=Time.now)
    event_type = event_type_string(event_type)
    time_format = timestamp.strftime("%Y-%m-%d|%H:%M:%S")
    RAILS_DEFAULT_LOGGER.warn("CriticalHealthClient::alert before sock.write = " +  "event, %s, %s, %s\r\n" % [event_type, time_format, user_id])

    Timeout::timeout(2) {
      sock = TCPSocket.open(CRITICALHEALTH_ADDRESS, CRITICALHEALTH_EVENT_PORT)
      sock.write("event,%s,%s,%s\n" % [event_type, time_format, user_id])
      
      response = sock.readline
      sock.close
    }

    RAILS_DEFAULT_LOGGER.warn("CriticalHealthClient::alert after sock.write = " +  "event, %s, %s, %s\r\n" % [event_type, time_format, user_id])
    return true
  end

  def self.event_type_string(klass)
    # FIXME: TODO: fill out these event types properly
    case klass
      when "Fall" then "FALL"
      when "Panic" then "BUTTON"
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