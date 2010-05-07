# critical alert related
# ----------------- Given

# ----------------- When

When /^I simulate a "([^\"]*)" with delivery to the call center for user login "([^\"]*)" with a "([^\"]*)" "([^\"]*)"$/ do |model, login, valid, error_type|
  # user = nil
  user = User.find_by_login(login)
  
  if valid == "invalid"
    case error_type
      when "call center account number" 
        Profile.update(user.profile.id, {:account_number => nil})
        # user.profile.account_number = ""
        # user.profile.save
        debugger
      when "profile"
        user.profile = nil
        user.save
      when "TCP connection"
        #http://rspec.info/documentation/mocks/message_expectations.html
        SafetyCareClient.should_receive(:alert).once.and_raise(Timeout::Error)
      # else "Unknown"
    end
  end
  SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 0, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  object = model.constantize.create(:timestamp => Time.now-2.minutes, :user_id => user.id, :magnitude => 23, :device_id => 965)
  object.timestamp_server = Time.now-1.minute
  object.send(:update_without_callbacks)
  DeviceAlert.job_process_crtical_alerts
end

When /^Battery status is "([^\"]*)" and "([^\"]*)" is latest for user login "([^\"]*)"$/ do |status, battery, login|
  user_id = User.find_by_login(login).id
  if status == 'available'
    Battery.create(:user_id => user_id,:timestamp => Time.now,:percentage => 5,:time_remaining => 20,:device_id => 2,:acpower_status => true) if battery == 'BatteryPlugged'
    Battery.create(:user_id => user_id,:timestamp => Time.now,:percentage => 5,:time_remaining => 20,:device_id => 2,:acpower_status => false) if battery == 'BatteryUnplugged'
  else
    battery_plugged_timestamp = battery == 'BatteryPlugged' ? Time.now : Time.now - 1.day
    battery_unplugged_timestamp = battery == 'BatteryUnplugged' ? Time.now : Time.now - 1.day
    device = Device.create(:id => 2,:serial_number => 'H200933345',:active => true)
    BatteryPlugged.create(:device_id => device.id,:timestamp => battery_plugged_timestamp,:percentage => 5,:time_remaining => 20,:user_id => user_id)
    BatteryUnplugged.create(:device_id => device.id,:timestamp => battery_unplugged_timestamp,:percentage => 5,:time_remaining => 20,:user_id => user_id)
  end
end

# ---------- Then

Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center with a "([^\"]*)" call center delivery timestamp$/ do |model, pending_string, timestamp_status|
  critical_alert =  model.constantize.first   
  if pending_string == "not pending"
    assert critical_alert.call_center_pending == false, "#{model} should be not pending"
  elsif pending_string == "pending"
    assert critical_alert.call_center_pending == true, "#{model} should be pending"  
  else
    assert false, "#{pending_string} is not a valid pending status"
  end

  if timestamp_status == "missing"
    critical_alert.timestamp_call_center.should be_nil, "#{model} should have nil timestamp"
  elsif timestamp_status == "valid"
    assert critical_alert.timestamp_call_center > critical_alert.timestamp_server, "#{model} should have timestamp_call_center later than timestamp_server"     
  else
    assert false, "#{timestamp_status} is not a valid timestamp status"
  end  
end

Then /^I should have "([^\"]*)" count of "([^\"]*)"$/ do |count, model| 
  assert model.constantize.count + Event.all.length == 2*count.to_i, "Should have #{count} #{model}"
end

