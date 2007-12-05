class SkinTemp < ActiveRecord::Base
  set_table_name "skin_temps"
  belongs_to :user
  
  def self.get_average(condition)
	SkinTemp.average(:skin_temp, :conditions => condition)
  end
end
