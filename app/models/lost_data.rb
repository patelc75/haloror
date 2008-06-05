class LostData < ActiveRecord::Base
  
  def self.user_ids_with_lost_data(start_time, stop_time)
    result = LostData.find(:all, :conditions => "begin_time > '#{start_time}' AND end_time < '#{stop_time}'")
    user_ids = []
    result.each do |ld|
      user_ids << ld.user_id
    end
    return user_ids
  end
end
