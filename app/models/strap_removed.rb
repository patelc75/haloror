class StrapRemoved < DeviceAlert
  set_table_name "strap_removeds"
  def self.node_name
    return :strap_removed
  end
  def to_s
    "Strap taken off on #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end
