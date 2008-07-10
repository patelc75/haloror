class BatteryPlugged < DeviceAlert
  set_table_name "battery_pluggeds"
  
  def self.node_name
    return :battery_plugged
  end
  
  def to_s
    "Battery plugged in on #{timestamp}"
  end
end
