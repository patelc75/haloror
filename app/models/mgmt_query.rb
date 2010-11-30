class MgmtQuery < ActiveRecord::Base
  include ActionView::Helpers::DateHelper # needed for distance_of_time_in_words
  include UtilityHelper
  
  #MINUTES_INTERVAL = 1
  belongs_to :mgmt_cmd
  belongs_to :device
  attr_accessor :last_mgmt_query # cache for faster access
  
  # Usage:
  #   MgmtQuery.where_device_id( 273)
  #   MgmtQuery.where_device_id( 273, 481)
  named_scope :where_device_id, lambda {|*args| { :conditions => { :device_id => args.flatten } }}
  # Usage:
  #   MgmtQuery.since               # default => since 1.week.ago
  #   MgmtQuery.since( 2.months.ago)  # can use any form of Date, Time, DateTime
  named_scope :since, lambda {|*args| { :conditions => ["timestamp_server > ?", (args.flatten.first || 1.week.ago)] }}
  # Usage:
  #   MgmtQuery.recent_few
  #   MgmtQuery.recent_few( 5)
  named_scope :recent_few, lambda {|*args| { :order => "timestamp_server DESC", :limit => (args.flatten.first || 4) }}

  # latest row for device_id
  def self.latest_by_device_id( device_id)
    find_by_device_id( device_id.to_i, :order => "timestamp_server DESC") unless device_id.blank? || device_id.to_i.zero?
  end
  
  # before latest row for device_id. cache for faster access
  def last
    last_mgmt_query ||= MgmtQuery.find_by_device_id( device_id.to_i, :conditions => ["id < ?", id], :order => "timestamp_server DESC", :limit => 2) unless device_id.blank? || device_id.to_i.zero?
  end
  
  # number of seconds since last
  def seconds_since_last
    last.blank? ? 0 : (timestamp_server - last.timestamp_server)
  end
  
  # difference of time since last row for device_id
  def diff_since_last
    last.blank? ? [0,0,0,0] : distance_of_time_as_array( timestamp_server, last.timestamp_server)
  end
  
  # most recent timestamp with delay > threshhold
  def latest_timestamp_threshold_away( threshold = 1.week.ago)
    row = MgmtQuery.first( :conditions => ["device_id = ? AND timestamp_server < ?", device_id, DateTime.now - threshold], :order => "timestamp_server DESC")
    row.blank? ? "" : row.timestamp_server.to_s
  end
  
  # delay between timestamp_device <=> timestamp_server
  # we can also use ApplicationHelper.distance_of_time_as_array for more specific values
  def delay
    "%3d days %2d hours %2d minutes %2d seconds" % distance_of_time_as_array( timestamp_device, timestamp_server)
  end
  
  # time elapsed since last post (device_id picked from "self")
  # we can also use ApplicationHelper.distance_of_time_as_array for more specific values
  def time_span_since_last
    last.blank? ? "" : ("%3d days %2d hours %2d minutes %2d seconds" % diff_since_last)
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

    MgmtQuery.gw_offline_check(ethernet_system_timeout)    
    MgmtQuery.gw_offline_check(dialup_system_timeout) #this could be done less frequently potentially since timeout is greater
  end
  
  
  private
  # Check if gateway is offline for the first time and every subsequent time
  def MgmtQuery.gw_offline_check(access_mode_system_timeout)
    conds = MgmtQuery.access_mode_conds(access_mode_system_timeout) #conds to query for either ethernet or dialup devices
    gw_offline_timeout = access_mode_system_timeout.gateway_offline_timeout_sec
    gw_offline_timeout += access_mode_system_timeout.gateway_offline_offset_sec if !access_mode_system_timeout.gateway_offline_offset_sec.nil? 
    conds << "id in (select id from devices where serial_number like 'H2%')"
    conds << "updated_at < now() - interval '#{gw_offline_timeout} seconds'"
    conds << "reconnected_at is NOT NULL"
    dlqs = DeviceLatestQuery.find(:all, :conditions => conds.join(' and '))
    dlqs.each do |dlq|
      begin
        alert = GatewayOfflineAlert.new
        alert.device = Device.find(dlq.id)
        alert.save!
        dlq.reconnected_at = nil
        dlq.save
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
end
