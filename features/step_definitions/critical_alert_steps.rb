# critical alert related
# ==========
# = givens =
# ==========

Given /^critical alerts types exist$/ do
  if (_critical = AlertGroup.create( :group_type => "critical"))
    ["Fall", "Panic", "GwAlarmButton", "GwAlarmButtonTimeout"].each do |_alert_type|
      _critical.alert_types.create( :alert_type => _alert_type)
    end
  end
end

# =========
# = whens =
# =========

When /^I simulate a "([^\"]*)" with delivery to the call center for user login "([^\"]*)" with a "([^\"]*)" "([^\"]*)"$/ do |model, login, valid, error_type|
  # user = nil
  user = User.find_by_login(login, :include => :profile)

  if valid == "invalid"
    case error_type
      when "call center account number"
        user.profile.update_attribute(:account_number, '')
      when "profile"
        user.profile = nil
        user.save
      when "TCP connection"
        #http://rspec.info/documentation/mocks/message_expectations.html
        SafetyCareClient.should_receive(:alert).once.and_raise(Timeout::Error)
      # else "Unknown"
    end
  end
  # SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 0, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  # Factory.create( :system_timeout, {
  #   :mode                           => 'dialup',
  #   :critical_event_delay_sec       => 0,
  #   :gateway_offline_timeout_sec    => 0,
  #   :gateway_offline_offset_sec     => 0,
  #   :device_unavailable_timeout_sec => 0,
  #   :strap_off_timeout_sec          => 0
  # })
  When "system timeout exists with no tolerence"
  #   * collect model attributes
  #   * include :magnitude if model has that attribute
  _attributes = {
    :timestamp        => 2.minutes.ago, # Time.now-2.minutes
    :user             => user,
    :device_id        => Device.find_by_serial_number("1234567890").id,
    :timestamp_server => 1.minute.ago
  }.merge( model.classify.constantize.new.respond_to?( :magnitude) ? { :magnitude => 23 } : {})
  #   * create the model row
  # Factory.create( model.gsub(/ /,'_').to_sym, _attributes )
  model.classify.constantize.create( _attributes)
  # _attributes[:magnitude] = 23 if model.classify.constantize.new.respond_to?( :magnitude) # unless model.downcase == 'panic' # , :magnitude => 23
  # object = model.gsub(/ /,'_').classify.constantize.create( _attributes) # was 965
  # object.timestamp_server = 1.minute.ago # Time.now-1.minute
  # object.send(:update_without_callbacks)
  When "critical alerts are processed by a background job" # CriticalDeviceAlert.job_process_crtical_alerts
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

When /^critical alerts are processed by a background job$/ do
  CriticalDeviceAlert.job_process_crtical_alerts
end

When /^system timeout exists with (.+) tolerence$/ do |_tolerence|
  ["dialup", "ethernet"].each do |_network_mode|
    Factory.create( :system_timeout, {
      :mode                           => _network_mode,
      :critical_event_delay_sec       => _tolerence.to_i,
      :gateway_offline_timeout_sec    => _tolerence.to_i,
      :gateway_offline_offset_sec     => _tolerence.to_i,
      :device_unavailable_timeout_sec => _tolerence.to_i,
      :strap_off_timeout_sec          => _tolerence.to_i
    })
  end
end

# =========
# = thens =
# =========

#
#  Mon Feb 28 23:58:55 IST 2011, ramonrails
#   * changed the business logic code during voice call on skype
#   * WARNING: needs to get these steps verified
Then /^I should have a "([^\"]*)" alert "([^\"]*)" to the call center with a "([^\"]*)" call center delivery timestamp$/ do |model, pending_string, timestamp_status|
  critical_alert =  model.classify.constantize.first
  if pending_string == "not pending"
    critical_alert.call_center_pending.should be_false, "#{model} should be not pending"
  elsif pending_string == "pending"
    critical_alert.call_center_pending.should be_true, "#{model} should be pending"
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

Then /^I should have (.+) count(?:|s) of "([^\"]*)"$/ do |count, model|
  ( model.classify.constantize.count +  Event.count( :conditions => { :event_type => model.classify}) ).should == (2 * count.to_i) #, "Should have #{count} #{model}"
end

Then /^I should exactly have (.+) count(?:|s) of "([^\"]*)" and events$/ do |count, model|
  (model.constantize.count + Event.all.length).should == count.to_i #, "Should have #{count} #{model}"
end

