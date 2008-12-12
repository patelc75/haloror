class DataTransformer 
  def self.transform_bad_timestamps(user_id, beginning_id, ending_id, begin_timestamp)
    timestamp = begin_timestamp.to_time
    prev_timestamp = nil
    count = beginning_id
    while(count < (ending_id + 1))
      vital = Vital.find(:first, :conditions => "user_id = #{user_id} AND id = #{count}")
      if vital && vital.timestamp != prev_timestamp
        new_vital = Vital.create(:heartrate => vital.heartrate, :hrv => vital.hrv,
                                :activity => vital.activity, :orientation => vital.orientation,
                                :user_id => vital.user_id, :timestamp => timestamp)
        new_vital.save!
        prev_timestamp = vital.timestamp
        timestamp = timestamp + 15.seconds
      end      
      count += 1
    end
  end
  
  def self.find_vitals_timestamps(user_id, beginning_id, ending_id, begin_timestamp)
    timestamp = begin_timestamp.to_time
    prev_timestamp = nil
    count = beginning_id
    while(count < (ending_id + 1))
      vital = Vital.find(:first, :conditions => "user_id = #{user_id} AND id = #{count}")
      if prev_timestamp == nil
        prev_timestamp = vital.timestamp
      end
      if vital && (prev_timestamp - vital.timestamp) < 15.seconds
        puts vital.inspect
        prev_timestamp = vital.timestamp
      end      
      count += 1
    end
  end
  
  def self.transform_add_timestamps(user_id, beginning_id, ending_id, seconds)
    prev_timestamp = nil
    count = beginning_id
    while(count < (ending_id + 1))
      vital = Vital.find(:first, :conditions => "user_id = #{user_id} AND id = #{count}")
      if vital
        timestamp = vital.timestamp + seconds.seconds
        new_vital = Vital.create(:heartrate => vital.heartrate, :hrv => vital.hrv,
                                :activity => vital.activity, :orientation => vital.orientation,
                                :user_id => vital.user_id, :timestamp => timestamp)
        new_vital.save!
      end
      count += 1
    end
  end
end