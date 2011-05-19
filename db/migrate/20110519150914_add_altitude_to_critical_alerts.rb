class AddAltitudeToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :altitude, :float
    add_column :panics, :altitude, :float
    add_column :gw_alarm_buttons, :altitude, :float
  end

  def self.down
    drop_column :falls, :altitude
    drop_column :panics, :altitude
    drop_column :gw_alarm_buttons, :altitude
  end
end