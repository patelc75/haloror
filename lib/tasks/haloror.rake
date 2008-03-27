require 'time'

namespace :halo do  
  desc "post random vitals data with either activerecord or curl"  
  def delete
    puts ""
    puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts "Deleting Vital, SkinTemp, Battery, and Step for all posts past #{Time.now} for user_id=#{ENV['user_id']}"
    puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts ""
    Vital.delete_all(["timestamp > ? AND user_id = ?" , Time.now, ENV['user_id']])
    SkinTemp.delete_all(["timestamp > ? AND user_id = ?" , Time.now, ENV['user_id']])
    Battery.delete_all(["timestamp > ? AND user_id = ?" , Time.now, ENV['user_id']])
    Step.delete_all(["begin_timestamp > ? AND user_id = ?" , Time.now, ENV['user_id']])
  end
  
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
      puts "You forgot the type. type = 'live' or 'historical'"
      puts ""
      print_usage = true
    else
      puts "Type: #{ENV['type']}"
    end
	
	
    if print_usage == true
      puts ""
      puts "Example Usage with curl: "
      puts "rake halo:post vital=all method=curl url=http://localhost:3000 increment=15 duration=5000 user_id=333 frequency=5 type=historical"	
      puts ""
      puts "Example Usage with activerecord (for same server): "
      puts "rake halo:post vital=all method=activerecord url=http://localhost:3000 increment=15 duration=5000 user_id=333 frequency=5 type=live"	
      puts ""
    else
      if(ENV['type'] == "live")
        delete
        start_time = Time.now
        end_time = start_time + ENV['duration'].to_i  
      elsif (ENV['type'] == "historical")
        end_time = Time.now
        start_time = end_time - ENV['duration'].to_i 
      end
		
      puts "Start time: #{start_time}" 
      puts "End time: #{end_time}"

      until start_time > end_time      
        puts "user_id: #{ENV['user_id']}"
        start_time = start_time + ENV['increment'].to_i #send a REST posts with the timestamp incremented by 15 seconds
		  		  
      if ENV['vital'] == "skin_temp" || ENV['vital'] == "all"
          random_skin_temp = rand(5)+96
          puts "#{start_time}: Posting skin temp of #{random_skin_temp} "  
          if ENV['method'] == "activerecord"
            skin_temp = SkinTemp.new(:user_id => ENV['user_id'], :timestamp => start_time, :skin_temp => random_skin_temp)
            skin_temp.save
          elsif ENV['method'] == "curl"
            skin_temp_xml = "<skin_temp><skin_temp>#{random_skin_temp}</skin_temp><user_id>#{ENV['user_id']}</user_id><timestamp>#{start_time}</timestamp></skin_temp>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + skin_temp_xml + '" ' + ENV['url'] + '/skin_temps'    
            puts curl_cmd
            system(curl_cmd)    				
          end		
        end
      
        if ENV['vital'] == "vitals" || ENV['vital'] == "all"
          random_orientation = rand(90)
          random_heartrate = rand(7)+70
          random_hrv = rand(5)
          random_activity = rand(25000)+10000
          if ENV['method'] == "activerecord"
            
            vitals = Vital.new(:user_id => ENV['user_id'], :timestamp => start_time, :orientation => random_orientation, :heartrate => random_heartrate, :hrv => random_hrv, :activity => random_activity)
            puts vitals
            vitals.save
          elsif ENV['method'] == "curl"
            
            vital_xml="<vital><activity>#{random_activity}</activity><heartrate>#{random_heartrate}</heartrate><hrv>#{random_hrv}</hrv><orientation>#{random_orientation}</orientation><timestamp>#{start_time}</timestamp><user_id>#{ENV['user_id']}</user_id></vital>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + vital_xml + '" ' + ENV['url'] + '/vitals'
            puts curl_cmd
            system(curl_cmd)    				
          end		
        end	       

       

        if ENV['vital'] == "battery" || ENV['vital'] == "all"
          random_percentage = rand(100)
          puts "#{start_time}: Posting battery of #{random_percentage} "  
          if ENV['method'] == "activerecord"
            battery = Battery.new(:user_id => ENV['user_id'], :timestamp => start_time, :percentage => random_percentage, :time_remaining => 0)
            battery.save
          elsif ENV['method'] == "curl"
            battery_xml = "<battery><percentage>#{random_percentage}</percentage><time_remaining>0</time_remaining><user_id>#{ENV['user_id']}</user_id><timestamp>#{start_time}</timestamp></battery>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + battery_xml + '" ' + ENV['url'] + '/batteries'    
            puts curl_cmd
            system(curl_cmd)    				
          end		
        end
		  
        if ENV['vital'] == "steps" || ENV['vital'] == "all"
          random_steps = rand(20)
         
          puts "#{start_time} to #{start_time+15}: Posting steps of #{random_steps} "  
          if ENV['method'] == "activerecord"
            step = Step.new(:user_id => ENV['user_id'], :begin_timestamp => start_time, :end_timestamp => start_time+15, :steps => random_steps)
            step.save
          elsif ENV['method'] == "curl"
           
            steps_xml = "<step><steps>#{random_steps}</steps><user_id>#{ENV['user_id']}</user_id><begin_timestamp>#{start_time}</begin_timestamp><end_timestamp>#{start_time+15}</end_timestamp></step>"
            curl_cmd ='curl -H "Content-Type: text/xml" -d "' + steps_xml + '" ' + ENV['url'] + '/steps'    
            puts curl_cmd
            system(curl_cmd)    				
          end		
        end
		
     	
		
        puts ""		
        puts "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
        puts ""
		
        sleep(ENV['frequency'].to_i)
      end
    end
  end
 end
