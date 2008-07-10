class Fall < ActiveRecord::Base
  include UtilityHelper
  belongs_to :user
  
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def self.node_name
    return :fall
  end
  def to_s
    "#{user.name}(#{user.id}) fell at #{UtilityHelper.format_datetime_readable(timestamp, user)}"
  end
  
  def email_body
    "Hello,\nWe detected that #{to_s}\n\n" +
    "The Halo server received the event #{UtilityHelper.format_datetime_readable(Time.now, user)} \n\n" +
    "Sincerely, Halo Staff"
  end
end
