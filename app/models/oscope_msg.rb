class OscopeMsg < ActiveRecord::Base
  has_many :points
  belongs_to :oscope_start_msg
  belongs_to :oscope_stop_msg
  
  #override new so it will accept parse through multiple points in an oscope_msg node  
  def self.new(oscope_msg=nil)
    if(!oscope_msg.nil?)
  	  self.process_oscope_msg(oscope_msg)
  	  return nil
	  else
	    super
  	end
  end
  
  #initialize will need to be overriden since new() was overriden
  def self.initialize(oscope_msg=nil)
    if(oscope_msg.nil?)
      super
    else
      self.new(oscope_msg)
    end
  end
  
  def self.process_oscope_msg(msg)
    timestamp = msg["timestamp"].to_time if msg["timestamp"]
    channel_num = msg["channel_num"].to_i if msg["channel_num"]
    user_id = msg["user_id"].to_i if msg["user_id"]
    o_msg = OscopeMsg.new
    o_msg.timestamp = timestamp
    o_msg.channel_num = channel_num
    o_msg.user_id = user_id
    o_msg.oscope_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id("'#{timestamp.to_s(:db)}'", user_id)
    o_msg.save!
    points = msg["point"]
    if points.class == Array
      points.each do |point|
        save_point(o_msg, point)
      end
    else
      save_point(o_msg, points)
    end
  end
  
  def self.save_point(o_msg, point)
    p = Point.new(point)
    p.oscope_msg = o_msg
    p.save!
  end
end
