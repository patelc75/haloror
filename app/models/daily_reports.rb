class DailyReports 
  def self.job_lost_data
    RAILS_DEFAULT_LOGGER.warn("DailyReports.job_lost_data running at #{Time.now}")
    lost_data = {}
    end_time = Time.now
    begin_time = 1.days.ago(end_time)
    users = User.find(:all)
    users.each do |user|
      user_id = user.id
      self.lost_data_scan(user_id)
      lost_data[user_id] = LostData.find(:all, :conditions => "user_id = #{user_id} AND end_time <= '#{end_time.to_s()}' AND begin_time >= '#{begin_time.to_s()}'", :order => "id desc")
    end
    return lost_data
  end
  def self.lost_data_scan(user_id)
    prev_timestamp = nil
    if last = VitalScan.find(:first, :conditions => "user_id = #{user_id}", :order => "timestamp desc")
      conds = " and timestamp > '#{last.timestamp.to_s()}'"
    else
      conds = ""
    end
    end_time = Time.now
    begin_time = nil
    begin_time = last.timestamp if last
    if begin_time
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, '#{begin_time.to_s()}', '#{end_time.to_s()})', '#{LOST_DATA_GAP} seconds')")
    else
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, null, '#{end_time.to_s()})', '#{LOST_DATA_GAP} seconds')")
    end
    lost_data = nil
    if begin_time
      lost_data = LostData.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id} AND end_time > '#{begin_time.to_s()}'")
    else
      lost_data = LostData.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id}")
    end
    prev_timestamp = lost_data.end_time if lost_data
          
    if (!last or prev_timestamp != last.timestamp) and !prev_timestamp.nil?
      last = VitalScan.new
      last.user_id = user_id
      last.timestamp = prev_timestamp
      last.save
    end
  end
end