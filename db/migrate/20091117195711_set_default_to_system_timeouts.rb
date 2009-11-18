class SetDefaultToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	#change_column :system_timeouts,:critical_event_delay,:default => '120 seconds'
  	
  	SystemTimeout.find(:all).each do |system_timeout|
  		if system_timeout.critical_event_delay.nil? or system_timeout.critical_event_delay == ""
  			system_timeout.update_attributes(:critical_event_delay => 120)
  		end
  	end
  	
  end

  def self.down
  end
end
