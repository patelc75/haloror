class BatteryChargeComplete < DeviceAlert
  set_table_name "battery_charge_completes"
  
  def to_s
    "Battery fully charged on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.percentage = rand(100)
      model.time_remaining = rand(1000)
    else
      model.percentage = 100
      model.time_remaining = 1000
    end
    return model    
  end
end