class BatteryPlugged < DeviceAlert
  set_table_name "battery_pluggeds"
  
  def to_s
    "Battery plugged"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.percentage = rand(60)
      model.time_remaining = rand(500)
    else
      model.percentage = 60
      model.time_remaining = 500
    end
    return model    
  end
end
