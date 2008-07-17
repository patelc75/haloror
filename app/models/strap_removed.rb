class StrapRemoved < DeviceAlert
  set_table_name "strap_removeds"
  
  def to_s
    "Strap taken off on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
