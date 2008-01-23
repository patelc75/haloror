class Orientation < ActiveRecord::Base
  set_table_name "orientations"
  belongs_to :user
  
  def self.get_average(condition)
	Orientation.average(:heartrate, :conditions => condition)
  end
end
