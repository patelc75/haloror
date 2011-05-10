class AddLatLongToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :lat, :float
    add_column :falls, :long, :float
    add_column :panics, :lat, :float
    add_column :panics, :long, :float
    add_column :gw_alarm_buttons, :lat, :float
    add_column :gw_alarm_buttons, :long, :float            
  end

  def self.down
    drop_column :falls, :lat
    drop_column :falls, :long
    drop_column :panics, :lat
    drop_column :panics, :long
    drop_column :gw_alarm_buttons, :lat
    drop_column :gw_alarm_buttons, :long
  end
end

