# 
# require "#{File.dirname(__FILE__)}/../test_helper" 
# 
# class UserStoriesTest < ActionController::IntegrationTest
#   fixtures :users
#   fixtures :profiles
#   fixtures :devices
#   fixtures :devices_users
#   fixtures :roles
#   fixtures :roles_users
#   fixtures :roles_users_options
#   fixtures :alert_options
#   fixtures :alert_types
#   fixtures :carriers
#   
# 
#  
#  
#  
#   # Checking = "Tue Dec 25 15:52:55 -0600 2007"
#   Checking = "Tue Dec 25 15:52:55 UTC 2007"
#   #puts "hi how r u : #{devices(:madhu).id} "
#  
#   def host_name_finder 
#     
#     
#     hostname1 = `hostname`
#     puts "hostname = #{hostname1}"
#    
#     original_host = `hostname`
#     hostname2 = Socket.gethostname 
#    
#   
#       
#     splited = hostname2.split('.')
#     splited_local = splited[1]
#     puts"hostanme_split  = #{splited_local} "
#       
#     if (splited_local == "local")
#       original_host = "localhost:3000"
#     end
#     
#     puts "host name is : #{original_host}"
#     
#     original_host
#   end
#   
#   
#     
#  # puts " ////////////////////////////////////////"
#  #  puts" please check whether you received eight emails in https://mail.google.com/a/halomonitoring.com . "
#  #  puts" User Name: test_caregiver1 "
#  #  puts" Password : test_caregiver1 "
#  #  puts "Please also check you received eight emails in another account with "
#  #  puts" User Name: test_user"
#  #  puts" Password : test_user"
#  #  puts" ///// The End /////// Part 2 is coming soon "
#  
#   
# 
#    
#     
#     
#   def test_fall
#     puts "testing fall"
#        
#    originalhost = host_name_finder    
# 
#     fall_event_xml = "<fall><magnitude>60</magnitude><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></fall>"
#     curl_cmd ='curl -v -H "Content-Type: text/xml" -d "' + fall_event_xml + '" ' +'"' + "http://#{originalhost}/falls?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" ' 
#     puts curl_cmd
#     system(curl_cmd)
#       
# 
#     @fall = Fall.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @ts = @fall.timestamp.to_s
#     assert_equal @ts, Checking.to_s
#    
# 
#   end
#   
#   def test_panic
#     puts " just panic "
#        
#     originalhost = host_name_finder  
#        
#     panic_event_xml = "<panic><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></panic>"
#     panic_cmd ='curl -v -H "Content-Type: text/xml" -d "' + panic_event_xml + '" ' +'"' + "http://#{originalhost}/panics?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#     #  # panic_cmd = 'curl -v -H "Content-Type: text/xml" -d "<panic><user_id>1</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" http://localhost:3000/panics?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024'
#     puts panic_cmd
#     system(panic_cmd)
# 
#     @panic = Panic.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspan = @panic.timestamp.to_s
#     assert_equal @tspan, Checking.to_s
#        
#   end
#   
#   def test_batterychargecomplete  
#     puts "testing battery "
#     
#    
#     originalhost = host_name_finder 
#    
#     batterycomplete_event_xml = "<battery_charge_complete><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
#     <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_charge_complete>"
#     batterycomplete_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batterycomplete_event_xml + '" ' +'"' + "http://#{originalhost}/battery_charge_completes?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#  
#     puts batterycomplete_cmd
#     system(batterycomplete_cmd)
# 
#     @batterycomplete = BatteryChargeComplete.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspanbc = @batterycomplete.timestamp.to_s
#     assert_equal @tspanbc, Checking.to_s
#   end  
#   
#   
#   def test_batterycritical  
#     puts "testing battery critical"
#     
#     originalhost = host_name_finder 
#     batterycritical_event_xml = "<battery_critical><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
#       <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_critical>"
#     batterycritical_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batterycritical_event_xml + '" ' +'"' + "http://#{originalhost}/battery_criticals?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
# 
#     puts batterycritical_cmd
#     system(batterycritical_cmd)
# 
#     @batterycritical = BatteryCritical.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspanbcr = @batterycritical.timestamp.to_s
#     assert_equal @tspanbcr, Checking.to_s
#   end
#   
#   def test_batteryplugged
#     puts "testing battery plugged"
#     
#     originalhost = host_name_finder 
#     batteryplugged_event_xml = "<battery_plugged><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
#     <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_plugged>"
#     batteryplugged_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batteryplugged_event_xml + '" ' +'"' + "http://#{originalhost}/battery_pluggeds?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#  
#     puts batteryplugged_cmd
#     system(batteryplugged_cmd)
# 
#     @batteryplugged = BatteryPlugged.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspanpg = @batteryplugged.timestamp.to_s
#     assert_equal @tspanpg, Checking.to_s
#     
#   end  
#   
#   def test_batteryunplugged
#     puts "testing battery unplugged"
#     
#     originalhost = host_name_finder 
#     batteryunplugged_event_xml = "<battery_unplugged><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage><time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_unplugged>"
#     batteryunplugged_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batteryunplugged_event_xml + '" ' +'"' + "http://#{originalhost}/battery_unpluggeds?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#  
#     puts batteryunplugged_cmd
#     system(batteryunplugged_cmd)
# 
#     @batteryunplugged = BatteryUnplugged.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspanup = @batteryunplugged.timestamp.to_s
#     assert_equal @tspanup, Checking.to_s
#     
#   end
#   
#   
#   
#   def test_strapremoved
#     puts "testing strap removed"
#     
#     originalhost = host_name_finder 
#     strapremoved_event_xml = "<strap_removed><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></strap_removed>"
#     strapremoved_cmd ='curl -v -H "Content-Type: text/xml" -d "' + strapremoved_event_xml + '" ' +'"' + "http://#{originalhost}/strap_removeds?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#  
#     puts strapremoved_cmd
#     system(strapremoved_cmd)
# 
#     @strapremoved = StrapRemoved.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspansr = @strapremoved.timestamp.to_s
#     assert_equal @tspansr, Checking.to_s
#     
#   end  
#   
#   def test_strapfastened
#     puts "testing strap fastened"
#     
#     originalhost = host_name_finder 
#     strapfastened_event_xml = "<strap_fastened><device_id>#{devices(:madhu).id}</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></strap_fastened>"
#     strapfastened_cmd ='curl -v -H "Content-Type: text/xml" -d "' + strapfastened_event_xml + '" ' +'"' + "http://#{originalhost}/strap_fasteneds?gateway_id=#{devices(:madhu).id}&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
#  
#     puts strapfastened_cmd
#     system(strapfastened_cmd)
# 
#     @strapfastened = StrapFastened.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
#     @tspansf = @strapfastened.timestamp.to_s
#     assert_equal @tspansf, Checking.to_s
#   
#   end
#   
#   
# 
#     
#   
#   
#   
#   
#   #class UserStoriesTest end 
# end
