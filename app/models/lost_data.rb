class LostData < ActiveRecord::Base

  def self.rows_by_user(user_id, begin_time, end_time)
    LostData.find(:all, :conditions => "user_id = #{user_id} AND end_time <= '#{end_time.to_s(:db)}' AND begin_time >= '#{begin_time.to_s(:db)}'", :order => "id desc")  
  end
    
  def self.user_ids_with_lost_data(start_time, stop_time)
    result = LostData.find(:all, :conditions => "begin_time > '#{start_time}' AND end_time < '#{stop_time}'")
    user_ids = []
    result.each do |ld|
      user_ids << ld.user_id
    end
    return user_ids
  end
end
