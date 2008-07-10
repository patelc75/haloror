class Fall < ActiveRecord::Base
  belongs_to :user
  
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name}(#{user.id}) fell on #{timestamp}"
  end
  
  def email_body
    "Hello,\nWe detected that #{to_s}\n\n" +
    "The Halo server received the event #{Time.now} \n\n" +
    "Sincerely, Halo Staff"
  end
end
