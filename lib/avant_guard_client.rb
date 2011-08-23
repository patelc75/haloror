require 'socket'
require 'timeout'
#require 'savon'   
require 'net/https'  
require 'uri'

class AvantGuardClient
  IP_ADDRESS = "12.29.157.39"
  IP_ADDRESS2 = "12.29.157.39"
  TCP_PORT = 1025
  TCP_PORT_HEARTBEAT = 1025
  HTTP_URL   =  "http://portal.agmonitoring.com/testSgsSignalService/Receiver.asmx"
  HTTPS_URL  =  "https://portal.agmonitoring.com/testsgssignalservice/receiver.asmx"  
  HTTPS_URL2 =  "https://portal.agmonitoring.com/testsgssignalservice/receiver.asmx"  
  # Test manually with:
  # ruby bin/safetycare_test_listener.rb &
  # script/runner 'SafetyCareClient.alert("0123", "001")'
  # script/runner 'SafetyCareClient.heartbeat()'
  # (ideally, the heartbeat should run from the task scheduler, of course)

  def self.heartbeat
    RAILS_DEFAULT_LOGGER.warn("AvantGuardClient.heartbeat running at #{Time.now}")
    #Avantguard does not support heartbeat since they have geographically redundant servers
  end

  #This method is used to test the Avantguard web service. It can be called as a standalone from script/console like this:
  # resp = AvantGuardClient.alert_test()
  def self.alert_test()                                              

    url = URI.parse(HTTPS_URL)    
    
    # Code snippet on how to use Net:HTTP: http://snippets.aktagon.com/snippets/305-Example-of-how-to-use-Ruby-s-NET-HTTP 
    http_endpoint = Net::HTTP.new(url.host, url.port)

    if url.scheme == 'https'
      http_endpoint.use_ssl = true      
      http_endpoint.verify_mode = OpenSSL::SSL::VERIFY_NONE 

      #verify the certificate -- not working with Avantguard, getting "OpenSSL::SSL::SSLError: certificate verify failed"
      #http_endpoint.verify_mode = OpenSSL::SSL::VERIFY_PEER 
    end
        
    content = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"><soap:Body><Signal xmlns=\"http://tempuri.org/\"><PollMessageFlag>false</PollMessageFlag><UserName>Chirag.Patel</UserName><UserPassword>cpHalo32</UserPassword><Receiver>string</Receiver><Line>string</Line><Account>G27500</Account><SignalFormat>CID</SignalFormat><SignalCode>E100</SignalCode>><TestSignalFlag>false</TestSignalFlag></Signal></soap:Body></soap:Envelope>"
    #Configuration.instance.logger.debug content
    #http_header = {'Content-Type' => 'text/xml'}
     
    request = Net::HTTP::Post.new(url.request_uri)
    #request.set_form_data({'data' => content})  #this doesn't work
    request.body = content
    
    #Tried using Savon but didn't work. Got the invalid soap action error
    #soap = AvantGuardClient.alert_savon("Fall", 1, "HM1234")   
    #request.body = soap.to_xml

    request.set_content_type("text/xml") 
    res = http_endpoint.start {|http| http_endpoint.request(request) }
    return res
    #another method of doing ita    
    #request = Net::HTTP::Get.new(url.request_uri)
    #response = http_endpoint.request(request)
    #response.body
    #response.status
    #response["header-here"] # All headers are lowercase 
    
    #yet another method of doing it
    #Net::HTTP.start('http://www.google.com') do |http|
    #  response = http.get('/')
    #  puts response
    #end

  end 

  def self.send(dest_url, content)
    url = URI.parse(dest_url)        
    # Code snippet on how to use Net:HTTP: http://snippets.aktagon.com/snippets/305-Example-of-how-to-use-Ruby-s-NET-HTTP 
    http_endpoint = Net::HTTP.new(url.host, url.port)

    if url.scheme == 'https'
      http_endpoint.use_ssl = true      
      http_endpoint.verify_mode = OpenSSL::SSL::VERIFY_NONE 
      #http_endpoint.verify_mode = OpenSSL::SSL::VERIFY_PEER   #verify the certificate -- not working with Avantguard, getting "OpenSSL::SSL::SSLError: certificate verify failed"          
    end        

    request = Net::HTTP::Post.new(url.request_uri)
    request.body = content
    request.set_content_type("text/xml") 
    res = http_endpoint.start do |http|
      http_endpoint.request(request) 
    end                            
    return res
  end
         
  def self.update_account(profile)
    content = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"><soap:Body><Signal xmlns=\"http://tempuri.org/\"><PollMessageFlag>false</PollMessageFlag><UserName>Chirag.Patel</UserName><UserPassword>cpHalo32</UserPassword><Receiver>string</Receiver><Line>string</Line><Account>#{account_num}</Account><SignalFormat>CID</SignalFormat><SignalCode>#{alarm_code}</SignalCode>><TestSignalFlag>false</TestSignalFlag></Signal></soap:Body></soap:Envelope>"

    res = send(HTTPS_URL, content)
  end
  
  #Usage: AvantGuardClient.alert("Fall", 1, "G27500")
  def self.alert(event_type, user_id, account_num, timestamp = Time.now, lat=nil, long=nil)
    alarm_code = event_type_numeric( event_type)
    
    content = "<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\"><soap:Body><Signal xmlns=\"http://tempuri.org/\"><PollMessageFlag>false</PollMessageFlag><UserName>Chirag.Patel</UserName><UserPassword>cpHalo32</UserPassword><Receiver>string</Receiver><Line>string</Line><Account>#{account_num}</Account><SignalFormat>CID</SignalFormat><SignalCode>#{alarm_code}</SignalCode>><TestSignalFlag>false</TestSignalFlag></Signal></soap:Body></soap:Envelope>"
    response = true

    if !account_num.blank?    
      [HTTPS_URL, HTTPS_URL2].each do |dest_url| 
        http_response = send(dest_url, content)           
        if (http_response.nil? or http_response.code != "200") 
          UtilityHelper.log_message_critical("AvantGuard.alert::Exception:: #{e} : #{event.to_s}", e)          
          response = false
        end
      end
    end       
    return response
  end
    
  def self.alert_savon(event_type, user_id, account_num, timestamp = Time.now, lat=nil, long=nil)
    #Savon::Request.log = false
    msg = nil
    alarm_code = event_type_numeric( event_type)
    if !account_num.blank?
      Savon.configure do |config|
        config.soap_version = 1  # use SOAP 1.2
      end

      client = Savon::Client.new do
        wsdl.document  = "https://portal.agmonitoring.com/testSgsSignalService/Receiver.asmx?WSDL"
        wsdl.endpoint  = "https://portal.agmonitoring.com/testsgssignalservice/receiver.asmx"
        wsdl.namespace = "https://tempuri.org"
      end

      # client.http.headers["SOAPAction"] = '"Signal"'

      # response = client.request( "signal", "xmlns" => "http://tempuri.org") do # |soap|
      #soap.header["API-KEY"] = "foobar"
      #soap.input = "DoSimpleRequest"
      #soap.action = "Signal"
      #body = Hash.new
      #body["wsdl:uniqueId"] = 12345
      response = client.request :signal do
        # soap.xml can be use to send custom XML. This XML matches the .NET utility output used by AvantGuard. See https://redmine.corp.halomonitor.com/issues/4461#note-4
        # soap.xml = %{<?xml version="1.0" encoding="utf-8"?>
        # <SOAP-ENV:Envelope
        #   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        #   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        #   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
        #   SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
        #   xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
        #   <SOAP-ENV:Body>
        #     <Signal xmlns="http://tempuri.org/">
        #       <UserName xsi:type="xsd:string">Chirag.Patel</UserName>
        #       <UserPassword xsi:type="xsd:string">cpHalo32</UserPassword>
        #       <Account xsi:type="xsd:string">#{account_num}</Account>
        #       <SignalFormat xsi:type="xsd:string">CID</SignalFormat>
        #       <SignalCode xsi:type="xsd:string">#{event_type_numeric(event_type)}</SignalCode>
        #       <Date xsi:type="xsd:dateTime">#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}</Date>
        #       <Longitude xsi:type="xsd:decimal">#{long || ''}</Longitude>
        #       <Latitude xsi:type="xsd:decimal">#{lat || ''}</Latitude>
        #     </Signal>
        #   </SOAP-ENV:Body>
        # </SOAP-ENV:Envelope>}

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
        soap.body["Latitude"]  = "#{lat}"  if !lat.nil?
        soap.body["Longitude"] = "#{long}" if !long.nil?
        
        msg = soap   
      end
      #RAILS_DEFAULT_LOGGER.warn("AvantGuard::client    = " + "%s\r\n"% [client.to_yaml])
      #RAILS_DEFAULT_LOGGER.warn("AvantGuard::soap.body = " + "%s\r\n"% [msg.body.to_yaml])
      #RAILS_DEFAULT_LOGGER.warn("AvantGuard::response  = " + "%s\r\n"% [response.to_yaml])

      return msg
    else
      UtilityHelper.log_message_critical("CmsClient.alert::Missing account number! for user_id = #{user_id}")
      return nil
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
