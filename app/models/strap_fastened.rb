class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"

  # trigger
  # we just need it for this event. Not device_alert.rb super class
  def after_save
    if (user = User.find(user_id))
      user.last_strap_fastened_id = id
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
    end
  end
  
  def to_s
    "Strap fastened on at #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end
