class StrapRemoved < DeviceAlert
  set_table_name "strap_removeds"
  
  named_scope :within_time_span, lambda {|arg| { :conditions => ["timestamp >= ?", arg] }}
  
  def to_s
    "Strap removed for #{user.name} (#{user.id})"
  end
  
  # 
  #  Tue Feb 22 04:47:43 IST 2011, ramonrails
  #   * Why is this required? This seems to be same as StrapRemoved.new
  # def self.new_initialize(random=false)
  #   model = self.new
  #   return model    
  # end
end
