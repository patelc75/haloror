class BloodPressure < Vital
	belongs_to :user
	set_table_name "blood_pressures"

  def user_summary
    user.blank? ? '' : ["#{user.name} (#{user.id})", (user.profile.blank? ? nil : "all times are in #{user.profile.time_zone} timezone")].compact.join(' - ')
  end
end
