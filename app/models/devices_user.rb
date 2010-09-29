class DevicesUser < ActiveRecord::Base
  belongs_to :device
  belongs_to :user
  
  # # WARNING: THIS DOES NOT WORK YET! similar dynamic method defined in Device
  # #
  # # Usage:
  # #   gateways_with_status "Installed"
  # { :gateways => "H2", :chest_straps => "H1", :belt_clips => "H5", :kits => "H4" }.each do |key, value|
  #   #
  #   # scopes
  #   named_scope "#{key}_with_status", lambda {|*args| {
  #     :joins => "LEFT JOIN devices ON devices_users.device_id == devices.id, LEFT JOIN users ON devices_users.user_id == users.id",
  #     :conditions => ["devices.serial_number LIKE ? AND users.status = ?", "#{value}%", args.flatten.first.to_s.strip ]
  #     }}
  # end
end