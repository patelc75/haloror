class StrapRemoved < DeviceAlert
  set_table_name "strap_removeds"
  
  def to_s
    "Strap removed"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
