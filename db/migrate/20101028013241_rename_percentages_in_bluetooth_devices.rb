class RenamePercentagesInBluetoothDevices < ActiveRecord::Migration
  def self.up
    rename_column(:weight_scales, :percentage, :battery_percentage)
    rename_column(:blood_pressures, :percentage, :battery_percentage)    
  end

  def self.down
    rename_column(:weight_scales, :battery_percentage, :percentage)
    rename_column(:blood_pressures, :battery_percentage, :percentage)
  end
end
