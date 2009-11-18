class AddCriticalEventDelayToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :system_timeouts, :critical_event_delay_sec, :integer
  end

  def self.down
  	remove_column :system_timeouts, :critical_event_delay_sec
  end
end
