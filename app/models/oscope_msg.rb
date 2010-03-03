class OscopeMsg < BundleProcessor
  has_many :points
  belongs_to :oscope_start_msg
  belongs_to :oscope_stop_msg
  
  def self.process_xml_hash(msg)
    timestamp = msg["timestamp"].to_time if msg["timestamp"]
    channel_num = msg["channel_num"].to_i if msg["channel_num"]
    user_id = msg["user_id"].to_i if msg["user_id"]
    o_msg = OscopeMsg.new
    o_msg.timestamp = timestamp
    o_msg.channel_num = channel_num
    o_msg.user_id = user_id
    o_msg.oscope_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id("'#{timestamp.to_s(:db)}'", user_id)
    if (o_msg.save! if o_msg.valid?) # CHANGED: no points required if no oscopes?
      points = (msg["point"].class == Array) ? points : [points] # make it, if not Array
      points.each {|point| save_point(o_msg, point) unless point.blank?} unless points.blank?
    end
  end
  
  def self.save_point(o_msg, point)
    p = Point.new(point)
    p.oscope_msg = o_msg
    p.save! if p.valid?
  end
end
