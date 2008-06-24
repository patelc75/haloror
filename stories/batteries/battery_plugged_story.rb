require File.dirname(__FILE__) + '/../helper'
require 'digest'

steps_for(:battery_plugged) do 
  	Given("a '$device_id', '$user_id', '$percentage', '$time_remaining', and a '$gateway_id'") do |device_id, 
  	                                                                                                user_id, 
  	                                                                                                percentage, 
  	                                                                                                time_remaining, 
  	                                                                                                gateway_id|
  	  if device_id == 'device id'
  	    puts ''
  	    puts  "device id?:  "
	      @device_id = gets
      else
        @device_id = device_id
      end
	    @device_id.strip!
	    if user_id == 'user id'
  	    puts ''
  	    puts  "user id?:  "
	      @user_id = gets
	    else
	      @user_id = user_id
	    end
      @user_id.strip!
      if percentage == 'battery percentage'
  	    puts ''
  	    puts  "battery percentage?:  "
	      @percentage = gets
	      @percentage.strip!
      else
        @percentage = percentage
      end  
	    @percentage.strip!
	    if time_remaining == "time remaining"
  	    puts ''
  	    puts  "time remaining?:  "
	      @time_remaining = gets
	    else
	      @time_remaining = time_remaining
	    end
	    @time_remaining.strip!
	    if gateway_id == 'gateway id'
  	    puts ''
  	    puts  "gateway id?:  "
	      @gateway_id = gets
      else
        @gateway_id = gateway_id
      end
	    @gateway_id.strip!
	  end
	  
	  When("I issue a '$command'") do |command|
	    if(command == "battery plugged command")
	      @timestamp = Time.now.strftime("%a %b %d %H:%M:%S -0600 %Y")
	      @serial_number = Device.find_by_id(@gateway_id).serial_number
	      @serial_number.strip!
	      s = "#{@timestamp}#{@serial_number}"
	      @auth = Digest::SHA256.hexdigest(s)
	      curl_cmd = "curl -v -H \"Content-Type: text/xml\" -d \"<battery_plugged><device_id>#{@device_id}</device_id><percentage>#{@percentage}</percentage><timestamp>#{@timestamp}</timestamp><time_remaining>#{@time_remaining}</time_remaining><user_id>#{@user_id}</user_id></battery_plugged>\" \"http://localhost:3000/battery_pluggeds?gateway_id=#{@gateway_id}&auth=#{@auth}\""
	      
	      puts curl_cmd
	      `#{curl_cmd}`
      end
    end
    
    Then("the user should verify '$battery'") do |battery|
      puts ''
      puts "Does the #{battery} display?"
      result = gets
      result.strip!
      result.upcase.should == 'YES'
    end
end

with_steps_for(:battery_plugged) do 
  run_local_story "battery_plugged_story", :type => RailsStory
end