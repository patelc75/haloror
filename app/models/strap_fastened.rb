class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  
  def to_s
    "Strap put back on at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
end
