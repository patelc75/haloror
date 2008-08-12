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
      lost_data[user_id] = LostData.find(:all, :conditions => "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' AND begin_time >= '#{begin_time.to_s(:db)}'", :order => "id desc")
    end
    return begin_time, end_time, lost_data
  end
  def self.lost_data_scan(user_id)
    prev_timestamp = nil
    last = VitalScan.find(:first, :conditions => "user_id = #{user_id}", :order => "timestamp desc")
    
    end_time = Time.now
    begin_time = nil
    begin_time = last.timestamp if last
    if begin_time
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, '#{begin_time.to_s(:db)}', '#{end_time.to_s(:db)}', '#{LOST_DATA_GAP} seconds')")
    else
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, null, '#{end_time.to_s(:db)}', '#{LOST_DATA_GAP} seconds')")
    end
    lost_data = nil
    if begin_time
      lost_data = LostData.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id} AND end_time > '#{begin_time.to_s(:db)}'")
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
  
  def self.device_not_worn(user_id, begin_time=nil, end_time=Time.now)
    sql = "SELECT timestamp, heartrate FROM vitals WHERE user_id = #{user_id} AND timestamp <= '#{end_time.to_s}'"
    if !begin_time.nil?
      sql = sql + " AND timestamp >= '#{begin_time.to_s}'"
    end
    sql = sql + " ORDER BY timestamp ASC"
    times = []
    Vital.connection.select_all(sql).collect do |row|
      data = {}
      data[:timestamp] = row["timestamp"].to_time
      data[:heartrate] = row["heartrate"].to_i
      times << data
    end
    accumulated_time = nil
    previous_time = nil
    times.collect do |time|
      if time[:heartrate] == -1
        if previous_time == nil
          previous_time = time[:timestamp]
        else
          if accumulated_time.nil?
            accumulated_time = (time[:timestamp] - previous_time)
          else
            accumulated_time = accumulated_time + (time[:timestamp] - previous_time)
          end
            previous_time = time[:timestamp]
        end
      else
        previous_time = nil
      end
    end
    return accumulated_time
  end
  
  
end