class AccessMode < DeviceAlert
  set_table_name "access_modes"

  belongs_to :device
  
  def to_s
    "Access mode set to #{mode} on #{UtilityHelper.format_datetime_readable(timestamp, nil)}"
  end
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
end

#  create_table "access_modes", :force => true do |t|
#    t.integer  "device_id"
#    t.string   "mode"
#    t.datetime "timestamp"
# end