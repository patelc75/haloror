class CriticalDeviceAlert < DeviceAlert
  def priority
    return IMMEDIATE
  end
  
  def before_create 
    #debugger
    self.timestamp_server = Time.now.utc
    self.call_center_pending = false
    groups = user.is_halouser_for_what
    groups.each do |group|
      if !group.nil? and group.sales_type == "call_center"
        self.call_center_pending = true
      end
    end
    Event.create_event(self.user_id, self.class.to_s, self.id, self.timestamp)
  end
  
  #for rspec
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
