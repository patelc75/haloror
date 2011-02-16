When /^I simulate a mgmt query with the timestamp "([^\"]*)" and device_id "([^\"]*)"$/ do |timestamp, device_id|   
  #user = User.find_by_login(login, :include => :profile)

  SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 21600, :gateway_offline_offset_sec => 4800, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  query = MgmtQuery.new
  query.device_id = device_id
  query.timestamp_device = timestamp
  query.timestamp_server = Time.now
  query.poll_rate = 60
  query.cycle_num = 1
  query.save
  
  dlq = DeviceLatestQuery.first
  dlq.updated_at = 7.hours.ago  
  dlq.save
  MgmtQuery.job_gw_offline  
end                       