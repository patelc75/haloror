class AddCriticalEventDelayToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :system_timeouts, :critical_event_delay, :integer
  end

  def self.down
  	remove_column :system_timeouts, :critical_event_delay
  end
end
