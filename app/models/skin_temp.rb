class SkinTemp < Vital
  set_table_name "skin_temps"
  
  def self.get_average(condition)
    SkinTemp.average(:skin_temp, :conditions => condition)
  end
  
  def self.format_average(average)
    round_to(average, 1)
  end
  
  def self.get_latest(vital)
    @series_data  = vital.map {|a| a.skin_temp }
  end
end
