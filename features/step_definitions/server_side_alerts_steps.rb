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
  table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase] = ( value.include?('`') ? eval(value.gsub('`','')).to_s : value) }
  # table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase] = value }

  _event = _event.downcase.gsub(/ /,'_')
  options['file_name'] = "#{_event}.xml" unless options.has_key?( 'file_name')
  options['path'] = "/#{_event.pluralize}" unless options.has_key?( 'path')

  #   * attributes specific to events can also be introduced hete to make step definition short and readable
  # _event = _event.downcase.gsub(/ /,'_')
  # case _event
  # when 'strap_fastened'
  # end
  When "I post the following XML:", table( options.collect {|k,v| "| #{k} | #{v} |" }.join(10.chr) )

  case _event
  when 'strap_fastened', 'strap_removed'
    if (dss = DeviceStrapStatus.last( :order => 'updated_at')) # pick most recent one
      dss.updated_at = Time.parse(options['timestamp'])
      #   * update without timestamp is mandatory
      dss.send( :update_without_callbacks)
    end
  end
end


When /^I simulate a mgmt query with the timestamp "([^\"]*)" and device_id "([^\"]*)"$/ do |timestamp, device_id|
  #user = User.find_by_login(login, :include => :profile)

  # SystemTimeout.create(:mode => "dialup", :critical_event_delay_sec => 0, :gateway_offline_timeout_sec => 21600, :gateway_offline_offset_sec => 4800, :device_unavailable_timeout_sec => 0, :strap_off_timeout_sec => 0)
  Factory.create( :system_timeout, {
    :mode                           => 'dialup',
    :critical_event_delay_sec       => 0,
    :gateway_offline_timeout_sec    => 21600,
    :gateway_offline_offset_sec     => 4800,
    :device_unavailable_timeout_sec => 0,
    :strap_off_timeout_sec          => 0
    })
  # query = MgmtQuery.new
  # query.device_id = device_id
  # query.timestamp_device = timestamp
  # query.timestamp_server = Time.now
  # query.poll_rate = 60
  # query.cycle_num = 1
  # query.save
  #   * supply the ones that are not default. Others picked from factory definition
  Factory.create( :mgmt_query, {
    :device_id        => device_id,
    :timestamp_device => timestamp
    })

  # dlq = DeviceLatestQuery.first
  # dlq.updated_at = 7.hours.ago
  # dlq.save
  DeviceLatestQuery.first.update_attribute( :updated_at => 7.hours.ago)
  MgmtQuery.job_gw_offline
end

When /^background scheduler has detected strap offs$/ do
  StrapOffAlert.job_detect_straps_off
end

When /^background scheduler has detected device unavailables$/ do
  StrapOffAlert.job_detect_unavailable_devices
end
# =========
# = thens =
# =========

#   * strap fastened
#   * strap removed
Then /^device "([^"]*)" should state the strap (fastened|removed) between now and "([^\"]*)"$/ do |_serial, _state, _timestamp|
  (device = Device.find_by_serial_number(_serial)).should_not be_blank
  #   * need UTC
  _timestamp = Time.parse( (_timestamp.include?('`') ? eval(_timestamp.gsub('`','')).to_s : _timestamp) ).utc
  device.send("strap_#{_state.pluralize}".to_sym).within_time_span( _timestamp).should_not be_blank
end