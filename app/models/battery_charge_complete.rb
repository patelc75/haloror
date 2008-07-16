class BatteryChargeComplete < DeviceAlert
  set_table_name "battery_charge_completes"
  
  def to_s
    "Battery fully charged on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end