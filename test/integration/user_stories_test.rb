
require "#{File.dirname(__FILE__)}/../test_helper" 

class UserStoriesTest < ActionController::IntegrationTest
  fixtures :users
  fixtures :profiles
  fixtures :devices
  fixtures :roles
  fixtures :roles_users
  fixtures :roles_users_options

 
 
 
  # Checking = "Tue Dec 25 15:52:55 -0600 2007"
  Checking = "Tue Dec 25 15:52:55 UTC 2007"
  
 
  

   
    
    
    def test_fall
       puts "testing fall"
       fall_event_xml = "<fall><magnitude>60</magnitude><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></fall>"
       curl_cmd ='curl -v -H "Content-Type: text/xml" -d "' + fall_event_xml + '" ' +'"' + "http://localhost:3000/falls?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" ' 
       puts curl_cmd
       system(curl_cmd)

       @fall = Fall.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
       @ts = @fall.timestamp.to_s
       assert_equal @ts, Checking.to_s
   

  end
  
 def test_panic
       puts " just panic "
       
       panic_event_xml = "<panic><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></panic>"
       panic_cmd ='curl -v -H "Content-Type: text/xml" -d "' + panic_event_xml + '" ' +'"' + "http://localhost:3000/panics?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
    #  # panic_cmd = 'curl -v -H "Content-Type: text/xml" -d "<panic><user_id>1</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" http://localhost:3000/panics?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024'
      puts panic_cmd
       system(panic_cmd)

       @panic = Panic.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
       @tspan = @panic.timestamp.to_s
       assert_equal @tspan, Checking.to_s
       
  end
  
 def test_batterychargecomplete  
    puts "testing battery "
    batterycomplete_event_xml = "<battery_charge_complete><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
    <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_charge_complete>"
    batterycomplete_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batterycomplete_event_xml + '" ' +'"' + "http://localhost:3000/battery_charge_completes?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
 
   puts batterycomplete_cmd
    system(batterycomplete_cmd)

    @batterycomplete = BatteryChargeComplete.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @tspanbc = @batterycomplete.timestamp.to_s
    assert_equal @tspanbc, Checking.to_s
  end  
  
  
  def test_batterycritical  
      puts "testing battery critical"
      batterycritical_event_xml = "<battery_critical><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
      <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_critical>"
      batterycritical_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batterycritical_event_xml + '" ' +'"' + "http://localhost:3000/battery_criticals?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '

     puts batterycritical_cmd
      system(batterycritical_cmd)

      @batterycritical = BatteryCritical.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
      @tspanbcr = @batterycritical.timestamp.to_s
      assert_equal @tspanbcr, Checking.to_s
    end
  
  def test_batteryplugged
    puts "testing battery plugged"
    batteryplugged_event_xml = "<battery_plugged><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage>
    <time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_plugged>"
    batteryplugged_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batteryplugged_event_xml + '" ' +'"' + "http://localhost:3000/battery_pluggeds?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
 
   puts batteryplugged_cmd
    system(batteryplugged_cmd)

    @batteryplugged = BatteryPlugged.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @tspanpg = @batteryplugged.timestamp.to_s
    assert_equal @tspanpg, Checking.to_s
    
  end  
  
  def test_batteryunplugged
    puts "testing battery unplugged"
    batteryunplugged_event_xml = "<battery_unplugged><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><percentage>33</percentage><time_remaining>232</time_remaining><user_id>#{users(:madhu).id}</user_id></battery_unplugged>"
    batteryunplugged_cmd ='curl -v -H "Content-Type: text/xml" -d "' + batteryunplugged_event_xml + '" ' +'"' + "http://localhost:3000/battery_unpluggeds?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
 
   puts batteryunplugged_cmd
    system(batteryunplugged_cmd)

    @batteryunplugged = BatteryUnplugged.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @tspanup = @batteryunplugged.timestamp.to_s
    assert_equal @tspanup, Checking.to_s
    
  end
  
  
  
  def test_strapremoved
    puts "testing strap removed"
    strapremoved_event_xml = "<strap_removed><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></strap_removed>"
    strapremoved_cmd ='curl -v -H "Content-Type: text/xml" -d "' + strapremoved_event_xml + '" ' +'"' + "http://localhost:3000/strap_removeds?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
 
   puts strapremoved_cmd
    system(strapremoved_cmd)

    @strapremoved = StrapRemoved.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @tspansr = @strapremoved.timestamp.to_s
    assert_equal @tspansr, Checking.to_s
    
  end  
  
  def test_strapfastened
    puts "testing strap fastened"
    strapfastened_event_xml = "<strap_fastened><device_id>1</device_id><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>#{users(:madhu).id}</user_id></strap_fastened>"
    strapfastened_cmd ='curl -v -H "Content-Type: text/xml" -d "' + strapfastened_event_xml + '" ' +'"' + "http://localhost:3000/strap_fasteneds?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"+'" '
 
   puts strapfastened_cmd
    system(strapfastened_cmd)

    @strapfastened = StrapFastened.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @tspansf = @strapfastened.timestamp.to_s
    assert_equal @tspansf, Checking.to_s
  
  end
    
  
  
  
end
