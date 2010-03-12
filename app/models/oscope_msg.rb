class OscopeMsg < ActiveRecord::Base
  has_many :points
  belongs_to :oscope_start_msg
  belongs_to :oscope_stop_msg
  #
  # this is a special case when we get the data from device, not formatted to match table structure
  # we want to keep the processing logic within the model
  # usage:
  # => OscopeMsg.create( hash_from_internal_business_logic )
  # => OscopeMsg.create( oscope_msg_hash_with_point_array_from_device_xml )
  
  # required. do not remove.
  # just a dummy virtual attribute. we get this array when parsing XML from device
  attr_accessor :point
  
  # method to parse additional values while creating an AR row from XML received from the device
  #
  def before_validation
    #
    # we get points as an array named 'point' when Hash.form_xml is loaded using XML from device. phew! :)
    # :point virtual attribute is to avoid ActiveRecord erorrs.
    #  It just holds points in memory as array of hashes. another phew! :)
    # we parse :point array to build Point.new values for this instance of OscopeMsg
    # I hope it makes sense. If not, just go through the business logic for this section, again.
    unless point.blank?
      point.each {|p| points.build(p)}
      point = nil # make it blank. both valid? and save! will call it otherwise, and make double copies
    end
    #
    # we need to link an OscopeStartMsg if we can find one suitable
    oscope_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id(timestamp.to_s(:db), user_id) \
      if oscope_start_msg.blank?
    #
    # That is it. Let ActiveRecord do the magic from here. :)
  end

  def after_validation
    point = nil # we do not need it anymore, if it existed at all
  end

  # 2010-03-13, not required anymore. all handled by before_validation
  #
  # # method called from oscope_msgs_controller
  # #
  # def self.process_xml_hash(msg)
  #   oscope_msg = self.new(msg)
  #   # oscope_msg.parse_for_xml_hash
  #   oscope_msg.save! rescue nil # if oscope_msg.valid?
  # end

  # def self.process_xml_hash(msg)
  #   timestamp = msg["timestamp"].to_time if msg["timestamp"]
  #   channel_num = msg["channel_num"].to_i if msg["channel_num"]
  #   user_id = msg["user_id"].to_i if msg["user_id"]
  #   o_msg = OscopeMsg.new
  #   o_msg.timestamp = timestamp
  #   o_msg.channel_num = channel_num
  #   o_msg.user_id = user_id
  #   o_msg.oscope_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id("'#{timestamp.to_s(:db)}'", user_id)
  #   if (o_msg.save! if o_msg.valid?) # CHANGED: no points required if no oscopes?
  #     points = (msg["point"].class == Array) ? points : [points] # make it, if not Array
  #     points.each {|point| save_point(o_msg, point) unless point.blank?} unless points.blank?
  #   end
  # end
  # 
  # def self.save_point(o_msg, point)
  #   p = Point.new(point)
  #   p.oscope_msg = o_msg
  #   p.save! if p.valid?
  # end
end
