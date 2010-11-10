class WeightScale < Vital
  belongs_to :user
  set_table_name "weight_scales"

  # DRYed code from view
  #
  def user_summary
    user.blank? ? '' : ["#{user.name} (#{user.id})", (user.profile.blank? ? nil : "all times are in #{user.profile.time_zone} timezone")].compact.join(' - ')
  end
  
  def weight_string
    "#{(weight.to_f/1000.0).round(1)} #{weight_unit}"
  end
  
  def battery_string
    "#{(battery.to_f/1000.0).round(1)}"
  end
end
