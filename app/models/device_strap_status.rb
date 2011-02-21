class DeviceStrapStatus < ActiveRecord::Base
  set_table_name "device_strap_status"
  
  named_scope :recent_on_top, :order => "updated_at DESC"
  named_scope :strapped_on, :conditions => { :is_fastened => 1 }
  named_scope :strapped_off, :conditions => ["is_fastened <> ?", 1]
  named_scope :updated_before, lambda {|arg| { :conditions => ["updated_at < (now() - interval '#{arg.to_i} seconds')"] }}
end