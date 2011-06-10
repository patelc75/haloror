class Fall < CriticalDeviceAlert
  set_table_name("falls")

  def to_s
    "#{user.name} fell at #{UtilityHelper.format_datetime(timestamp, user)}"
  end
  
  def to_s_short
   "FALL #{user.name}" 
  end

  def email_body
    "Hello,\nWe detected that #{to_s}" +
      "\n\nA Halo operator will be handling the event immediately.\n\n" +
      "- Halo Staff"
  end

  # check if the associated user profile has an account_number mentioned in it
  # this logic is used to decide critical_alert.timestamp_call_center value
  #
  def call_center_number_valid?
    !user.call_center_account.blank? #rescue false # fetch the call center account number, or, false
  end

  def can_map?
    self.respond_to?(:lat) && self.respond_to?(:long) # && !lat.blank? && !long.blank?
  end

  def location
    _location = [lat, long].compact.join(',') if can_map?
    if _location.blank?
      _location = (user.blank? ? 'U.S.A.' : (user.location || 'U.S.A.'))
    end
  end
end
