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

  def self.new_initialize(random=false)
    model = self.new
    if random
      model.magnitude = 60
    else
      model.magnitude = rand(60)
    end

    return model
  end
end
