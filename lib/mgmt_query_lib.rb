class MgmtQueryLib
  include ActionView::Helpers::DateHelper

  def self.debug( device_id)
    puts "Timestamp Device                | Timestamp Server                | Last Timestamp Server           | Delay server from last"
    MgmtQuery.find_all_by_device_id( device_id, :order => "timestamp_server DESC").each do |mgmt|
      last = MgmtQuery.find_by_id( mgmt.id-1)
      puts "#{mgmt.timestamp_device} | #{mgmt.id} #{mgmt.timestamp_server} | #{last.id unless last.blank?} #{last.timestamp_server unless last.blank?} | #{mgmt.time_span_since_last}"
    end
  end
end
