class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  
  def to_s
    "Strap put back on at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
