class PopulateSystemTimeouts < ActiveRecord::Migration
  def self.up
  	SystemTimeout.create(:mode => "dialup", :gateway_offline_timeout_sec => "21600", :device_unavailable_timeout_sec => "21900", :strap_off_timeout_sec => "25200")
	SystemTimeout.create(:mode => "ethernet", :gateway_offline_timeout_sec => "1200", :device_unavailable_timeout_sec => "300", :strap_off_timeout_sec => "3600")
  end

  def self.down
  	p = Person.find(:first, :conditions => "mode = dialup")
  	SystemTimeout.delete(p.id)
  	p = Person.find(:first, :conditions => "mode = ethernet")
  	SystemTimeout.delete(p.id)
  end
end
