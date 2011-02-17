class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  
  named_scope :within_time_span, lambda {|arg| { :conditions => ["timestamp >= ?", arg] }}

  #
  #  Wed Dec  8 00:52:21 IST 2010, ramonrails
  #   * switched off for 1.6.0 www issues
  # # trigger
  # # we just need it for this event. Not device_alert.rb super class
  # def after_save
  #   if (user = User.find(user_id))
  #     user.last_strap_fastened_id = id
  #     user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
  #   end
  # end
  
  def to_s
    "Strap fastened for #{user.name} (#{user.id})"
  end
  
  # 
  #  Fri Feb 18 03:37:01 IST 2011, ramonrails
  #   * WARNING: What is this? initialize itself from its own model?
  #   * StrapFastened.new could have done the same thing
  # def self.new_initialize(random=false)
  #   model = self.new
  #   return model    
  # end
end
