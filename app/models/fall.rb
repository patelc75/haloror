class Fall < CriticalDeviceAlert
  set_table_name("falls")

  def to_s
    "#{user.name}(#{user.id}) fell at #{UtilityHelper.format_datetime(timestamp, user)}"
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
  
end
