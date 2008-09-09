class OscopeStopMsg < ActiveRecord::Base
  has_many :oscope_msgs
  
  after_save :reference_oscope_msgs
  
  private
  
  def reference_oscope_msgs
    o_msgs = OscopeMsg.find(:all, :conditions => "timestamp = '#{timestamp.to_s(:db)}' AND user_id = #{user_id}")
    if o_msgs
      o_msgs.each do |o_msg|
        o_msg.oscope_stop_msg = self
        o_msg.save!
      end
    end
  end
end