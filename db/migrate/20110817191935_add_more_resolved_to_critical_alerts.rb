class AddMoreResolvedToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :resolved_reason, :string
    add_column :panics, :resolved_reason, :string
    add_column :gw_alarm_buttons, :resolved_reason, :string
    add_column :falls, :resolved_timestamp, :datetime
    add_column :panics, :resolved_timestamp, :datetime
    add_column :gw_alarm_buttons, :resolved_timestamp, :datetime        
  end

  def self.down
    drop_column :falls, :resolved_reason
    drop_column :panics, :resolved_reason    
    drop_column :gw_alarm_buttons, :resolved_reason     
    drop_column :falls, :resolved_timestamp
    drop_column :panics, :resolved_timestamp    
    drop_column :gw_alarm_buttons, :resolved_timestamp    
  end
end
