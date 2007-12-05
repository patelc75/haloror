class Activity < Vital
  set_table_name "activities"
  belongs_to :user
  
  def self.get_average(condition)
	Activity.average(:heartrate, :conditions => condition)
  end
end
