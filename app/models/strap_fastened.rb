class StrapFastened < DeviceAlert
  set_table_name "strap_fasteneds"
  def self.node_name
    return :strap_fastened
  end
  def to_s
    "Strap put back on at #{timestamp}"
  end
end
