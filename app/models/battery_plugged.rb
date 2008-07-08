class BatteryPlugged < DeviceAlert
  set_table_name "battery_pluggeds"
  
  def to_s
    "Battery plugged in on #{timestamp}"
  end
end
