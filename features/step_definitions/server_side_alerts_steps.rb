require "digest/sha2"

# =========
# = whens =
# =========

# 
#  Fri Feb 18 02:42:55 IST 2011, ramonrails
#   * flexible step. just mention the event name
# Assumptions:
#   * a file exists with the same name as the event. downcase, underscored
# Example:
#   * I simulate a "Strap Fastened" ... (will assume)
#   * 1. an XML file named strap_fastened.xml exists
#   * 2. POST URL is /strap_fasteneds
#   * Specify these attributes only when default assumption may be incorrect
When /^I simulate a "([^"]*)" event with the following attributes:$/ do |_event, table|
  # fetch values and keys from the table
  options = {}
  table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase] = value }

  _event = _event.downcase.gsub(/ /,'_')
  options['file_name'] = "#{_event}.xml" unless options.has_key?( 'file_name')
  options['path'] = "/#{_event.pluralize}" unless options.has_key?( 'path')
  
  #   * attributes specific to events can also be introduced hete to make step definition short and readable
  # _event = _event.downcase.gsub(/ /,'_')
  # case _event
  # when 'strap_fastened'
  # end

  When "I post the following XML:", table( options.collect {|k,v| "| #{k} | #{v} |" }.join(10.chr) )
end


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

When /^background scheduler has detected strap offs$/ do
  StrapOffAlert.job_detect_straps_off
end

# =========
# = thens =
# =========

Then /^device "([^"]*)" should state the strap fastened between now and "([^\"]*)"$/ do |_serial, _timestamp|
  (device = Device.find_by_serial_number(_serial)).should_not be_blank
  #   * need UTC
  _timestamp = Time.parse( (_timestamp.include?('`') ? eval(_timestamp.gsub('`','')).to_s : _timestamp) ).utc
  device.strap_fasteneds.within_time_span( _timestamp).should_not be_blank
end