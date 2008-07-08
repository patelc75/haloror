class BatteryCritical < DeviceAlert
  set_table_name "battery_criticals"
  
  def to_s
    "Battery critically low on #{timestamp}"
  end
end
