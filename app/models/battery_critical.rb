class BatteryCritical < DeviceAlert
  set_table_name "battery_criticals"
  
  def to_s
    "Battery critically low on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.percentage = rand(10)
      model.time_remaining = rand(100)
    else
      model.percentage = 10
      model.time_remaining = 100
    end
    return model    
  end
end
