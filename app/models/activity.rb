class Activity < Vital
  set_table_name "activities"
  belongs_to :user
  
  def self.get_average(condition)
	Activity.average(:activity, :conditions => condition)
  end
  
  def self.format_average(average)
	round_to(average, 1)
  end
  
  def self.get_latest(vital)
	@series_data  = vital.map {|a| a.activity }
  end
end