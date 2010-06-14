require 'socket'
require 'timeout'

class CmsClient
  IP_ADDRESS = "12.29.157.39"
  TCP_PORT = 1025
  TCP_PORT_HEARTBEAT = 1025
  
  # Test manually with:
  # ruby bin/safetycare_test_listener.rb &
  # script/runner 'SafetyCareClient.alert("0123", "001")'
  # script/runner 'SafetyCareClient.heartbeat()' 
  # (ideally, the heartbeat should run from the task scheduler, of course)
  
  def self.heartbeat
  	RAILS_DEFAULT_LOGGER.warn("CmsClient.heartbeat running at #{Time.now}")  	
    # Timeout::timeout(5) {
    #   sock = TCPSocket.open(IP_ADDRESS, TCP_PORT_HEARTBEAT)
    #   
    #   # 64.chr => "@", 13.chr => "\r" (CR), 10.chr => "\r" (LF)   
    #   #sock.write(64.chr+' '+13.chr) 
    #   #sock.write(64.chr+20.chr)
    #   #sock.write(64.chr+' '+10.chr)      
    #   sock.write(64.chr+' '+20.chr+10.chr) #this was tested with larry foley on the phone     
    #   sock.close
    # }
    # https://redmine.corp.halomonitor.com/issues/2951
    self.heartbeat_open_socket # open the docket if not already
    RAILS_DEFAULT_LOGGER.warn("Unable to open socket for connecting to CmsClient") # log warning if cannot open socket
    Timeout::timeout(5) { @heartbeat_socket.write(64.chr+' '+20.chr+10.chr) if @heartbeat_socket } # write if socket available
  end
  
  def self.alert(event_type,user_id,account_num,timestamp=Time.now)      
    alarm_code = event_type_numeric(event_type)
    if !account_num.blank?
      #don't need to filter because safetycare filters by IP
      #if ServerInstance.in_hostname?('dfw-web1') or ServerInstance.in_hostname?('dfw-web2') or ServerInstance.in_hostname?('atl-web1')
      Timeout::timeout(2) {
        sock = TCPSocket.open(IP_ADDRESS, TCP_PORT)
        sock.write("501001 18%s%s " % [account_num, alarm_code]+20.chr+10.chr) #1234 => account number
        #sock.write("%s%s\r\n" % [account_num, alarm_code])
        response = sock.readline
        sock.close
      }
      RAILS_DEFAULT_LOGGER.warn("CmsClient::alert = " + "%s%s\r\n" % [account_num, alarm_code])
      return true
    else
      #raise CriticalAlertException, "SafetyCareClient.alert::Missing account number! for user_id = #{user_id}"
      UtilityHelper.log_message_critical("CmsClient.alert::Missing account number! for user_id = #{user_id}")
      return false
    end
  end

  def self.event_type_numeric(event_type)
    # FIXME: TODO: fill out these event types properly
    case event_type
      when "Fall" then "E15001001"
      when "Panic" then "E15002002"
      when "GwAlarmButton" then "R15001001"
      #when "CallCenterFollowUp" then "004"
      when "BatteryReminder" then "100"
  	  when "StrapOff" then "101"
  	  when "GatewayOfflineAlert" then "102"
  	  when "DeviceUnavailableAlert" then "103"	
      else "000"
  	end
  end

  private
  
  def self.heartbeat_open_socket
    Timeout::timeout(5) { @heartbeat_socket ||= TCPSocket.open(IP_ADDRESS, TCP_PORT_HEARTBEAT) }
    @heartbeat_socket
  end
  
end