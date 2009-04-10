class AddSystemTimeouts < ActiveRecord::Migration
  def self.up
    SystemTimeout.create(:mode => 'ethernet',
                        :gateway_offline_timeout_min => 20, 
                        :device_unavailable_timeout_min => 5,
                        :strap_off_timeout_min => 60 )
                        
    SystemTimeout.create(:mode => 'dialup',
                        :gateway_offline_timeout_min => 20, 
                        :device_unavailable_timeout_min => 5,
                        :strap_off_timeout_min => 60 )
  end

  def self.down
  end
end
