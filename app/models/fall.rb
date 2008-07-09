class Fall < ActiveRecord::Base
  belongs_to :user
  
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name} fell on #{timestamp}"
  end
  
  def email_body
    "Hello,\nWe detected that #{user.name} fell on #{timestamp}\n\n" +
    "The Halo server received the event #{Time.now} \n\n" +
    "Sincerely, Halo Staff"
  end
end
