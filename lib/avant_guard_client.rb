require 'socket'
require 'timeout'
require 'savon'

class AvantGuardClient
  IP_ADDRESS = "12.29.157.39"
  TCP_PORT = 1025
  TCP_PORT_HEARTBEAT = 1025

  # Test manually with:
  # ruby bin/safetycare_test_listener.rb &
  # script/runner 'SafetyCareClient.alert("0123", "001")'
  # script/runner 'SafetyCareClient.heartbeat()'
  # (ideally, the heartbeat should run from the task scheduler, of course)

  def self.heartbeat
    RAILS_DEFAULT_LOGGER.warn("AvantGuardClient.heartbeat running at #{Time.now}")
    #Avantguard does not support heartbeat since they have geographically redundant servers
  end

  def self.alert(event_type, user_id, account_num, timestamp = Time.now)
    #Savon::Request.log = false
    msg = nil
    alarm_code = event_type_numeric( event_type)
    if !account_num.blank?
      Savon.configure do |config|
        config.soap_version = 2  # use SOAP 1.2
      end

      client = Savon::Client.new do
        wsdl.document = "https://portal.agmonitoring.com/testSgsSignalService/Receiver.asmx?WSDL"
        wsdl.endpoint = "https://portal.agmonitoring.com/testsgssignalservice/receiver.asmx"
        wsdl.namespace = "http://tempuri.org"
      end

      # client.http.headers["SOAPAction"] = '"Signal"'

      response = client.request :soap, "signal" do # |soap|
        #soap.header["API-KEY"] = "foobar"
        #soap.input = "DoSimpleRequest"
        #soap.action = "Signal"
        #body = Hash.new
        #body["wsdl:uniqueId"] = 12345
        soap.body = {
          "UserName"     => "Chirag.Patel",
          "UserPassword" => "cpHalo32",
          "Account"      => "#{account_num}",
          "SignalFormat" => "CID",
          "SignalCode"   => "#{event_type_numeric(event_type)}",
          #Looks like the preferred date formats include 'MM/dd/yyyy hh:mm:ss' (when the region of the account is US) 
          #and 'yyyy-MM-dd hh:mm:ss' (which is my preferred format as there is no ambiguity).
          "Date"         => "#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}"       
        }

        msg = soap
      end
      # RAILS_DEFAULT_LOGGER.warn("AvantGuard::client    = " + "%s\r\n"% [client.to_yaml])
      RAILS_DEFAULT_LOGGER.warn("AvantGuard::soap.body = " + "%s\r\n"% [msg.body.to_yaml])
      RAILS_DEFAULT_LOGGER.warn("AvantGuard::response  = " + "%s\r\n"% [response.to_yaml])

      return true
    else
      UtilityHelper.log_message_critical("CmsClient.alert::Missing account number! for user_id = #{user_id}")
      return false
    end
  end

  def self.event_type_numeric(event_type)
    # FIXME: TODO: fill out these event types properly
    case event_type
    when "Fall"                   then "E100"
    when "Panic"                  then "E15002002"
    when "GwAlarmButton"          then "R15001001"
      #when "CallCenterFollowUp" then "004"
    when "BatteryReminder"        then "100"
    when "StrapOff"               then "101"
    when "GatewayOfflineAlert"    then "102"
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