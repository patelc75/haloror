require 'time'
require "digest/sha2"
namespace :halo do  
  desc "railroad command to generate schema"
  task :railroad => :environment  do
    system('railroad -a -i -M | dot -Tpng > models.png')
  end
  
  def delete
    puts ""
    puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts "Deleting Vital, SkinTemp, Battery, and Step for all posts"
    puts "past #{Time.now.utc} for user_id=#{ENV['user_id']}"
    puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts ""
    Vital.delete_all(["timestamp > ? AND user_id = ?" , Time.now.utc, ENV['user_id']])
    SkinTemp.delete_all(["timestamp > ? AND user_id = ?" , Time.now.utc, ENV['user_id']])
    Battery.delete_all(["timestamp > ? AND user_id = ?" , Time.now.utc, ENV['user_id']])
    Step.delete_all(["begin_timestamp > ? AND user_id = ?" , Time.now.utc, ENV['user_id']])
  end
  
  def validatation
  	if ENV['user_id'] == nil
      puts ""
      puts "You forgot user_id"
      puts ""
      print_usage = true
    else
      puts "User ID: #{ENV['user_id']}"
    end
 
    if ENV['device_id'] == nil
      puts ""
      puts "You forgot device_id"
      puts ""
      print_usage = true
    else
      puts "Device ID: #{ENV['device_id']}"
    end
    
     if ENV['gateway_id'] == nil
      puts ""
      puts "You forgot gateway_id"
      puts ""
      print_usage = true
    else
      puts "Gateway ID: #{ENV['gateway_id']}"
    end
    
    start_time = Time.now.utc
  end
  
  desc "install user reg"  
  task :install_user_reg => :environment  do
      validatation
      start_time = Time.now.utc
    if ENV['method'] == "activerecord"
            skin_temp = MgmtCmd.new(:user_id => ENV['user_id'],:device_id => ENV['device_id'],:cmd_type => 'user_registration', :timestamp_initiated => start_time)
            skin_temp.save
	end
  end
  
  desc "install self test gw"  
  task :install_self_test_gw => :environment  do
       validatation
       start_time = Time.now.utc
    if ENV['method'] == "activerecord"
            set_test = SelfTestResult.new(:device_id => ENV['gateway_id'],:cmd_type => 'self_test',:result => 't', :timestamp => start_time)
            set_test.save
	end
  end
  
  desc "install self test phone"  
  task :install_self_test_phone => :environment  do
      validatation
      start_time = Time.now.utc
    if ENV['method'] == "activerecord"
            set_test_phone = SelfTestResult.new(:device_id => ENV['gateway_id'],:cmd_type => 'self_test_phone', :result => 'f', :timestamp => start_time)
            set_test_phone.save
	end
  end
  
  desc "install vital"  
  task :install_vital => :environment  do
	validatation
	start_time = Time.now.utc
    if ENV['method'] == "activerecord"
            future_vital = Vital.new(:user_id => ENV['user_id'],:heartrate => 75,:hrv => 2,:activity=>10000,:orientation => 90, :timestamp => start_time)
            future_vital.save
	end
  end
  
  
  
  desc "post random vitals data with either activerecord or curl"  
  task :post => :environment  do
    #end_time = Time.parse('2007-08-30 18:44:37-04') #hardcoded for demo 

    if ENV['vital'] == nil
      puts ""	
      puts "You forgot vital. vital = vitals, skin_temp, battery, or all"
      puts ""
      print_usage = true
    else
      puts "Vital: #{ENV['vital']}" 
    end

    if ENV['method'] == nil
      puts ""
      puts "You forgot method. method = curl or activerecord"
      puts ""
      print_usage = true
    else
      puts "Method: #{ENV['method']}" 
    end

    if ENV['duration'] == nil
      puts ""
      puts "You forgot duration. duration = length of time period in seconds, ending with the current time"
      puts ""	
      print_usage = true
    else
      puts "Duration: #{ENV['duration']} seconds"
    end

    if ENV['increment'] == nil
      puts ""
      puts "You forgot increment. increment = seconds between each timestamp"
      puts ""
      print_usage = true
    else
      puts "Increment: #{ENV['increment']} seconds"
    end

    if ENV['user_id'] == nil
      puts ""
      puts "You forgot user_id"
      puts ""
      print_usage = true
    else
      puts "User ID: #{ENV['user_id']}"
    end
	
    if ENV['frequency'] == nil
      puts ""
      puts "You forgot frequency. frequency = seconds between each post (frequency=0 means no delay)"
      puts ""
      print_usage = true
    else
      puts "Frequency: #{ENV['frequency']}"
    end
	
    if ENV['url'] == nil &&  ENV['method'] == "curl"
      puts ""
      puts "You forgot the url. Example: http://localhost:3000"
      puts ""
      print_usage = true
    else
      puts "URL: #{ENV['url']}\n"
    end

    if ENV['type'] == nil
      puts ""
      puts "You forgot the type. type = 'live' or 'historical' or 'future'"
      puts ""
      print_usage = true
    else
      puts "Type: #{ENV['type']}"
    end
    
    if ENV['curve'] == nil
      puts ""
      puts "You forgot the curve. curve = random  or sawooth"
      puts ""
      print_usage = true
    else
      puts "Slope: #{ENV['curve']}"
    end
    
    if ENV['swing'] == nil and ENV['curve'] == "sawtooth"
      puts ""
      puts "You forgot the swing. It is the width of sawtooth. Example: Swing=10 "
      puts ""
      print_usage = true
    else
      puts "Swing: #{ENV['swing']}"
    end
	
    if ENV['slope'] == nil and ENV['curve'] == "sawtooth"
      puts ""
      puts "You forgot the slope. It is the increment number. Example: Slope=5 "
      puts ""
      print_usage = true
    else
      puts "Slope: #{ENV['slope']}"
    end
  
    if ENV['gateway_id'] == nil 
       puts ""
      puts "You forgot the gateway_id."
      puts ""
      print_usage = true
    else
      puts "gateway id: #{ENV['gateway_id']}"
      
    end
    
    if ENV['gateway_serial_num'] == nil 
       puts ""
      puts "You forgot the Gateway serial number."
      puts ""
      print_usage = true
    else
      puts "gateway serial number: #{ENV['gateway_serial_num']}"
      
    end
  
      
    if print_usage == true
      puts ""
      puts "Example Usage with curl: "
      #puts "rake halo:post vital=all method=curl url=http://localhost:3000 increment=15 duration=5000 user_id=333 frequency=5 type=historical"	
      
      #puts "rake halo:post vital=all  method=curl url=http://localhost:3000 increment=15 duration=5000 user_id=60 frequency=5 type=historical move=up swing=10 slope=10
      #"
      
      puts "rake halo:post vital=all  method=curl url=http://localhost:3000 increment=15 duration=5000 user_id=60 frequency=5 type=historical swing=10 slope=10 curve=random"
      
      puts ""
      puts "Example Usage with activerecord (for same server): "
      puts "rake halo:post vital=all method=activerecord url=http://localhost:3000 increment=15 duration=5000 user_id=333 frequency=5 type=live"	
      puts ""
    else
      if(ENV['type'] == "live" or ENV['type'] == "future" ) 
       if ENV['end_date'] != nil
        start_time = Time.now.utc
         end_time = ENV['end_date'].to_time
       elsif
        delete
        start_time = Time.now.utc
        end_time = start_time + ENV['duration'].to_i  
       end
        
      elsif (ENV['type'] == "historical")
        if ENV['start_date'] != nil
           end_time = Time.now.utc
           start_time = ENV['start_date'].to_time
        elsif
           end_time = Time.now.utc
           start_time = end_time - ENV['duration'].to_i
        end
        
     elsif (ENV['type'] == "range")
        
        if (ENV['end_date'] != nil and ENV['start_date'] != nil)
        end_time = ENV['end_date'].to_time
        start_time = ENV['start_date'].to_time
        elsif (ENV['end_date'] == nil and ENV['start_date'] != nil)
          start_time = ENV['start_date'].to_time
          end_time = start_time + ENV['duration'].to_i
          elsif (ENV['start_date'] == nil and ENV['end_date'] != nil )
            end_time = ENV['end_date'].to_time
            start_time = end_time - ENV['duration'].to_i
           elsif (ENV['start_date'] == nil and ENV['end_date'] == nil)
           puts " You have to enter either Start date or End date if you want to choose the range option"
         end
       
      end
		
      puts "Start time: #{start_time}" 
      puts "End time: #{end_time}"
      puts 
       #remoed it .new
      randhr = rand(10) + 60
      #randhr = rand(100) + 500
      hr = randhr
      direction = "up" 
      count = 0
      until start_time > end_time     
        if(ENV['type'] == "live")
          start_time = Time.now.utc
        else  
          start_time = start_time + ENV['increment'].to_i #send a REST posts with the timestamp incremented by 15 seconds
        end
        calculathash = Digest::SHA256.hexdigest(start_time.to_s+ENV['gateway_serial_num'])
        #calculathash = Digest::SHA256.hexdigest(start_time.to_s+"0123456789")
     
     
                
         if hr == (randhr + ENV['swing'].to_i)
          direction = "down"
        elsif hr == (randhr - ENV['swing'].to_i)
          direction = "up"
        end  
       
    
        if (direction == "up")           
          hr += ENV['slope'].to_i
        elsif (direction == "down")         
          hr -= ENV['slope'].to_i
        end  

       
        if ENV['curve'] == "sawtooth"
          if(count % 15 == 0 || count % 16 == 0 || count % 17 == 0)
            random_heartrate = -1
            random_skin_temp = -1
            random_percentage = -1
            random_steps = -1
            random_activity = -1
          else
            random_heartrate = hr
            random_skin_temp = hr + 30
            random_percentage = hr + 30
            random_steps = hr - 50
            random_activity = hr + 10000
          end 
          #new
          
        elsif ENV['curve'] == "random"
          if(count % 15 == 0 || count % 16 == 0 || count % 17 == 0)
            random_heartrate = -1
            random_skin_temp = -1
            random_percentage = -1
            random_steps = -1
            random_activity = -1
          else
            random_skin_temp = (rand() + rand(6) + 95.6).round(1)
            random_heartrate = rand(7)+70
            random_percentage = rand(100)
            random_steps = rand(20)
            #new
            random_activity = rand(25000)+10000
          end
          count = count + 1
        end           
     
        if ENV['vital'] == "skin_temp" || ENV['vital'] == "all"
          print "user_id #{ENV['user_id']} | "
          print "#{start_time}| skin temp #{random_skin_temp} | "  
          if ENV['method'] == "activerecord"
            skin_temp = SkinTemp.new(:user_id => ENV['user_id'], :timestamp => start_time, :skin_temp => random_skin_temp)
            skin_temp.save
          elsif ENV['method'] == "curl"
            skin_temp_xml = "<skin_temp><skin_temp>#{random_skin_temp}</skin_temp><timestamp>#{start_time}</timestamp><user_id>#{ENV['user_id']}</user_id></skin_temp>"
            #curl_cmd ='curl -H "Content-Type: text/xml" -d "' + skin_temp_xml + '" ' +'"' + ENV['url'] + "/skin_temps?gateway_id=30&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a'+'" '   
            
           # curl_cmd ='curl -v -H "Content-Type: text/xml" -d "' + skin_temp_xml + '" ' +'"' + 'http://localhost:3000/skin_temps?gateway_id=30&auth='+ "#{calculathash}"+'" ' 
           curl_cmd ='curl -v -H "Content-Type: text/xml" -d "' + skin_temp_xml + '" ' +'"' + ENV['url'] + '/skin_temps?gateway_id=' + "#{ENV['gateway_id']}" '&auth=' + "#{calculathash}"+'" ' 
            puts curl_cmd
            system(curl_cmd)    				         
          end
        end
      
      
        if ENV['vital'] == "vitals" || ENV['vital'] == "all"
          random_orientation = rand(90)
          random_hrv = rand(5)          
          #new removed
          # random_activity = rand(25000)+10000      

          print "orientation #{random_orientation} | hr #{random_heartrate} | hrv #{random_hrv} | activity #{random_activity} | "  
          if ENV['method'] == "activerecord"          
            vitals = Vital.new(:user_id => ENV['user_id'], :timestamp => start_time, :orientation => random_orientation, :heartrate => random_heartrate, :hrv => random_hrv, :activity => random_activity)
            vitals.save
          elsif ENV['method'] == "curl"

            vital_xml="<vital><activity>#{random_activity}</activity><heartrate>#{random_heartrate}</heartrate><hrv>#{random_hrv}</hrv><orientation>#{random_orientation}</orientation><timestamp>#{start_time}</timestamp><user_id>#{ENV['user_id']}</user_id></vital>"
           # curl_cmd ='curl -H "Content-Type: text/xml" -d "' + vital_xml + '" '  +'"'  + ENV['url'] + '/vitals?gateway_id='+ "#{ENV['gateway_id']}&auth='+ "#{calculathash}"+'" ' 
           curl_cmd ='curl -H "Content-Type: text/xml" -d "' + vital_xml + '" '  +'"'  + ENV['url'] + '/vitals?gateway_id=' + "#{ENV['gateway_id']}" '&auth=' + "#{calculathash}"+'" ' 

            puts curl_cmd
            system(curl_cmd)    				
          end		
        end
        
        if ENV['vital'] == "battery" || ENV['vital'] == "all"
          print "battery #{random_percentage} | "  
          if ENV['method'] == "activerecord"
            battery = Battery.new(:user_id => ENV['user_id'], :timestamp => start_time, :percentage => random_percentage, :time_remaining => 0)
            battery.save
          elsif ENV['method'] == "curl"
            battery_xml = "<battery><percentage>#{random_percentage}</percentage><time_remaining>0</time_remaining><user_id>#{ENV['user_id']}</user_id><timestamp>#{start_time}</timestamp></battery>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + battery_xml + '" ' +'"' + ENV['url'] + '/batteries?gateway_id=' + "#{ENV['gateway_id']}" '&auth=' + "#{calculathash}"+'" ' 
            system(curl_cmd)    				
          end		
        end
  
        if ENV['vital'] == "steps" || ENV['vital'] == "all"
          print "steps #{random_steps}"  
          if ENV['method'] == "activerecord"
            step = Step.new(:user_id => ENV['user_id'], :begin_timestamp => start_time, :end_timestamp => start_time+15, :steps => random_steps)
            step.save
          elsif ENV['method'] == "curl"

            steps_xml = "<step><steps>#{random_steps}</steps><user_id>#{ENV['user_id']}</user_id><begin_timestamp>#{start_time}</begin_timestamp><end_timestamp>#{start_time+15}</end_timestamp></step>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + steps_xml + '" ' +'"' + ENV['url'] + '/steps?gateway_id=' + "#{ENV['gateway_id']}" '&auth=' + "#{calculathash}"+'" '    
            puts curl_cmd
            system(curl_cmd)    				
          end		
        end
	
        puts
        puts
        sleep(ENV['frequency'].to_i)
      end
    end
  end
end