class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  
  def to_s
    "Strap put back on at #{timestamp}"
  end
end
