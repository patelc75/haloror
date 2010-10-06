class Email < ActiveRecord::Base
  def self.notify_by_priority
    RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority running at #{Time.now}")
    arsendmail = ActionMailer::ARSendmail.new(:Once => true)
    arsendmail.run
  end
  
  #after_save :debug_it
  
  def debug_it
   emails = Email.all(:select => 'emails.mail').map {|p| puts p.mail[0..170] + "\n" }  
   debugger # permanent. required here
  end
end
