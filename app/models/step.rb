class Step < Vital
  set_table_name "steps"
  belongs_to :user
  
  def self.get_average(condition)
	Step.average(:heartrate, :conditions => condition)
  end
end
