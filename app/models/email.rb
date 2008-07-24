class Email < ActiveRecord::Base
  def self.notify_by_priority
    begin
      ActiveRecord::Base.logger.warn("Email.notify_by_priority running at #{Time.now}")
      ActionMailer::ARSendmail.run
    rescue
      RAILS_DEFAULT_LOGGER.warn("RESCUE called in Email.notify_by_priority")
    end
  end
end
