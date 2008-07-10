class BatteryCritical < DeviceAlert
  set_table_name "battery_criticals"
  
  def self.node_name
    return :battery_critical
  end
  
  def to_s
    "Battery critically low on #{timestamp}"
  end
end
