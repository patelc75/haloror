class DebugTask
  include ActionView::Helpers::DateHelper

  # https://redmine.corp.halomonitor.com/issues/3168
  #   fetch rows and mgmt_queries
  def self.mgmt_query( device_id = nil)
    if device_id.blank?
      puts "Please specify a device_id"
      []

    else
      MgmtQuery.find_all_by_device_id( device_id, :order => "timestamp_server DESC").collect do |row|
        "#{row.timestamp_device} | #{row.timestamp_server} | #{row.last.timestamp_server unless row.last.blank?} | #{row.time_span_since_last}"
      end.insert( 0, "Timestamp Device                | Timestamp Server                | Last Timestamp Server           | Delay server from last")
    end
  end

  def self.halo_debug_msgs( *device_ids)
    if device_ids.blank?
      puts "Please provide device_id or [device_id1, device_id2, ...]"
      []
      
    else
      Device.find_all_by_id( device_ids.flatten).collect do |device|
        user = device.users.first
        profile = user.profile unless user.blank?
        msg = user.halo_debug_msgs.all( :order => "timestamp DESC").select {|e| e.description && e.description.include?("Numbers in use") }.first unless user.blank?
        "#{(profile.first_name || '').ljust(25) unless profile.blank?} | #{(profile.last_name || '').ljust(25) unless profile.blank?} | #{msg.timestamp.to_s.ljust(25) unless msg.blank?} | #{msg.description unless msg.blank?}" unless msg.blank?
      end.insert( 0, ["First name".ljust(25), "Last name".ljust(25), "Timestamp".ljust(25), "Description"].join(" | "))

    end
  end

end
