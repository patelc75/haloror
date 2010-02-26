class ActionMailer::ARMailer < ActionMailer::Base
  include UtilityHelper
  attr_accessor :priority
  
  def perform_delivery_activerecord(mail)
    begin
      RAILS_DEFAULT_LOGGER.warn("perform_delivery_activerecord")
      if self.priority.nil?
        self.priority = Priority::IMMEDIATE
      end
      if !mail.destinations.blank?
        if (ENV['RAILS_ENV'] == 'production' or ENV['RAILS_ENV'] == 'staging') and self.priority > Priority::THRESH_HOLD
          emails = []
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
      ActionMailer::Base.smtp_settings = SMTP_SETTINGS_GMAIL
      UtilityHelper.safe_send_email("Error sending mail: perform_delivery_activerecord\n  #{e}", 'exceptions@halomonitoring.com')
      ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST
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
          ActionMailer::Base.smtp_settings = SMTP_SETTINGS_GMAIL
          safe_send_emails(mail)
        elsif self.priority > Priority::THRESH_HOLD
          ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST
          safe_send_emails(mail)
        else
          ActionMailer::Base.smtp_settings = SMTP_SETTINGS_LOCALHOST_BACKUP
          safe_send_emails(mail)
        end
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("Error sending mail:  #{e}")
    end
  end
  
  protected
  def safe_send_emails(mail)
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
