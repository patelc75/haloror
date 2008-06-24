require File.dirname(__FILE__) + '/../helper'
require 'digest'

steps_for(:battery_plugged) do 
  	Given("a '$device'") do |device|
  	  puts ''
  	  puts  "device id?:  "
	    @device_id = gets
	    @device_id.strip!
	  end
    
	  When("I issue a '$command'") do |command|
	    if(command == "battery plugged command")
	      puts ''

	      puts  "user id?:  "
	      @user_id = gets
	      @user_id.strip!

	      puts "battery percentage?:  "
	      @percentage = gets 
	      @percentage.strip!

	      puts  "time remaining?:  "
	      @time_remaining = gets
	      @time_remaining.strip!

	      puts  "time stamp?:  "
	      @timestamp = gets
	      @timestamp.strip!

	      puts "gateway id?:  "
	      @gateway_id = gets
        @gateway_id.strip!

	      @serial_number = Device.find_by_id(@gateway_id).serial_number
	      @serial_number.strip!
	      s = "#{@timestamp}#{@serial_number}"
	      @auth = Digest::SHA256.hexdigest(s)
	      curl_cmd = "curl -v -H \"Content-Type: text/xml\" -d \"<battery_plugged><device_id>#{@device_id}</device_id><percentage>#{@percentage}</percentage><timestamp>#{@timestamp}</timestamp><time_remaining>#{@time_remaining}</time_remaining><user_id>#{@user_id}</user_id></battery_plugged>\" \"http://localhost:3000/battery_pluggeds?gateway_id=#{@gateway_id}&auth=#{@auth}\""
	      
	      puts curl_cmd
	      `#{curl_cmd}`
      end
    end
    
    Then("the user should verify 'battery plugged icon") do |battery|
      
    end
end

with_steps_for(:battery_plugged) do 
  run_local_story "battery_plugged_story", :type => RailsStory
end