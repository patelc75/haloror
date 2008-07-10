class Battery < Vital
  set_table_name "batteries"
  belongs_to :device
  
  def self.node_name
    return :battery
  end
  
  def self.get_average(condition)
    Battery.average(:percentage, :conditions => condition)
  end
end