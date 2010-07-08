class MgmtQueryLib
  include ActionView::Helpers::DateHelper

  def self.debug( device_id)
    puts "Timestamp Device                | Timestamp Server                | Last Timestamp Server           | Delay server from last"
    MgmtQuery.find_all_by_device_id( device_id, :order => "timestamp_server DESC").each do |row|
      puts "#{row.timestamp_device} | #{row.timestamp_server} | #{row.last.timestamp_server unless row.last.blank?} | #{row.time_span_since_last}"
    end
  end
end
