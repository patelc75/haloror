class BatteryCritical < DeviceAlert
  set_table_name "battery_criticals"
  
  def self.node_name
    return :battery_critical
  end
  
  def to_s
    "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end
