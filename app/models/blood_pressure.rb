class BloodPressure < Vital
	belongs_to :user
	set_table_name "blood_pressures"
end
