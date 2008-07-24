class Email < ActiveRecord::Base
  def self.notify_by_priority
    begin
      RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority running at #{Time.now}")
      ActionMailer::ARSendmail.run(:once => true)
    rescue
      RAILS_DEFAULT_LOGGER.warn("RESCUE called in Email.notify_by_priority")
    end
  end
end
