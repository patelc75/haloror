class SystemTimeout < ActiveRecord::Base
  DEFAULTS = {
    "dialup" => {
      :battery_reminder_three_sec     => 14400,
      :battery_reminder_two_sec       => 7200,
      :critical_event_delay_sec       => 120,
      :device_unavailable_timeout_sec => 26700,
      :gateway_offline_offset_sec     => 4800,
      :gateway_offline_timeout_sec    => 21600,
      :group_id                       => Group.default.id,
      :mode                           => "dialup",
      :strap_off_timeout_sec          => 25200
    }, "ethernet" => {
      :battery_reminder_three_sec     => 14400,
      :battery_reminder_two_sec       => 7200,
      :critical_event_delay_sec       => 120,
      :device_unavailable_timeout_sec => 300,
      :gateway_offline_offset_sec     => 300,
      :gateway_offline_timeout_sec    => 1200,
      :group_id                       => Group.default.id,
      :mode                           => "ethernet",
      :strap_off_timeout_sec          => 3600
    }
  }
  belongs_to :group
  
  validates_presence_of :mode
  validates_presence_of :gateway_offline_timeout_sec
  validates_presence_of :device_unavailable_timeout_sec
  validates_presence_of :strap_off_timeout_sec
  
  # make sure the default set of data exist in this table
  # this will also ensure group named "default"
  def self.ensure_defaults( *name)
    standard = ( DEFAULTS.keys & name.collect(&:to_s) ) unless name.blank? # make sure we have valid modes only
    standard = DEFAULTS.keys if standard.blank? # assume default modes unless we get a match above
    #
    # for each identified or given mode
    standard.each do |kind|
      found = SystemTimeout.find_or_create_by_mode( DEFAULTS[ kind] ) # find or create by mode
      found.update_attributes( DEFAULTS[kind] ) unless found.blank? # update attributes (over write)
    end
    #
    # return the values based on the parameters requested or identified
    rows = all( :conditions => { :mode => standard }) # we need to return this to support Group.get_system_timeout
    (standard.size > 1) ? rows : rows.first
  end
  
  # verify the requested attribute is valid
  def self.valid_attribute?( attribute)
    self.new.attributes.keys.include? attribute.to_s
  end
  
end

# Fri Aug 13 02:25:21 IST 2010
# default values as seen on dfw-web2
#
# >> y SystemTimeout.all
# --- 
# - !ruby/object:SystemTimeout 
#   attributes: 
#     updated_at: 2010-04-20 18:35:24.541203
#     battery_reminder_three_sec: "14400"
#     battery_reminder_two_sec: "7200"
#     mode: dialup
#     strap_off_timeout_sec: "25200"
#     device_unavailable_timeout_sec: "26700"
#     id: "1"
#     gateway_offline_offset_sec: "4800"
#     critical_event_delay_sec: "120"
#     created_at: 2009-05-19 23:53:03.373771
#     gateway_offline_timeout_sec: "21600"
#   attributes_cache: {}
# 
# - !ruby/object:SystemTimeout 
#   attributes: 
#     updated_at: 2010-04-20 18:35:34.21012
#     battery_reminder_three_sec: "14400"
#     battery_reminder_two_sec: "7200"
#     mode: ethernet
#     strap_off_timeout_sec: "3600"
#     device_unavailable_timeout_sec: "300"
#     id: "2"
#     gateway_offline_offset_sec: "300"
#     critical_event_delay_sec: "120"
#     created_at: 2009-05-19 23:53:03.38919
#     gateway_offline_timeout_sec: "1200"
#   attributes_cache: {}
