class MgmtQueryLib
  include ActionView::Helpers::DateHelper
  
  def self.sql_like_output( device_id)
    MgmtQuery.find_all_by_device_id( device_id).collect do |row|
      timespan = row.time_span_since_last
      "#{row.timestamp_device} | #{row.timestamp_server} | #{timespan}"
      # puts "#{row.timestamp_device.to_s(:rfc822).ljust(25)} | #{row.timestamp_server.to_s(:rfc822).ljust(25)} | #{row.delay.to_s.ljust(25)} | #{timespan[0].ljust(50)} | #{timespan[1].ljust(50)}"
    end.insert(0, ["Timestamp Device                | Timestamp Server                | Delay server from last"])
  end
end
