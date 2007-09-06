# heartrate_post.rb
# August 20, 2007
require 'time'

namespace :halo do
  desc "post to the heartrate table with a cURL cmd"
  task :post_heartrate_with_curl do
    end_time = Time.new
    start_time = end_time - 24 * 60 * 60 #subtract 1 day in seconds
    #start_time = end_time - 60 * 60 #subtract 1 hour in seconds
    until start_time > end_time      
      start_time = start_time + 15 #send a REST posts with the timestamp incremented by 15 seconds
      puts start_time
      heartrate_xml = "<heartrate><heartrate>#{rand(4)+70}</heartrate><user_id>0817</user_id><timestamp>#{start_time}</timestamp></heartrate>"
      #puts heartrate_xml
      curl_cmd ='curl -H "Content-Type: text/xml" -d "' + heartrate_xml + '" http://localhost:3000/heartrates'    
      #puts curl_cmd
      system(curl_cmd)    
    end
  end
  
  desc "post to the heartrate table with activerecords"  
  task :post_heartrate_with_activerecord => :environment  do
    end_time = Time.new
    start_time = end_time - 60 
    #start_time = end_time - 24 * 60 * 60 #subtract 1 day in seconds
    #start_time = end_time - 60 * 60 #subtract 1 day in seconds
    until start_time > end_time      
      start_time = start_time + 15 #send a REST posts with the timestamp incremented by 15 seconds
      puts "Posting #{start_time}"  
      heartrate = Heartrate.new(:user_id => 817, :timestamp => start_time, :heartrate => rand(5)+70)
      heartrate.save
    end
  end
end