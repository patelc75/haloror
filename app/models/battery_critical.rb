class BatteryCritical < DeviceAlert
  set_table_name "battery_criticals"
  
  def to_s
    "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end
