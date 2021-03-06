class BatteryUnplugged < DeviceAlert
  set_table_name "battery_unpluggeds"
  
  def to_s
    "Battery unplugged for #{user.name} (#{user.id})"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.percentage = rand(50)
      model.time_remaining = rand(500)
    else
      model.percentage = 50
      model.time_remaining = 500
    end
    return model    
  end
end
