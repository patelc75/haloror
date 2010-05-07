class Fall < CriticalDeviceAlert
  set_table_name("falls")

  def to_s
    "#{user.name}(#{user.id}) fell at #{UtilityHelper.format_datetime(timestamp, user)}"
  end

  def email_body
    "Hello,\nWe detected that #{to_s}" +
      "\n\nA Halo operator will be handling the event immediately.\n\n" +
      "Sincerely, Halo Staff"
  end

  # FIXME: What is this method doing?
  #   initialize is a standard method available on the class anyways
  #   Fall.new([true|false]) can be used to initialize the instance
  def self.new_initialize(random=false)
    model = self.new
    if random
      model.magnitude = 60
    else
      model.magnitude = rand(60)
    end

    return model
  end

  # check if the associated user profile has an account_number mentioned in it
  # this logic is used to decide critical_alert.timestamp_call_center value
  #
  def call_center_number_valid?
    !user.profile.account_number.blank? rescue false # fetch the call center account number, or, false
  end
  
end
