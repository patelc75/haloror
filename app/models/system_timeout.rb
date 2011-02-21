class SystemTimeout < ActiveRecord::Base
  validates_presence_of :mode
  validates_presence_of :gateway_offline_timeout_sec
  validates_presence_of :device_unavailable_timeout_sec
  validates_presence_of :strap_off_timeout_sec
  
  # =================
  # = class methods =
  # =================
  
  class << self
    ['dialup', 'ethernet'].each do |_mode|
      define_method "#{_mode}".to_sym do
        first( :conditions => { :mode => _mode })
      end
    end
  end

end