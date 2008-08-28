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
    
   if(!prev_timestamp.nil? and (!last or prev_timestamp > last.timestamp))
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
    accumulated_time = nil
    previous_time = nil
    Vital.connection.select_all(sql).collect do |row|
      if row[:heartrate].to_i == -1
        if previous_time == nil
          previous_time = row[:timestamp].to_time
        else
          if accumulated_time.nil?
            accumulated_time = (row[:timestamp].to_time - previous_time)
          else
            accumulated_time = accumulated_time + (row[:timestamp].to_time - previous_time)
          end
          previous_time = row[:timestamp].to_time
        end
      else
        previous_time = nil
      end
    end
    return accumulated_time
  end
  
  def self.device_not_worn_halousers(begin_time=nil, end_time=Time.now) 
    RAILS_DEFAULT_LOGGER.warn("DailyReports.device_not_worn_halousers running at #{Time.now}")
    puts begin_time.to_s + " to " + end_time.to_s
    halousers = User.halousers()
    total_not_worn = 0
    total_lost_data = 0
    if !halousers.blank?
      halousers.each do |halouser|
        lost_data = self.lost_data_by_user(halouser.id, begin_time, end_time)
        sum_lost_data = self.lost_data_sum(lost_data) + self.lost_data_by_user_boundaries(halouser.id, begin_time, end_time)
        sum_device_not_worn = DailyReports.device_not_worn(halouser.id, begin_time, end_time  )
        total = 0
        if !sum_device_not_worn.nil?
          total = total + sum_device_not_worn
          total_not_worn = total_not_worn + sum_device_not_worn
        end
        if !sum_lost_data.nil?
          total = total + sum_lost_data
          total_lost_data = total_lost_data + sum_lost_data
        end
        
        halouser[:seconds_not_worn] = sum_device_not_worn.nil? ? 0 : sum_device_not_worn
        halouser[:seconds_lost_data] = sum_lost_data
        halouser[:total] = total
        puts "#{halouser.id}) " + "#{halouser.name}" + ": \t" + "#{sum_device_not_worn}" + "\t" + "#{sum_lost_data}" + "\t" + "#{total}"
      end       
    end
    return halousers, total_lost_data, total_not_worn
  end
  
  def self.lost_data_sum(lost_data)
    accumulated_time = 0
    lost_data.each do |ld|
      accumulated_time = accumulated_time + (ld.end_time - ld.begin_time)
    end
    return accumulated_time
  end
  
  def self.lost_data_by_user_boundaries(user_id, begin_time, end_time)
    accumulated = 0
    if !begin_time.nil?
      conds = "user_id = #{user_id} AND end_time >= '#{begin_time.to_s(:db)}' AND begin_time <= '#{begin_time.to_s(:db)}'"
      boundary_lost_data = LostData.find(:first, :conditions => conds, :order => 'id desc')
      if boundary_lost_data
        accumulated = accumulated + (boundary_lost_data.end_time - begin_time)
      end
    end
    conds2 = "user_id = #{user_id} AND end_time >= '#{end_time.to_s(:db)}' AND begin_time <= '#{end_time.to_s(:db)}'"
    boundary2_lost_data = LostData.find(:first, :conditions => conds2, :order => 'id desc')
    if boundary2_lost_data 
      accumulated = accumulated + (end_time - boundary2_lost_data.begin_time)
    end
    return accumulated
  end
  
  def self.lost_data_by_user(user_id, begin_time=nil, end_time=Time.now)    
    self.lost_data_scan(user_id)
    conds = "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' "
    if(begin_time != nil)
      conds = conds + "AND begin_time >= '#{begin_time.to_s(:db)}'"
    end
    #end_time >
    return LostData.find(:all, :conditions => conds, :order => "id desc")
  end
  
  def self.successful_user_logins(begin_time=nil, end_time=Time.now)
    RAILS_DEFAULT_LOGGER.warn("DailyReports.successful_user_logins running at #{Time.now}")
    users = User.find(:all, :order => 'id')
    users.each do |user|
      conds = "status = 'successful' AND user_id = #{user.id} AND created_at <= '#{end_time.to_s(:db)}' "
      if !begin_time.nil?
        conds = conds + " AND created_at >= '#{begin_time.to_s(:db)}'"
      end
      logins = AccessLog.count(:all, :conditions => conds)
      user[:logins] = logins
    end
    return users
  end
end