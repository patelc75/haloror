class MgmtQuery < ActiveRecord::Base
  include ActionView::Helpers::DateHelper # needed for distance_of_time_in_words
  
  #MINUTES_INTERVAL = 1
  belongs_to :mgmt_cmd
  belongs_to :device

  # latest row for device_id
  def self.latest_by_device_id( device_id)
    find_by_device_id( device_id.to_i, :order => "timestamp_server DESC") unless device_id.blank? || device_id.to_i.zero?
  end
  
  # delay between timestamp_device <=> timestamp_server
  # we can also use ApplicationHelper.difference_between_datetime for more specific values
  def delay
    distance_of_time_in_words( timestamp_server - timestamp_device)
  end
  
  # time elapsed since last post (device_id picked from "self")
  # we can also use ApplicationHelper.difference_between_datetime for more specific values
  def time_span_since_last
    row = MgmtQuery.find_by_id( id-1)
    row.blank? ? "" : [distance_of_time_in_words( timestamp_device - row.timestamp_device), distance_of_time_in_words( timestamp_server - row.timestamp_server)]
  end

  def self.new_initialize(random=false)
    model = self.new
    if random
      model.poll_rate = 30 + rand(60)
    else
      model.poll_rate = 60
    end
    return model    
  end
  
  # Each user's wireless gateway queries the server every MINUTES_INTERVAL minutes. We need to detect the devices that have
  # not connected in a while and create notifications of GWOfflineAlert after a certain number of failures. 
  def MgmtQuery.job_gw_offline
    RAILS_DEFAULT_LOGGER.warn("MgmtQuery.job_gw_offline running at #{Time.now}")
    ethernet_system_timeout = SystemTimeout.find_by_mode('ethernet')
    dialup_system_timeout   = SystemTimeout.find_by_mode('dialup')

=begin
    #GWOnline check moved to MgmtQueriesController::create to cut down on Rufus load    
    MgmtQuery.gw_online_check(ethernet_system_timeout)
    MgmtQuery.gw_online_check(dialup_system_timeout)
 
    #not sure why would want to send GW Offline alerts for devices with no existing GW Offline alerts
    devices = Device.find(:all, 
                          :conditions => "id in (select dlq.id from device_latest_queries dlq where dlq.id not in (select device_id from gateway_offline_alerts group by device_id))")
    devices.each do |device|
      begin
        MgmtQuery.gw_offline_process(device)
      rescue Exception => e
        logger.fatal("Error processing outage alert for device #{device.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development" || ENV['RAILS_ENV'] == "test"
      end
    end
=end

    MgmtQuery.gw_offline_check(ethernet_system_timeout)    
    MgmtQuery.gw_offline_check(dialup_system_timeout) #this could be done less frequently potentially since timeout is greater
  end
  
  
  private
  # Check if gateway is offline for the first time and every subsequent time
  def MgmtQuery.gw_offline_check(access_mode_system_timeout)
    conds = MgmtQuery.access_mode_conds(access_mode_system_timeout) #conds to query for either ethernet or dialup devices
    #conds << "id in (select dlq.id from device_latest_queries dlq where dlq.updated_at < now() - interval '#{access_mode_system_timeout.gateway_offline_timeout_sec*(1+GATEWAY_OFFLINE_TIMEOUT_MARGIN)} seconds')"
    gw_offline_timeout = access_mode_system_timeout.gateway_offline_timeout_sec
    gw_offline_timeout += access_mode_system_timeout.gateway_offline_offset_sec if !access_mode_system_timeout.gateway_offline_offset_sec.nil? 
    conds << "updated_at < now() - interval '#{gw_offline_timeout} seconds'"
    conds << "reconnected_at is NOT NULL"
    dlqs = DeviceLatestQuery.find(:all, :conditions => conds.join(' and '))
    #devices = Device.find(:all, :conditions => conds.join(' and '))
    dlqs.each do |dlq|
      begin
        alert = GatewayOfflineAlert.new
        alert.device = Device.find(dlq.id)
        alert.save!
        dlq.reconnected_at = nil
        dlq.save
        #MgmtQuery.gw_offline_process(device)
      rescue Exception => e
        logger.fatal("Error processing outage alert for device #{dlq.inspect}: #{e}")
        raise e if ENV['RAILS_ENV'] == "development" || ENV['RAILS_ENV'] == "test"
      end
    end
  end
  
  def MgmtQuery.access_mode_conds(access_mode_system_timeout)
    if access_mode_system_timeout && access_mode_system_timeout.mode == "ethernet"
      conds = ["(id in (select device_id from access_mode_statuses where mode = 'ethernet') OR id not in (select device_id from access_mode_statuses))"]
    elsif access_mode_system_timeout && access_mode_system_timeout.mode == "dialup"
      conds = ["id in (select device_id from access_mode_statuses where mode = 'dialup') "]
    else
      conds = []
    end
  end
  
=begin
  # Find devices that were previously offline but have come back online. Trigger a "Reconnect" event for these
  # devices. In practice, there should be very few of these alerts so we process them one by one as the devices come back online.
  def MgmtQuery.gw_online_check(access_mode_system_timeout = nil)    
    conds = MgmtQuery.access_mode_conds(access_mode_system_timeout) #conds to find ethernet or dialup devices
    #conds << ("id in (select device_id from gateway_offline_alerts where reconnected_at is null and " << 
    #            "device_id in (select id from device_latest_queries where updated_at > now() - interval '#{access_mode_system_timeout.gateway_offline_timeout_sec*(1+GATEWAY_OFFLINE_TIMEOUT_MARGIN)} seconds'))")
    conds << "reconnected_at is NULL"
    conds << "updated_at > now() - interval '#{access_mode_system_timeout.gateway_offline_timeout_sec*(1+GATEWAY_OFFLINE_TIMEOUT_MARGIN)} seconds'"
    
    dlqs = DeviceLatestQuery.find(:all, :conditions => conds.join(' and '))           
    #reconnected = Device.find(:all, :conditions => conds.join(' and '))
    dlqs.each do |dlq|
      Device.transaction do
        GatewayOnlineAlert.create(:device => Device.find(dlq.id))
#       GatewayOfflineAlert.find(:all, 
#                                 :conditions => ['device_id = ? and reconnected_at is null', device.id]).each do |alert|
        dlq.reconnected_at = Time.now
        dlq.save!
#       end          
      end
    end
  end
  
  def MgmtQuery.gw_offline_process(device)
    alert = GatewayOfflineAlert.find(:first, :order => 'created_at desc',
                                     :conditions => ['reconnected_at is null and device_id = ?', device.id])
    
    if alert
      alert.number_attempts += 1
      alert.save!
    else
      alert = GatewayOfflineAlert.new
      alert.device = device
      alert.save!
    end
  end
=end
end
