class DataTransformer 
  def self.transform_bad_timestamps(user_id, beginning_id, ending_id, begin_timestamp)
    timestamp = begin_timestamp.to_time
    prev_timestamp = nil
    count = beginning_id
    while(count < (ending_id + 1))
      vital = Vital.find(:first, :conditions => "user_id = #{82} AND id = #{count}")
      if vital && vital.timestamp != prev_timestamp
        new_vital = Vital.create(:heartrate => vital.heartrate, :hrv => vital.hrv,
                                :activity => vital.activity, :orientation => vital.orientation,
                                :user_id => vital.user_id, :timestamp => timestamp)
        new_vital.save!
        prev_timestamp = timestamp
        timestamp = timestamp + 15.seconds
      end      
      count += 1
    end
  end
end