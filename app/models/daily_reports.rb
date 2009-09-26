class DailyReports 
  
  #create a hash of arrays (an array of lost_datas for each user)
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
    #fetch the timestamp on when the lost_data_scan left off (from the vital_scans table)
    prev_timestamp = nil
    last = VitalScan.find(:first, :conditions => "user_id = #{user_id}", :order => "timestamp desc")
    
    #populate more lost_data rows into the lost_data table, starting from the timestamp it left off
    end_time = Time.now
    begin_time = nil
    begin_time = last.timestamp if last
    if begin_time
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, '#{begin_time.to_s(:db)}', '#{end_time.to_s(:db)}', '#{LOST_DATA_GAP} seconds')")
    else
      LostData.connection.select_all("select * from lost_data_function(#{user_id}, null, '#{end_time.to_s(:db)}', '#{LOST_DATA_GAP} seconds')")
    end
    lost_data = nil
    
    #find the timestamp of the most recent row in the lost_data table
    if begin_time
      lost_data = LostData.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id} AND end_time > '#{begin_time.to_s(:db)}'")
    else
      lost_data = LostData.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id}")
    end
    prev_timestamp = lost_data.end_time if lost_data
    
    #mark the spot where it last left off in the vital_scans table  
    if(!prev_timestamp.nil? and (!last or prev_timestamp > last.timestamp))
      last = VitalScan.new
      last.user_id = user_id
      last.timestamp = prev_timestamp
      last.save
    end
  end
  
    #create a hash of arrays (an array of lost_datas for each user)
  def self.job_device_not_warn
    RAILS_DEFAULT_LOGGER.warn("DailyReports.job_device_not_warn running at #{Time.now}")
    strap_not_worn = {}
    end_time = Time.now
    begin_time = 1.days.ago(end_time)
    users = User.find(:all)
    users.each do |user|
      user_id = user.id
      self.device_not_worn_scan(user_id)
      strap_not_worn[user_id] = StrapNotWorn.find(:all, :conditions => "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' AND begin_time >= '#{begin_time.to_s(:db)}'", :order => "id desc")
    end
    return begin_time, end_time, strap_not_worn
  end
  
  def self.device_not_worn_scan(user_id)
    #fetch the timestamp on when the device_not_worn_scan left off (from the strap_not_worn_scans table)
    prev_timestamp = nil
    last = StrapNotWornScan.find(:first, :conditions => "user_id = #{user_id}", :order => "timestamp desc")
    
    #populate more lost_data rows into the lost_data table, starting from the timestamp it left off
    end_time = Time.now
    begin_time = nil
    begin_time = last.timestamp if last
    if begin_time
      StrapNotWorn.connection.select_all("select * from device_not_worn_function(#{user_id}, '#{begin_time.to_s(:db)}', '#{end_time.to_s(:db)}')")
    else
      StrapNotWorn.connection.select_all("select * from device_not_worn_function(#{user_id}, null, '#{end_time.to_s(:db)}')")
    end
    strap_not_worn = nil
    
    #find the timestamp of the most recent row in the lost_data table
    if begin_time
      strap_not_worn = StrapNotWorn.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id} AND end_time > '#{begin_time.to_s(:db)}'")
    else
      strap_not_worn = StrapNotWorn.find(:first, :order => "end_time desc", :conditions => "user_id = #{user_id}")
    end
    prev_timestamp = strap_not_worn.end_time if strap_not_worn
    
    #mark the spot where it last left off in the vital_scans table  
    if(!prev_timestamp.nil? and (!last or prev_timestamp > last.timestamp))
      last = StrapNotWornScan.new
      last.user_id = user_id
      last.timestamp = prev_timestamp
      last.save
    end
  end
  
  def self.device_not_worn(user_id, begin_time=nil, end_time=Time.now)
    sql = "SELECT begin_time, end_time FROM strap_not_worns WHERE user_id = #{user_id} AND end_time <= '#{end_time.to_s}'"
    if !begin_time.nil?
      sql = sql + " AND begin_time >= '#{begin_time.to_s}'"
    end
    accumulated_time = nil
    previous_time = nil
    StrapNotWorn.connection.select_all(sql).collect do |row|
    	accumulated_time = accumulated_time + (row['end_time'].to_time - row['begin_time'].to_time) 
    end
    return accumulated_time
  end
  
  def self.device_not_worn_halousers(begin_time=nil, end_time=Time.now) 
    RAILS_DEFAULT_LOGGER.warn("DailyReports.device_not_worn_halousers running at #{Time.now}")
    RAILS_DEFAULT_LOGGER.debug(begin_time.to_s + " to " + end_time.to_s)
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
        RAILS_DEFAULT_LOGGER.debug("#{halouser.id}) " + "#{halouser.name}" + ": \t" + "#{sum_device_not_worn}" + "\t" + "#{sum_lost_data}" + "\t" + "#{total}")
      end       
    end
    return halousers, total_lost_data, total_not_worn
  end
  
  #accumulate the total time for an array of lost_data
  def self.lost_data_sum(lost_data)
    accumulated_time = 0
    lost_data.each do |ld|
      accumulated_time = accumulated_time + (ld.end_time - ld.begin_time) #result is in seconds (eg. 34.0)
    end
    return accumulated_time
  end
  
  #accumulate the total time for an array of device_not_worn
  def self.strap_not_worn_sum(strap_not_worn)
    accumulated_time = 0
    strap_not_worn.each do |ld|
      accumulated_time = accumulated_time + (ld.end_time - ld.begin_time) #result is in seconds (eg. 34.0)
    end
    return accumulated_time
  end
  
  #don't really understand this method, look at it again later
  def self.lost_data_by_user_boundaries(user_id, begin_time, end_time)
    accumulated = 0.0
    
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
  
  #find all lost_data for a user within a certain date range, NOT performing a lost_data_scan_first
  def self.fast_lost_data_by_user(user_id, begin_time=nil, end_time=Time.now)    
    conds = "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' "
    if(begin_time != nil)
      conds = conds + "AND begin_time >= '#{begin_time.to_s(:db)}'"
    end
    #end_time >
    return LostData.find(:all, :conditions => conds, :order => "id desc")
  end
  
  #find all lost_data for a user within a certain date range, NOT performing a lost_data_scan_first
  def self.fast_device_not_worn_by_user(user_id, begin_time=nil, end_time=Time.now)    
    conds = "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' "
    if(begin_time != nil)
      conds = conds + "AND begin_time >= '#{begin_time.to_s(:db)}'"
    end
    #end_time >
    return StrapNotWorn.find(:all, :conditions => conds, :order => "id desc")
  end
  
  #find all lost_data for a user within a certain date range, performing a lost_data_scan_first
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