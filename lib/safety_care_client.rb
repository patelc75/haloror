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
  
  def self.alert(account_number, alarm_code)
    Timeout::timeout(2) {
      sock = TCPSocket.open(SAFETYCARE_ADDRESS, SAFETYCARE_PORT)
      sock.write("%s%s\r\n" % [account_number, alarm_code])
      response = sock.readline
      sock.close
    }
  end
     
end