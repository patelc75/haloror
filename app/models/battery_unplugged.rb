class BatteryUnplugged < DeviceAlert
  set_table_name "battery_unpluggeds"
  
  def self.node_name
    return :battery_unplugged
  end
  
  def to_s
    "Battery unplugged on #{timestamp}"
  end
end
