class OscopeMsg < ActiveRecord::Base
  has_many :points
  belongs_to :oscope_start_msg
  belongs_to :oscope_stop_msg
    
  def self.new(params_array)
  	self.process_oscope_msg(params_array)
  end
  
  def self.process_oscope_msg(params_array)
  	debugger
  	o_msgs = params_array[:oscope_msgs]
      msgs = o_msgs[:oscope_msg]
      if msgs.class != Array
        msgs = [msgs]
      end
      msgs.each do |msg|
        timestamp = msg[:timestamp].to_time if msg[:timestamp]
        channel_num = msg[:channel_num].to_i if msg[:channel_num]
        user_id = msg[:user_id].to_i if msg[:user_id]
        o_msg = OscopeMsg.new
        o_msg.timestamp = timestamp
        o_msg.channel_num = channel_num
        o_msg.user_id = user_id
        o_msg.oscope_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id("'#{timestamp.to_s(:db)}'", user_id)
        o_msg.save!
        points = msg[:point]
        if points.class == Array
          points.each do |point|
            save_point(o_msg, point)
          end
        else
          save_point(o_msg, points)
        end
      end
  end
end
