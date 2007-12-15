require 'time'

namespace :halo do
  desc "post random vitals data with either activerecord or curl"  
  task :post => :environment  do
    end_time = Time.now
    #end_time = Time.parse('2007-08-30 18:44:37-04') #hardcoded for demo 
	start_time = end_time - ENV['duration'].to_i  #24 x 60 x 60 = 1 day
    
	if ENV['vital'] == nil
	  puts ""	
	  puts "You forgot vital. vital = heartrate, skin_temp, actvity, or all"
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
	  puts "You forgot increment. increment = seconds between each post"
	  puts ""
	  print_usage = true
	else
	  puts "Start time: #{start_time}" 
	  puts "End time: #{end_time}"
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
	
	if ENV['url'] == nil &&  ENV['method'] == "curl"
	  puts ""
	  puts "You forgot the url. Example: http://localhost:3000"
	  puts ""
	  print_usage = true
	else
	  puts "URL: #{ENV['url']}\n"
	end
	
	if print_usage == true
	  puts ""
	  puts "Example Usage with curl: "
	  puts "rake halo:post vital=all method=curl url=http://localhost:3000 increment=15 duration=5000 user_id=333"	
	  puts ""
	  puts "Example Usage with activerecord: "
	  puts "rake halo:post vital=all method=activerecord increment=15 duration=5000 user_id=333"	
	  puts ""
	else
		until start_time > end_time      
		  start_time = start_time + ENV['increment'].to_i #send a REST posts with the timestamp incremented by 15 seconds
		  
		  if ENV['vital'] == "heartrate" || ENV['vital'] == "all"
			random_heartrate = rand(7)+70
			puts "#{start_time}: Posting heartrate of #{random_heartrate}"  
			if ENV['method'] == "activerecord"
			  heartrate = Heartrate.new(:user_id => ENV['user_id'], :timestamp => start_time, :heartrate => random_heartrate)
			  heartrate.save
			elsif ENV['method'] == "curl"
			  heartrate_xml = "<heartrate><heartrate>#{random_heartrate}</heartrate><user_id>#{ENV['user_id']}</user_id><timestamp>#{start_time}</timestamp></heartrate>"
			  curl_cmd ='curl -H "Content-Type: text/xml" -d "' + heartrate_xml + '" ' + ENV['url'] + '/heartrates'    
			  puts curl_cmd
			  system(curl_cmd)    		
			end
		  end
		  
		  if ENV['vital'] == "activity" || ENV['vital'] == "all"
			random_activity = rand(25000)+10000
			puts "#{start_time}: Posting activty of #{random_activity}"  
			if ENV['method'] == "activerecord"
			  activity = Activity.new(:user_id => ENV['user_id'], :timestamp => start_time, :activity => random_activity)
			  activity.save	  
			elsif ENV['method'] == "curl"
			  activity_xml = "<activity><activity>#{random_activity}</activity><user_id>#{ENV['user_id']}</user_id><timestamp>#{start_time}</timestamp></activity>"
			  curl_cmd ='curl -H "Content-Type: text/xml" -d "' + activity_xml + '" ' + ENV['url'] + '/activities'    
			  puts curl_cmd
			  system(curl_cmd)    		
			end
		  end
		  
		  if ENV['vital'] == "skin_temp" || ENV['vital'] == "all"
			random_skin_temp = rand(2)+93
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
		end
	end
  end
end
