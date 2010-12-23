class Email < ActiveRecord::Base
  def self.notify_by_priority
    RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority running at #{Time.now}")

    if Email.count < MAX_EMAILS_ALLOWED 
     arsendmail = ActionMailer::ARSendmail.new(:Once => true)
     arsendmail.run
    else
      #send critical exception here
      UtilityHelper.log_message_critical( "Email.notify_by_priority: More emails than maximum allowed #{MAX_EMAILS_ALLOWED}")
    end
  end
  
  #after_save :debug_it
  
  def debug_it
   emails = Email.all(:select => 'emails.mail').map {|p| puts p.mail[0..170] + "\n" }  
   debugger # permanent. required here
  end
end
