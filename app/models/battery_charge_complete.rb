class BatteryChargeComplete < DeviceAlert
  set_table_name "battery_charge_completes"
  
  def self.node_name
    return :battery_charge_complete
  end
  
  def to_s
    "Battery fully charged on #{timestamp}"
  end
end
