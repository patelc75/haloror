class BatteryUnplugged < DeviceAlert
  set_table_name "battery_unpluggeds"
  
  def to_s
    "Battery unplugged on #{timestamp}"
  end
end
