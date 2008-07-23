class ActionMailer::ARMailer < ActionMailer::Base
  attr_accessor :priority
  
   def perform_delivery_activerecord(mail)
     begin
       RAILS_DEFAULT_LOGGER.warn("perform_delivery_activerecord")
      if self.priority.nil?
        self.priority = Priority::LOW
      end
      if !mail.destinations.blank?
        if self.priority > Priority::THRESH_HOLD || ENV['RAILS_ENV'] == 'development'
          emails = []
          ar_sendmail = ActionMailer::ARSendmail.new
          mail.destinations.each do |destination|
            emails << Email.new(:mail => mail.encoded,    :to => destination,
                                :from => mail.from.first, :priority => self.priority)
          end
          ar_sendmail = ActionMailer::ARSendmail.new
          ar_sendmail.deliver(emails)
        else
          mail.destinations.each do |destination|
          Email.create  :mail => mail.encoded,    :to => destination, 
                        :from => mail.from.first, :priority => self.priority
          end
        end
      end
      rescue Exception => e
        email = Email.new(:mail => 'Error sending mail',          :to => 'exceptions_www@halomonitoring.com', 
                            :from => 'no-reply@halomonitoring.com', :priority => 100)
        ar_sendmail = ActionMailer::ARSendmail.new
        ar_sendmail.deliver([email])
        RAILS_DEFAULT_LOGGER.warn("Error sending mail:  #{e}")
      end
    end
    
  
  def perform_delivery_smtp(mail)
    begin
    RAILS_DEFAULT_LOGGER.warn("perform_delivery_smtp")
    if self.priority.nil?
      self.priority = Priority::LOW
    end
    if !mail.destinations.blank?
      if ENV['RAILS_ENV'] == 'development' 
        ActionMailer::Base.smtp_settings = SMTP_SETTINGS_DEVELOPMENT
        send_emails(mail)
      elsif self.priority > Priority::THRESH_HOLD
        ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST
        send_emails(mail)
      else
        ActionMailer::Base.smtp_settings = SMTP_SETTINGS_SERVER2
        send_emails(mail)
      end
    end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("Error sending mail:  #{e}")
    end
  end
  def send_emails(mail)
      emails = []
      mail.destinations.each do |destination|
        emails << Email.new(:mail => mail.encoded,    :to => destination,
                            :from => mail.from.first, :priority => self.priority)
      end
      ar_sendmail = ActionMailer::ARSendmail.new
      ar_sendmail.deliver(emails)
  end
end

class ActionMailer::ARSendmail
  def find_emails
    options = { :conditions => ['last_send_attempt < ?', Time.now.to_i - 300], :order => :priority }
    options[:limit] = batch_size unless batch_size.nil?
    mail = @email_class.find :all, options
    log "found #{mail.length} emails to send"
    mail
  end
end
