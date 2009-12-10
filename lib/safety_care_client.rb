require 'socket'
require 'timeout'

class SafetyCareClient
  # SafetyCare addresses
  # TODO: FIXME: change this when finished testing?
  SAFETYCARE_ADDRESS = "74.43.4.37"
  SAFETYCARE_PORT = 19925

  # For use with the bin/safetycare_test_listener.rb tester
  #SAFETYCARE_ADDRESS = "localhost"
  #SAFETYCARE_PORT = 2000
  
  # Test manually with:
  # ruby bin/safetycare_test_listener.rb &
  # script/runner 'SafetyCareClient.alert("0123", "001")'
  # script/runner 'SafetyCareClient.heartbeat()' 
  # (ideally, the heartbeat should run from the task scheduler, of course)
  
  def self.heartbeat()
  	RAILS_DEFAULT_LOGGER.warn("SafetyCareClient.heartbeat running at #{Time.now}")  	
    Timeout::timeout(5) {
      sock = TCPSocket.open(SAFETYCARE_ADDRESS, SAFETYCARE_PORT)
      sock.write(64.chr) # 64.chr => @
      sock.close
    }
  end
  
  def self.alert(event_type,user_id,account_num,timestamp=Time.now)
    alarm_code = event_type_numeric(event_type)
    
    if !account_num.blank?
      #don't need to filter because safetycare filters by IP
      #if ServerInstance.in_hostname?('dfw-web1') or ServerInstance.in_hostname?('dfw-web2') or ServerInstance.in_hostname?('atl-web1')
      Timeout::timeout(2) {
        sock = TCPSocket.open(SAFETYCARE_ADDRESS, SAFETYCARE_PORT)
        sock.write("%s%s\r\n" % [account_num, alarm_code])
        response = sock.readline
        sock.close
      }
      RAILS_DEFAULT_LOGGER.warn("SafetyCareClient::alert = " + "%s%s\r\n" % [account_num, alarm_code])
    else
      UtilityHelper.log_message("SafetyCareClient.alert::Missing account number!")   
    end
  end

  def self.event_type_numeric(event_type)
    # FIXME: TODO: fill out these event types properly
    case event_type
      when "Fall" then "001"
      when "Panic" then "002"
      when "GwAlarmButton" then "003"
      #when "CallCenterFollowUp" then "004"
      when "BatteryReminder" then "100"
  	  when "StrapOff" then "101"
  	  when "GatewayOfflineAlert" then "102"
  	  when "DeviceUnavailableAlert" then "103"	
      else "000"
  	end
  end
       
end