class AddResolvedToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :resolved, :string
    add_column :panics, :resolved, :string
    add_column :gw_alarm_buttons, :resolved, :string    
  end

  def self.down
    drop_column :falls, :resolved
    drop_column :panics, :resolved    
    drop_column :gw_alarm_buttons, :resolved    
  end
end
                                                                                    