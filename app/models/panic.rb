class Panic < ActiveRecord::Base
  belongs_to :user
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name} panicked on #{timestamp}"
  end
  
    def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{timestamp}" +
    "\n\nThe Halo server received the event #{Time.now} \n\n" +
    "Sincerely, Halo Staff"
  end
end
