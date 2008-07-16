class BatteryPlugged < DeviceAlert
  set_table_name "battery_pluggeds"
  
  def to_s
    "Battery plugged in on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end
