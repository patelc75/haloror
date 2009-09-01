class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  
  def to_s
    "Strap fastened on at #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
