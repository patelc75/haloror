class SystemTimeout < ActiveRecord::Base
  validates_presence_of :mode
  validates_presence_of :gateway_offline_timeout_sec
  validates_presence_of :device_unavailable_timeout_sec
  validates_presence_of :strap_off_timeout_sec
  belongs_to :group
  
 # named_scope :default_timeout, lambda {|mode| {:conditions => ["mode = ? and groups.name = ?",mode,'default'],:include => :group}}
  
  def self.default_timeout(mode)
     SystemTimeout.find_by_mode(mode,:conditions => ['groups.name = ?','default'],:include => :group)
  end
  
end