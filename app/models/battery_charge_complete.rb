class BatteryChargeComplete < DeviceAlert
  set_table_name "battery_charge_completes"
  
  def to_s
    "Battery fully charged on #{timestamp}"
  end
end
